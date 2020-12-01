

import 'package:latlong/latlong.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import './model_segment.dart';
part 'model_cave.g.dart';

//call in /marian/
//flutter pub run build_runner build to autogenerate code
//flutter pub run build_runner watch to watch for changes

@JsonSerializable(explicitToJson: true)

class ModelCave extends Equatable {
  final String fullName;
  final String path;
  final List<ModelSegment> segments;
  @JsonKey(fromJson: _polyFromJson, toJson: _polyToJson)
  final List<List<LatLng>> polylines;
  @JsonKey(fromJson: _latlngFromJson, toJson: _latlngToJson)
  final LatLng startCoord;
   
  ModelCave({
    this.fullName, this.path, this.segments, this.startCoord, this.polylines
  });

  //to check if cave is equal, just check path > Equitable package
  @override
  List<Object> get props => [path];
  @override
  bool get stringify => true;

  factory ModelCave.fromJson(Map<String, dynamic> json) => _$ModelCaveFromJson(json);
  Map<String, dynamic> toJson() => _$ModelCaveToJson(this);


  // ModelCave.fromJson(Map<String, dynamic> json) : fullName = json["fullName"], path = json["path"], 
  //   segments = json["segments"], polylines = json["polylines"], startCoord = json["startCoord"];

}

// T _dataFromJson<T, S, U>(Map<String, dynamic> input, [S other1, U other2]) =>
//     input['value'] as T;

// Map<String, dynamic> _dataToJson<T, S, U>(T input, [S other1, U other2]) =>
//     {'value': input};

LatLng _latlngFromJson(Map<String, double> json) => LatLng(json["latitude"], json["longitude"] ); 
Map<String, double> _latlngToJson(LatLng latlng) => {"latitude": latlng.latitude, "longitude": latlng.longitude};

List<LatLng> _listLatlngFromJson(List<Map<String, double>> jsonList) {
  List<LatLng> latlngList = [];
  jsonList.forEach((json) => latlngList.add(_latlngFromJson(json)));
  return latlngList;
}

List<Map<String, double>> _listLatlngToJson(List<LatLng> latlngList) {
  List<Map<String, double>> jsonList = [];
  latlngList.forEach((latlng) => jsonList.add(_latlngToJson(latlng)));
  return jsonList;
}

List<List<LatLng>> _polyFromJson(List<List<Map<String, double>>> jsonList) {
  List<List<LatLng>> polys = [];
  jsonList.forEach((json) => polys.add(_listLatlngFromJson(json)));
  return polys;
}

List<List<Map<String, double>>> _polyToJson(List<List<LatLng>> polys){
  List<List<Map<String, double>>> jsonList = [];
  polys.forEach((poly) => jsonList.add(_listLatlngToJson(poly)));
  return jsonList;
}
