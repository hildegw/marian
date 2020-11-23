//import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong/latlong.dart';
import 'dart:convert';
import 'dart:io';
import 'package:xml/xml_events.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../models/model_segment.dart';
import '../blocs/tmlu_bloc.dart';



class TmluData {
  //final client = HttpClient();

  String cave;
  XmlDocument tmlu;
  List<XmlElement> srvd = [];
  List<ModelSegment> segments = [];
  List<List<LatLng>> polylines = [];
  LatLng startCoord;
  List<String> sectionNames = [];
  List<List<XmlNode>> lines = [];
  int missedCoord;
  int startId = 0;
  String caveName = "test"; //TODO set cave name


  void loadFromGithub(BuildContext context) async {
    await getSavedSegments(caveName); //check if data is available in storage, if not, load from github
    if (segments == null || segments.length < 1) {
      segments = [];
      final url = Uri.parse('https://raw.githubusercontent.com/arosl/cave_survey/master/kaan_ha/KaanHa.tmlu');
      //final url = Uri.parse('https://raw.githubusercontent.com/arosl/cave_survey/master/hatzutz/hatzutz.tmlu');
      try {
        final request = await HttpClient().getUrl(url);
        final response = await request.close();
        await response
          .transform(utf8.decoder)
          .toXmlEvents()
          .selectSubtreeEvents((event) => event.name == 'SRVD')
          .toXmlNodes()
          .forEach((item) {
            lines.add(item);
          });
        if (lines != null && lines.length > 0) lines.forEach((srvdItem) {
          //print(srvdItem);
          srvdItem.forEach((item) {
            bool exc = item.getElement("EXC").text == "true"; 
            double az = double.parse(item.getElement("AZ").text);
            double dp = double.parse(item.getElement("DP").text);
            double lg = double.parse(item.getElement("LG").text);
            int id = int.parse(item.getElement("ID").text);
            int frid = int.parse(item.getElement("FRID").text);
            String sc = item.getElement("SC").text;  //section names
            srvd.add(item);
            segments.add(ModelSegment(id: id, frid: frid, az: az, dp: dp, lg: lg, sc: sc, exc: exc));
            //if (!sectionNames.contains(sc)) sectionNames.add(sc); //create list of section names to identify line sections for polylines
          });
        });
        else throw ("error parsing tmlu data stream");
        segments = segments.where((segment) => !segment.exc).toList(); //filter out lines that were deselected in Ariane 
        print("loaded segments");
        print(segments.length);
        getStartCoordinates(); 
        addCoordinates();
        calculatePolylineCoord();
        saveSegments(caveName);
      } catch (err) {
        print('error loading tmlu data in utils: $err');
      }
    } else { //segments retrieved from storage
      print("local data");
      segments.forEach((element) => print(element));
      //identify start coordinates
      int segIndex = segments.indexWhere((currentSeg) => currentSeg.frid == -1); //find start segment
      if (segIndex > -1) startCoord = segments[segIndex].latlng;
      print(startCoord);
      //calculate polyline
      calculatePolylineCoord();
      //coordinates are already in list
    }
    //add data to bloc
    final tmluBloc = BlocProvider.of<TmluBloc>(context);
    tmluBloc.add(LoadData(segments: segments, polylines: polylines, startCoord: startCoord));
  }


  // void loadTmlu(BuildContext context) async {
  //   try {
  //     cave = await rootBundle.loadString('assets/tmlu/hatzutz.xml');
  //     tmlu = XmlDocument.parse(cave);
  //     srvd = tmlu.findAllElements(("SRVD")).toList();
  //     srvd.forEach((item) {
  //       bool exc = item.getElement("EXC").text == "true"; 
  //       double az = double.parse(item.getElement("AZ").text);
  //       double dp = double.parse(item.getElement("DP").text);
  //       double lg = double.parse(item.getElement("LG").text);
  //       int id = int.parse(item.getElement("ID").text);
  //       int frid = int.parse(item.getElement("FRID").text);
  //       String sc = item.getElement("SC").text;  //section names
  //       segments.add(ModelSegment(id: id, frid: frid, az: az, dp: dp, lg: lg, sc: sc, exc: exc));
  //     });
  //     getStartCoordinates();
  //     addCoordinates();
  //     calculatePolylineCoord();
  //     //segments.forEach((element) => print(element.toString()));
  //     //add data to bloc
  //     final tmluBloc = BlocProvider.of<TmluBloc>(context);
  //     //if (segments == null || segments.length < 1 || polylines == null) return;
  //     tmluBloc.add(LoadData(segments: segments, polylines: polylines, startCoord: startCoord));
  //   } catch (err) {
  //     print('error loading tmlu data in utils: $err');
  //   }
  // }

