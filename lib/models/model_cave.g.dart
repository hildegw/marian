// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_cave.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModelCave _$ModelCaveFromJson(Map<String, dynamic> json) {
  return ModelCave(
    fullName: json['fullName'] as String,
    path: json['path'] as String,
    segments: (json['segments'] as List)
        ?.map((e) =>
            e == null ? null : ModelSegment.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    startCoord: _dataFromJson(json['startCoord'] as Map<String, dynamic>),
    polylines: _dataFromJson(json['polylines'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ModelCaveToJson(ModelCave instance) => <String, dynamic>{
      'fullName': instance.fullName,
      'path': instance.path,
      'segments': instance.segments?.map((e) => e?.toJson())?.toList(),
      'polylines': _dataToJson(instance.polylines),
      'startCoord': _dataToJson(instance.startCoord),
    };
