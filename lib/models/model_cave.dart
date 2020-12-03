

import 'package:latlong/latlong.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import './model_segment.dart';
//part 'model_cave.g.dart';

//call in /marian/
//flutter pub run build_runner build to autogenerate code
//flutter pub run build_runner watch to watch for changes

//@JsonSerializable(explicitToJson: true)

class ModelCave extends Equatable {
  final String fullName;
  final String path;
  final List<ModelSegment> segments;
  //@JsonKey(fromJson: _polyFromJson, toJson: _polyToJson)
  final List<List<LatLng>> polylines;
  //@JsonKey(fromJson: _latlngFromJson, toJson: _latlngToJson)
  final LatLng startCoord;
   
  ModelCave({
    this.fullName, this.path, this.segments, this.startCoord, this.polylines
  });

  //to check if cave is equal, just check path > Equitable package
  @override
  List<Object> get props => [path];
  @override
  bool get stringify => true;

  // factory ModelCave.fromJson(Map<String, dynamic> json) => _$ModelCaveFromJson(json);
  // Map<String, dynamic> toJson() => _$ModelCaveToJson(this);

  ModelCave.fromJson(Map<String, dynamic> json) : 
    fullName = json["fullName"], 
    path = json["path"], 
    segments = _segmentsFromJson(json["segments"]), 
    polylines = _polyFromJson(json["polylines"]), 
    startCoord = _latlngFromJson(json["startCoord"]);

  Map<String, dynamic> toJson() => {
    "fullName": fullName,
    "path": path,
    "segments": _segmentsToJson(segments),
    "polylines": _polyToJson(polylines),
    "startCoord": _latlngToJson(startCoord),
  };

}

// T _dataFromJson<T, S, U>(Map<String, dynamic> input, [S other1, U other2]) =>
//     input['value'] as T;

// Map<String, dynamic> _dataToJson<T, S, U>(T input, [S other1, U other2]) =>
//     {'value': input};

List<ModelSegment> _segmentsFromJson(json) { 
  List<ModelSegment> segments = [];
  json.forEach((seg) => segments.add(ModelSegment.fromJson(seg)));
  return segments;
}

List<Map<String, dynamic>> _segmentsToJson(List<ModelSegment> segments) {
  List<Map<String, dynamic>> jsonList = [];
  segments.forEach((seg) => jsonList.add(seg.toJson()));
  return jsonList;
}

LatLng _latlngFromJson(Map<String, dynamic> json) => LatLng(json["latitude"], json["longitude"] ); 
Map<String, dynamic> _latlngToJson(LatLng latlng) => {"latitude": latlng.latitude, "longitude": latlng.longitude};

List<LatLng> _listLatlngFromJson(List<dynamic> jsonList) {
  List<LatLng> latlngList = [];
  jsonList.forEach((json) => latlngList.add(_latlngFromJson(json)));
  return latlngList;
}

List<dynamic>_listLatlngToJson(List<LatLng> latlngList) {
  List<dynamic> jsonList = [];
  latlngList.forEach((latlng) => jsonList.add(_latlngToJson(latlng)));
  return jsonList;
}

List<List<LatLng>> _polyFromJson(List<dynamic> jsonList) {
  List<List<LatLng>> polys = [];
  jsonList.forEach((json) => polys.add(_listLatlngFromJson(json)));
  return polys;
}

List<dynamic> _polyToJson(List<List<LatLng>> polys){
  List<dynamic> jsonList = [];
  polys.forEach((poly) => jsonList.add(_listLatlngToJson(poly)));
  return jsonList;
}