  void getStartCoordinates() {
    //get starting point coordinates
    XmlElement startSrvd = srvd.firstWhere((item) => item.getElement("FRID").text == "-1" ); //&& item.getElement("EXC") == "false" ??? TODO
    startId = int.parse(startSrvd.getElement("ID").text);
    double lat = double.parse(startSrvd.getElement("LT").text);
    double lon = double.parse(startSrvd.getElement("LGT").text);
    startCoord = LatLng(lat, lon);
    int segIndex = segments.indexWhere((currentSeg) => currentSeg.frid == -1); //find start segment
    if (segIndex > -1) segments[segIndex].latlng = startCoord;
  }

  void addCoordinates() {
    //calculate other coordinates
    segments.forEach((seg) { 
      if (seg.id == startId) return; //start coordinates are known
      Distance distance =  Distance();
      //get previous segment for frid
      ModelSegment prevSeg = segments.where((prevSeg) => seg.frid == prevSeg.id).length > 0 ? segments.where((prevSeg) => seg.frid == prevSeg.id).first : null;
      if (prevSeg != null && prevSeg.latlng != null) {
        //correct length for depth
        double prevDepth = prevSeg.dp;
        double deltaDepth = prevDepth != null ? seg.dp - prevDepth : 0.0;  
        double correctedLength = deltaDepth != 0.0 
          ? math.sqrt(math.pow(seg.lg, 2)-math.pow(deltaDepth, 2))
          : seg.lg;
        //calculate each station's coordinates for polyline, needs to include connections between segments that are not lines
        LatLng currentCoord = !correctedLength.isNaN ? distance.offset(prevSeg.latlng, correctedLength, seg.az) : distance.offset(prevSeg.latlng, seg.lg, seg.az);
        int segIndex = segments.indexWhere((currentSeg) => seg.id == currentSeg.id);
        if (segIndex > -1) segments[segIndex].latlng = currentCoord.round();
      }
    });
    Iterable<ModelSegment> missingCoordinates = segments.where((seg) => seg.latlng == null);
    //missingCoordinates.forEach((element) => print(element));
    if (missingCoordinates != null && missingCoordinates.length > 0 && missedCoord != missingCoordinates.length) {
      missedCoord = missingCoordinates.length;
      addCoordinates();
    }
  }

  //TODO add connecting lines between segments where necessary
        //if ((seg.az == 0.0 && seg.lg == 0.0) || seg.id >= segments.length) return; >>> not sure, does not help
        //>> need to add frid segment with other line name!!!
  void calculatePolylineCoord() {
    //create list of section names to identify line sections for polylines
    segments.forEach((seg) { if (!sectionNames.contains(seg.sc)) sectionNames.add(seg.sc); }); 
    print(sectionNames);
    print(sectionNames.length);
    if (segments == null || segments.length < 1) return polylines = null;
    //identify jumps and Ts >> check SC tags
    sectionNames.forEach((name) { 
      List<LatLng> polyline = [];
      Iterable<ModelSegment> section = segments.where((seg) => seg.sc == name && seg.latlng != null); 
      print(name);
      print(section.length);
      //print(section);
      section.forEach((seg) => polyline.add(LatLng(seg.latlng.latitude, seg.latlng.longitude)));
      // segments.forEach((seg) {
      //   if (seg.frid > -1 && seg.id < segments.length && seg.sc == name && seg.latlng != null) { //&& seg.id <= segments.length && seg.frid != -1 && segments[seg.frid].lg != 0.0) 
      //       //TODO add frid station from other line-name, check that name is different
      //       // if (segments[seg.frid] != null && segments[seg.frid].latlng != null && segments[seg.frid].sc != name) 
      //       //       polyline.add(LatLng(segments[seg.frid].latlng.latitude, segments[seg.frid].latlng.longitude));
      //       polyline.add(LatLng(seg.latlng.latitude, seg.latlng.longitude));
      //   }
      polylines.add(polyline);
    });
    print("polylines");
    print(polylines.length);
    //polylines.forEach((element) => print(element.toString()));
  }

