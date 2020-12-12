import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:flutter/services.dart' show rootBundle; //for loading assets
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong/latlong.dart';
import 'dart:convert';
import 'dart:io';
import 'package:xml/xml_events.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../models/model_segment.dart';
import '../blocs/tmlu_bloc.dart';
import '../models/model_git_search_response.dart';
import '../models/model_cave.dart';
import '../utils/local_storage.dart';


class TmluData {
  final LocalStorage localStorage = LocalStorage();
  XmlDocument tmlu;
  List<XmlElement> srvd = [];
  List<ModelSegment> segments = [];
  List<List<LatLng>> polylines = [];
  LatLng startCoord;
  List<String> sectionNames = [];
  List<List<XmlNode>> lines = [];
  int missedCoord;
  int startId = 0;
  ModelCave cave;


  Future loadFromGithub(ModelGitFile file) async {
    await localStorage.getSegments(file.filename); //check if data is available in storage, if not, load from github
    if (segments == null || segments.length < 1) {
      segments = [];
      final url = Uri.parse("https://raw.githubusercontent.com/" + file.fullName + "/master/" + file.path);
      //final url = Uri.parse('https://raw.githubusercontent.com/arosl/cave_survey/master/kaan_ha/KaanHa.tmlu');
      //final url = Uri.parse('https://raw.githubusercontent.com/arosl/cave_survey/master/hatzutz/hatzutz.tmlu');
      //print(url);
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
          print(srvdItem);
          srvdItem.forEach((item) {
            bool exc = item.getElement("EXC").text == "true"; 
            double az = double.parse(item.getElement("AZ").text);
            double dp = double.parse(item.getElement("DP").text);
            double lg = double.parse(item.getElement("LG").text);
            int id = int.parse(item.getElement("ID").text);
            int frid = int.parse(item.getElement("FRID").text);
            String sc = item.getElement("SC").text;  //section names
            String cl = item.getElement("CL").text; //colors
            //srvd.add(item);
            segments.add(ModelSegment(id: id, frid: frid, az: az, dp: dp, lg: lg, sc: sc, exc: exc, cl: cl));
          });
        });
        else throw ("error parsing tmlu data stream");
        //filter out lines that were deselected in Ariane
        segments = segments.where((segment) => !segment.exc).toList(); 
        //segments.sort((a, b) => a.compareTo(b)); >> sorting sections instead
        getStartCoordinates(); 
        addCoordinates();
        calculatePolylineCoord(segments);
        localStorage.saveSegments(file.filename, segments);
      } catch (err) {
        print('error loading tmlu data in utils: $err');
      }
    } else { //segments retrieved from storage
      print("local data");
      //segments.forEach((element) => print(element));
      //identify start coordinates
      int segIndex = segments.indexWhere((currentSeg) => currentSeg.frid == -1); //find start segment
      if (segIndex > -1) {
        startCoord = segments[segIndex].latlng;
        startId = segIndex;
      } else throw ("error finding start segment in segments retrieved from storage");
      //calculate polyline  //coordinates are already in list, no need to calculate again
      calculatePolylineCoord(segments);
      // polylines[0].forEach((el) {print(el); });
    }
    //add data to bloc >>> TODO move into files bloc!!!! Or add to list as part of event. 
    print("adding to tmlu bloc");
    cave = ModelCave(fullName: file.fullName, path: file.path, segments: segments, polylines: polylines, startCoord: startCoord);
    return cave;
    //need to add data from files bloc to tmlu bloc
    // final tmluBloc = BlocProvider.of<TmluBloc>(context);
    // tmluBloc.add(LoadData(cave: cave));
    //tmluBloc.add(LoadData(segments: segments, polylines: polylines, startCoord: startCoord));
    //segments.forEach((element) => print(element));
  }

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
        if (segIndex > -1) segments[segIndex].latlng = currentCoord;  //.round();
      }
    });
    Iterable<ModelSegment> missingCoordinates = segments.where((seg) => seg.latlng == null);
    //missingCoordinates.forEach((element) => print(element));
    if (missingCoordinates != null && missingCoordinates.length > 0 && missedCoord != missingCoordinates.length) {
      missedCoord = missingCoordinates.length;
      addCoordinates();
    }
  }

  List<List<LatLng>>  calculatePolylineCoord(List<ModelSegment> segments) {
    List<List<LatLng>> polylines = [];
    List<String> sectionNames = [];
    //create list of section names to identify line sections for polylines
    segments.forEach((seg) { if (!sectionNames.contains(seg.sc)) sectionNames.add(seg.sc); }); 
    if (segments == null || segments.length < 1) return polylines = null;
    //identify jumps and Ts to split into separate polylines
    sectionNames.forEach((name) { 
      List<LatLng> polyline = [];
      //create section list with all segments that have the same name
      List<ModelSegment> section = segments.where((seg) => seg.sc == name && seg.latlng != null).toList(); 
      //sort section based on frid, see compare method in model segment
      section.sort((a, b) => a.compareTo(b));
      //find previous segment with different name and add as first item to polyline
      Iterable<ModelSegment> prevSegs = [];
      ModelSegment prevSegToAdd;
      if (section != null && section.length > 0) section.forEach((sectionSeg) {
        if (sectionSeg.frid == -1) return prevSegs = null;
        prevSegs = segments.where((prev) => prev.id == sectionSeg.frid && prev.sc != name); //should be array with only one element found
        //if (prevSegs != null &&  prevSegs.length > 0) print("attaching jump from ${prevSegs.first.sc} ${prevSegs.first.id}  ");
        if (prevSegs != null &&  prevSegs.length > 0) prevSegs.forEach((prevseg) { //add segment to poly-section 
          if (prevseg.latlng != null) prevSegToAdd = prevseg; //add segment to section rather than polyline        
          else prevSegToAdd = null; 
               //polyline.add(prevseg.latlng);
        });
      });
      //add previous segment at start of section
      if (prevSegToAdd != null) section.insert(0, prevSegToAdd); 
      //add line section as polyline
      section.forEach((seg) => polyline.add(LatLng(seg.latlng.latitude, seg.latlng.longitude)));
      polylines.add(polyline);
      //section.forEach((seg) => print("section after sorting: from ${seg.frid} to ${seg.id}: ${seg.sc}"));
    });
    print("polylines");
    print(polylines.length);
    return polylines;
    //polylines.forEach((element) => print(element.toString()));
  }


  // saveSegments(String caveName) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   List<String> jsonList = [];
  //   segments.forEach((seg) => jsonList.add(jsonEncode(seg.toJson())) );
  //   await prefs.setStringList(caveName, jsonList); //TODO seg Json parse instead to read data
  // }

  // getSavedSegments(String caveName) async {
  //   segments = [];
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     List<String> jsonList = prefs.getStringList(caveName); 
  //     if (jsonList != null) {
  //       jsonList.forEach((seg) {
  //         Map segString = jsonDecode(seg);
  //         segments.add(ModelSegment.fromJson(segString));
  //       });
  //     }
  //     else segments = null;
  //   } catch(err) { 
  //     print("error fetching cave from storage: $err");
  //     segments = null;
  //   }
  // }


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


