

import 'package:latlong/latlong.dart';

class ModelSegment implements Comparable {
  int id;
  int frid;
  double az;
  double dp;
  double lg;
  LatLng latlng;
  String sc;
  bool exc;
  String cl;
   
  ModelSegment({
    this.id, this.frid, this.az, this.dp, this.lg, this.latlng, this.sc, this.exc, this.cl,
  });

  toString() => 'Segment Model from $frid to $id: az=$az dp=$dp lg=$lg, and coord: ${latlng.toString()}, $sc, excluded ? $exc   ';

  ModelSegment.fromJson(Map<String, dynamic> json) : id = json["id"], frid = json["frid"], az = json["az"], 
      dp = json["dp"], lg = json["lg"], sc = json["sc"], exc = json["exc"], cl = json["cl"],
      latlng = LatLng(json["latlng"]["latitude"], json["latlng"]["longitude"]);

  Map<String, dynamic> toJson() => { "id": id, "frid": frid, "az": az, "dp": dp, "lg": lg,  
      "sc": sc, "exc": exc, "cl": cl,
      "latlng": {
        "latitude": latlng != null ? latlng.latitude : 0.0,
        "longitude": latlng != null ? latlng.longitude : 0.0,
      }
    };


//TODO segments.sort((a, b) => a.compareTo(b));
  @override
  int compareTo(other) {  //sort: -1 to come first, 1 to come after
    if (this.frid == other.id) return 1; //this line comes after other line
    else if (other.frid == this.id) return -1; 
    else if (this.frid == -1) return -1;
    else if (other.frid == -1) return 1;
    else if (this.frid < this.id && this.frid > other.id) return 1;
    else if (this.frid < this.id && this.frid < other.id) return -1;
    else if (this.frid < this.id && other.frid > this.id) return -1;
    else if (this.frid < this.id && other.frid < this.id) return 1;
    
    else if (this.frid > this.id && this.frid > other.id) return -1;
    else if (this.frid > this.id && this.frid < other.id) return 1;
    else if (this.frid > this.id && other.frid > this.id) return 1;
    else if (this.frid > this.id && other.frid < this.id) return -1;

    else return 1;
    // if (this.frid < this.id && this.id > other.id) {
    //   //print("case 1 1  ${this.id}   ${other.id}" );
    //   return 1;
    // }
    // else if (this.frid < this.id && this.id < other.id) {
    //   //print("case 2 -1  ${this.id}  ${other.id}");
    //   return -1;
    // }
    // else if (this.frid > this.id && this.id > other.id) {
    //   //print("case 3 -1  ${this.id}  ${other.id}");
    //   return -1;
    // }
    // else if (this.frid > this.id && this.id < other.id) {
    //   //print("case 4 1  ${this.id}  ${other.id}");
    //   return 1;
    // }
    // else {
    //   //print("case else 1 ");
    //   return 1;
    // }
  }

    // if (this.frid <= this.id && this.id <= other.id) return -1;
    // else if (this.frid > this.id && this.frid <= other.frid) return -1;
    // else return 1;



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
