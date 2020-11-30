

import 'package:latlong/latlong.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import './model_segment.dart';


class ModelCave extends Equatable {
  String fullName;
  String path;
  List<ModelSegment> segments;
  List<List<LatLng>> polylines;
  LatLng startCoord;
   
  ModelCave({
    this.fullName, this.path, this.segments, this.polylines, this.startCoord
  });

  //to check if cave is equal, just check path > Equitable package
  @override
  List<Object> get props => [path];
  @override
  bool get stringify => true;
  //toString() => 'Cave Model $path:: $fullName starts: $startCoord';


  ModelCave.fromJson(Map<String, dynamic> json) : fullName = json["fullName"], path = json["path"], 
    segments = json["segments"], polylines = json["polylines"], startCoord = json["startCoord"];





}

