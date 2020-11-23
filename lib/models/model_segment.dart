

import 'package:latlong/latlong.dart';

class ModelSegment {
  int id;
  int frid;
  double az;
  double dp;
  double lg;
  LatLng latlng;
  String sc;
  bool exc;
   
  ModelSegment({
    this.id, this.frid, this.az, this.dp, this.lg, this.latlng, this.sc, this.exc,
  });

  toString() => 'Segment Model from $frid to $id: az=$az dp=$dp lg=$lg, and coord: ${latlng.toString()}, $sc, excluded ? $exc   ';

  ModelSegment.fromJson(Map<String, dynamic> json) : id = json["id"], frid = json["frid"], az = json["az"], 
      dp = json["dp"], lg = json["lg"], latlng = json["latlng"], sc = json["sc"], exc = json["exc"];

  Map<String, dynamic> toJson() => { "id": id, "frid": frid, "az": az, "dp": dp, "lg": lg, "laglng": latlng, "sc": sc, "exc": exc  };



}

//not in use, just for drawing lines
class ModelLinePoint {
  int station;
  double relX;
  double relY;
  double absX;
  double absY;
   
  ModelLinePoint({
    this.station, this.relX, this.relY, this.absX, this.absY,
  });

  toString() => 'station $station: relative: x=$relX y=$relY, offset: x=$absX, y=$absY ';
}
