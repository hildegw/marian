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


  void loadFromGithub(BuildContext context) async {
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
          //if (az != 0.0 && lg != 0.0) {          //do not add lines where a new segmnet starts >> TODO >> when does this happen? Filtered when calculating LatLng
            srvd.add(item);
            segments.add(ModelSegment(id: id, frid: frid, az: az, dp: dp, lg: lg, sc: sc, exc: exc));
            if (!sectionNames.contains(sc)) sectionNames.add(sc); //create list of section names to identify line sections for polylines
          //}
        });
      });
      else throw ("error parsing tmlu data stream");
      print(srvd.length);
      print(segments.length);
      segments.where((segment) => segment.exc); //filter out lines that were deselected in Ariane TODO check
      print(segments.length);
      addCoordinates();
      calculatePolylineCoord();
      //segments.forEach((element) => print(element.toString()));
      // polylines.forEach((element) => print(element.toString()));
      //add data to bloc
      final tmluBloc = BlocProvider.of<TmluBloc>(context);
      //if (segments == null || segments.length < 1 || polylines == null) return;
      tmluBloc.add(LoadData(segments: segments, polylines: polylines, startCoord: startCoord));
    } catch (err) {
      print('error loading tmlu data in utils: $err');
    }
  }


  void loadTmlu(BuildContext context) async {
    try {
      cave = await rootBundle.loadString('assets/tmlu/hatzutz.xml');
      tmlu = XmlDocument.parse(cave);
      srvd = tmlu.findAllElements(("SRVD")).toList();
      srvd.forEach((item) {
        double az = double.parse(item.getElement("AZ").text);
        double dp = double.parse(item.getElement("DP").text);
        double lg = double.parse(item.getElement("LG").text);
        int id = int.parse(item.getElement("ID").text);
        int frid = int.parse(item.getElement("FRID").text);
        String sc = item.getElement("SC").text;  //section names
        segments.add(ModelSegment(id: id, frid: frid, az: az, dp: dp, lg: lg, sc: sc));
        if (!sectionNames.contains(sc)) sectionNames.add(sc); //create list of section names to identify line sections for polylines
      });
      addCoordinates();
      calculatePolylineCoord();
      //segments.forEach((element) => print(element.toString()));
      //polylines.forEach((element) => print(element.toString()));
      //add data to bloc
      final tmluBloc = BlocProvider.of<TmluBloc>(context);
      //if (segments == null || segments.length < 1 || polylines == null) return;
      tmluBloc.add(LoadData(segments: segments, polylines: polylines, startCoord: startCoord));
    } catch (err) {
      print('error loading tmlu data in utils: $err');
    }
  }

  void addCoordinates() {
    //get starting point coordinates
    //XmlElement startSrvd = srvd.firstWhere((item) => item.getElement("AZ").text != null);
    XmlElement startSrvd = srvd.firstWhere((item) => item.getElement("FRID").text == "-1");
    int startId = int.parse(startSrvd.getElement("ID").text);
    double lat = double.parse(startSrvd.getElement("LT").text);
    double lon = double.parse(startSrvd.getElement("LGT").text);
    segments[startId].latlng = LatLng(lat, lon);
    startCoord = LatLng(lat, lon);
    //calculate other coordinates
    segments.forEach((seg) { 
      //issue with connecting to zero point in hatzutz, need to filter out connections to where new lines start 
              //>> TODO check id = 436, frid = 415
      if (seg.id == startId || seg.id >= segments.length) return; //TODO verify these limits!!!
      Distance distance =  Distance();
      //check if from-station has coordinates to calculate offset/coordinates
      if (segments[seg.frid] != null && segments[seg.frid].latlng != null) {
        //correct length for depth
        double prevDepth = segments[seg.frid].dp;
        double deltaDepth = prevDepth != null ? seg.dp - prevDepth : 0.0;  
        double correctedLength = deltaDepth != 0.0 
          ? math.sqrt(math.pow(seg.lg, 2)-math.pow(deltaDepth, 2))
          : seg.lg;
        //calculate each station's coordinates for polyline, needs to include connections between segments that are not lines
        LatLng prevCoord = segments[seg.frid].latlng;  
        LatLng currentCoord = !correctedLength.isNaN ? distance.offset(prevCoord, correctedLength, seg.az) : distance.offset(prevCoord, seg.lg, seg.az);
        segments[seg.id].latlng = currentCoord.round();
      }
    });
    Iterable <ModelSegment> missingCoordinates = segments.where((seg) => seg.latlng == null);
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
    if (segments == null || segments.length < 1) return polylines = null;
    //identify jumps and Ts >> check SC tags
    sectionNames.forEach((name) { 
      List<LatLng> polyline = [];
      segments.forEach((seg) {
        if (seg.frid == -1 || seg.id >= segments.length) return; //TODO ????
        if (seg.sc == name && seg.latlng != null) { //&& seg.id <= segments.length && seg.frid != -1 && segments[seg.frid].lg != 0.0) 
            //TODO add frid station from other line-name, check that name is different
            if (segments[seg.frid] != null && segments[seg.frid].latlng != null && segments[seg.frid].sc != name) 
                  polyline.add(LatLng(segments[seg.frid].latlng.latitude, segments[seg.frid].latlng.longitude));
            polyline.add(LatLng(seg.latlng.latitude, seg.latlng.longitude));
        }
        polylines.add(polyline);
      });
    });
  }
}



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


