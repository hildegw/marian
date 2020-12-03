// GENERATED CODE - DO NOT MODIFY BY HAND

// part of 'model_cave.dart';

// // **************************************************************************
// // JsonSerializableGenerator
// // **************************************************************************

// ModelCave _$ModelCaveFromJson(Map<String, dynamic> json) {
//   return ModelCave(
//     fullName: json['fullName'] as String,
//     path: json['path'] as String,
//     segments: (json['segments'] as List)
//         ?.map((e) =>
//             e == null ? null : ModelSegment.fromJson(e as Map<String, dynamic>))
//         ?.toList(),
//     startCoord: _latlngFromJson(json['startCoord'] as Map<String, double>),
//     polylines:
//         _polyFromJson(json['polylines'] as List<List<Map<String, double>>>),
//   );
// }

// Map<String, dynamic> _$ModelCaveToJson(ModelCave instance) => <String, dynamic>{
//       'fullName': instance.fullName,
//       'path': instance.path,
//       'segments': instance.segments?.map((e) => e?.toJson())?.toList(),
//       'polylines': _polyToJson(instance.polylines),
//       'startCoord': _latlngToJson(instance.startCoord),
//     };
