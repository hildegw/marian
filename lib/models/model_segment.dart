

import 'package:latlong/latlong.dart';

class ModelSegment {
  int id;
  int frid;
  double az;
  double dp;
  double lg;
  LatLng latlng;
  String sc;
   
  ModelSegment({
    this.id, this.frid, this.az, this.dp, this.lg, this.latlng, this.sc,
  });

  toString() => 'Segment Model from $frid to $id: az=$az dp=$dp lg=$lg, and coord: ${latlng.toString()}, $sc';
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
