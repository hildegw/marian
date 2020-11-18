//import 'dart:ffi';
//import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import '../models/model_segment.dart';
import '../blocs/tmlu_bloc.dart';



class TmluData {

  String cave;
  XmlDocument tmlu;
  Iterable srvd = [];
  List<ModelSegment> segments = [];
  List<List<LatLng>> polylines = [];
  LatLng startCoord;
  

  //calculate coordinates for lines to define map size


  void loadTmlu(BuildContext context) async {
    try {
      cave = await rootBundle.loadString('assets/tmlu/hatzutz.xml');
      //print("loaded tmlu $bones");
      tmlu = XmlDocument.parse(cave);
      //final caveFile = tmlu.findElements('CaveFile');
      //final data = caveFile.elementAt(0).findElements('Data');
      // final Iterable data = tmlu.findAllElements("Data");
      srvd = tmlu.findAllElements(("SRVD"));
      print("SRVDs ${srvd.length}");
      srvd.forEach((item) {
        //XmlElement az = segment.getElement("AZ");
        double az = double.parse(item.getElement("AZ").text);
        double dp = double.parse(item.getElement("DP").text);
        double lg = double.parse(item.getElement("LG").text);
        int id = int.parse(item.getElement("ID").text);
        int frid = int.parse(item.getElement("FRID").text);
        segments.add(ModelSegment(id: id, frid: frid, az: az, dp: dp, lg: lg));
      });
      addCoordinates();
      calculatePolylines();
      //add data to bloc
      final tmluBloc = BlocProvider.of<TmluBloc>(context);
      if (segments == null || segments.length < 1 || polylines == null) return;
      tmluBloc.add(LoadData(segments: segments));
      tmluBloc.add(LoadData(polylines: polylines));
      segments.forEach((element) => print(element.toString()));
    } catch (err) {
      print('error loading tmlu data in utils: $err');
    }
  }

  void addCoordinates() {
    //get starting point coordinates
    XmlElement startSrvd = srvd.firstWhere((item) => item.getElement("AZ").text != null);
    int startId = int.parse(startSrvd.getElement("ID").text);
    double lat = double.parse(startSrvd.getElement("LT").text);
    double lon = double.parse(startSrvd.getElement("LGT").text);
    segments[startId].latlng = LatLng(lat, lon);
    startCoord = LatLng(lat, lon);
    //calculate other coordinates
    segments.forEach((seg) { 
      if (seg.id == startId ) return;
      Distance distance =  Distance();
      if (segments[seg.frid] != null && segments[seg.frid].latlng != null) {
        LatLng prevCoord = segments[seg.frid].latlng;  //check if from-station has coordinates to calculate offset
        LatLng currentCoord = distance.offset(prevCoord, seg.lg, seg.az );
        segments[seg.id].latlng = currentCoord.round();
      }
      //print(currentCoord.round());
    });
    Iterable <ModelSegment> missingCoordinates = segments.where((seg) => seg.latlng == null);
    if (missingCoordinates != null && missingCoordinates.length > 0) addCoordinates();
  }

  void calculatePolylines() {
    if (segments == null || segments.length < 1) return polylines = null;
    List<LatLng> polyline = [];
    //identify jumps and Ts
    segments.forEach((seg) {
      if (seg.frid+1 != seg.id && polyline.length > 0) {
        polylines.add(polyline);
        polyline = [];
      } 
      polyline.add(LatLng(seg.latlng.latitude, seg.latlng.longitude));
    });


    //segments.forEach((seg) => polyline.add(LatLng(seg.latlng.latitude, seg.latlng.longitude)) );

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

//   //check for app opening via deep link, listener is set in init home
//   static void initDynamicLinks(BuildContext context) async {
//     //listener for deep link when app is open or in background
//     FirebaseDynamicLinks.instance.onLink(onSuccess: (PendingDynamicLinkData dynamicLink) async {
//       print('FB API received onLink success ${dynamicLink.toString()} ');
//       final Uri deepLink = dynamicLink?.link;
//       if (deepLink == null) return;
//       final queryParams = deepLink.queryParameters;
//       print('FB API received onLink success ${queryParams.toString()} ');
//       if (queryParams.length > 0) {
//         String houseId = queryParams['houseid'];
//         //send house info to bloc
//         final housesBloc = BlocProvider.of<HousesBloc>(context);
//         housesBloc.add(SharedHouse(houseId: houseId));
//       }
//     }, onError: (OnLinkErrorException e) async {
//       print('FB API onLinkError');
//       print(e.message);
//     });
//     //deeplink with app closed or newly installed
//     try {
//       final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();
//       final Uri deepLink = data?.link;
//       if (deepLink == null) return;
//       print('FB API received dynamic link: ${deepLink.toString()}');
//       final queryParams = deepLink.queryParameters;
//       if (queryParams.length > 0) {
//         print('FB API received dynamic link ${queryParams.toString()} ');
//         String houseId = queryParams['houseid'];
//         //send house info to bloc
//         final housesBloc = BlocProvider.of<HousesBloc>(context);
//         housesBloc.add(SharedHouse(houseId: houseId));
//       }
//     } catch (err) {
//       print('error checking for dynamic link in FB API: $err');
//     }
//   }
// }