  saveSegments(String caveName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonList = [];
    segments.forEach((seg) => jsonList.add(jsonEncode(seg.toJson())) );
    await prefs.setStringList(caveName, jsonList); //TODO seg Json parse instead to read data
  }

  getSavedSegments(String caveName) async {
    segments = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> jsonList = prefs.getStringList(caveName); 
      if (jsonList != null) {
        jsonList.forEach((seg) {
          Map segString = jsonDecode(seg);
          segments.add(ModelSegment.fromJson(segString));
        });
      }
      else segments = null;
    } catch(err) { 
      print("error fetching cave from storage: $err");
      segments = null;
    }
  }


} //class





// class FirebaseAPI {
//   //called by userBloc SignupEvent (new user, or user enters name, phone, and code)
//   static Future<void> setUserById({UserModel userModel}) async {
//     final _firestoreInstance = Firestore.instance;
//     print('FBAPI send user name to FB ${userModel.toString()}');
//     await _firestoreInstance.collection("users").document(userModel.id).setData(userModel.toMap(), merge: true);
//   }

//   // //called by splash
//   // static Future<void> setUserLocationById({String uid, LocationData location}) async {
//   //   final _firestoreInstance = Firestore.instance;
//   //   GeoPoint geopoint = GeoPoint(location.latitude, location.longitude);
//   //   print('FBAPI send user location to FB $location');
//   //   await _firestoreInstance.collection("users").document(uid).setData({'location': geopoint}, merge: true);
//   // }

//   //called by login page to check if user data is already available, and fetch info
//   static Future<UserModel> getUserById(String userId) async {
//     final _firestoreInstance = Firestore.instance;

//     final snapshot = await _firestoreInstance.collection("users").document(userId).get();
//     final userModel = UserModel.fromMap(uid: snapshot.documentID, data: snapshot.data);
//     print('FBAPI fetch user name ${userModel.toString()}');
//     return userModel;
//   }

//   static Future<List<HouseModel>> getAllHouses() async {
//     List<HouseModel> houseModels = List<HouseModel>();
//     final _firestoreInstance = Firestore.instance;

//     final houses = await _firestoreInstance.collection('houses').where('isDeleted', isEqualTo: false).getDocuments();
//     houses.documents.forEach((h) {
//       final house = HouseModel.fromMap(uid: h.documentID, data: h.data);
//       houseModels.add(house);
//     });

//     return houseModels;
//   }

//   static Future<List<HouseModel>> getHousesByLocation({
//       double latitude, 
//       double longitude, 
//       int radius: MapboxSettings.SEARCH_RADIUS
//     }) async {
//     final _functionsInstance = CloudFunctions.instance;
//     List<HouseModel> houseModels = List<HouseModel>();

//     final HttpsCallable callable = _functionsInstance.getHttpsCallable(functionName: 'GetHousesByCoordinates');

//     //do not user radius for now
//     //dynamic result = await callable.call(<String, dynamic>{'latitude': latitude, 'longitude': longitude, 'radius': radius});
//     dynamic result = await callable.call(<String, dynamic>{'latitude': latitude, 'longitude': longitude });

//     result.data.forEach((h) {
//       final house = HouseModel.fromCloudFunctionMap(uid: h['id'], data: Map<String, dynamic>.from(h['data']));
//       houseModels.add(house);
//        print('FB API get houses by location $house ');
//     });

//     return houseModels;
//   }

//   //called when user receives a share that is not in the list of all houses
//   static Future<HouseModel> getHouseById(String houseId) async {
//     final _firestoreInstance = Firestore.instance;
//     try {
//       final snaps = await _firestoreInstance.collection('houses').document(houseId).get();
//       final house = HouseModel.fromMap(uid: snaps.documentID, data: snaps.data);
//       print('FBAPI fetch user name ${house.toString()}');
//       return house;
//     } catch (err) {
//       print('FB API get house by id error $err');
//     }
//     ;
//   }

//   static Stream<FirebaseUser> onAuthStateChanged() {
//     final _firestoreInstance = FirebaseAuth.instance;
//     return _firestoreInstance.onAuthStateChanged;
//   }

// }


