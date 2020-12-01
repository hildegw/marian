

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
  @JsonKey(fromJson: _dataFromJson, toJson: _dataToJson)
  final List<List<LatLng>> polylines;
  @JsonKey(fromJson: _dataFromJson, toJson: _dataToJson)
  final LatLng startCoord;
  //@JsonKey(fromJson: LatLng.fromJson, toJson: jsonEncode)
   
  ModelCave({
    this.fullName, this.path, this.segments, this.startCoord, this.polylines
  });

  //to check if cave is equal, just check path > Equitable package
  @override
  List<Object> get props => [path];
  @override
  bool get stringify => true;
  //toString() => 'Cave Model $path:: $fullName starts: $startCoord';

  factory ModelCave.fromJson(Map<String, dynamic> json) => _$ModelCaveFromJson(json);
  Map<String, dynamic> toJson() => _$ModelCaveToJson(this);

  // ModelCave.fromJson(Map<String, dynamic> json) : fullName = json["fullName"], path = json["path"], 
  //   segments = json["segments"], polylines = json["polylines"], startCoord = json["startCoord"];

}

T _dataFromJson<T, S, U>(Map<String, dynamic> input, [S other1, U other2]) =>
    input['value'] as T;

Map<String, dynamic> _dataToJson<T, S, U>(T input, [S other1, U other2]) =>
    {'value': input};