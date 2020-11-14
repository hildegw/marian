


class ModelSegment {
  int id;
  int frid;
  double az;
  double dp;
  double lg;
   
  ModelSegment({
    this.id, this.frid, this.az, this.dp, this.lg,
  });

  toString() => 'from $frid to $id: az=$az dp=$dp lg=$lg';
}

class ModelLinePoint {
  int station;
  double x;
  double y;
   
  ModelLinePoint({
    this.station, this.x, this.y,
  });

  toString() => 'station $station: x=$x y=$y';
}
