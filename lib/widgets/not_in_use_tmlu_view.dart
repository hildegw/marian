//import 'dart:ffi';
//import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart' as coord;

import '../models/model_segment.dart';
import '../blocs/tmlu_bloc.dart';


//TODO Canvas controller to move and resize cave
//https://blog.codemagic.io/multi-touch-canvas-with-flutter/
//https://github.com/rodydavis/flutter_multi_touch_canvas

class TmluView extends StatefulWidget {
  @override
  _TmluViewState createState() => _TmluViewState();
}

class _TmluViewState extends State<TmluView> {

  String cave;
  XmlDocument tmlu;
  Iterable srvd = [];
  List<ModelSegment> segments = [];
  coord.LatLng startCoord;
  
  @override
  void initState() {
    loadTmlu();
    //final tmluBloc = BlocProvider.of<TmluBloc>(context);

    super.initState();
  }


  //calculate coordinates for lines to define map size
  void addCoordinates() {
    //get starting point coordinates
    XmlElement startSrvd = srvd.firstWhere((item) => item.getElement("AZ").text != null);
    int startId = int.parse(startSrvd.getElement("ID").text);
    double lat = double.parse(startSrvd.getElement("LT").text);
    double lon = double.parse(startSrvd.getElement("LGT").text);
    segments[startId].latlng = coord.LatLng(lat, lon);
    startCoord = coord.LatLng(lat, lon);
    //calculate other coordinates
    segments.forEach((seg) { 
      if (seg.id == startId ) return;
      coord.Distance distance =  coord.Distance();
      if (segments[seg.frid] != null && segments[seg.frid].latlng != null) {
        coord.LatLng prevCoord = segments[seg.frid].latlng;  //check if from-station has coordinates to calculate offset
        coord.LatLng currentCoord = distance.offset(prevCoord, seg.lg, seg.az );
        segments[seg.id].latlng = currentCoord.round();
      }
      //print(currentCoord.round());
    });
    Iterable <ModelSegment> missingCoordinates = segments.where((seg) => seg.latlng == null);
    if (missingCoordinates != null && missingCoordinates.length > 0) addCoordinates();
  }

  loadTmlu() async {
    cave = await rootBundle.loadString('assets/tmlu/hatzutz.xml');
    //print("loaded tmlu $bones");
    tmlu = XmlDocument.parse(cave);
    //final caveFile = tmlu.findElements('CaveFile');
    //final data = caveFile.elementAt(0).findElements('Data');
    // final Iterable data = tmlu.findAllElements("Data");
    srvd = tmlu.findAllElements(("SRVD"));
    print("SRVDs ${srvd.length}");
    srvd.forEach((item) {
      //XmlElement az = segment.getElement("AZ");
      double az = double.parse(item.getElement("AZ").text);
      double dp = double.parse(item.getElement("DP").text);
      double lg = double.parse(item.getElement("LG").text);
      int id = int.parse(item.getElement("ID").text);
      int frid = int.parse(item.getElement("FRID").text);
      segments.add(ModelSegment(id: id, frid: frid, az: az, dp: dp, lg: lg));
    });
    addCoordinates();
  }


  @override
  Widget build(BuildContext context) {   
    final tmluBloc = BlocProvider.of<TmluBloc>(context);
    if (segments != null && segments.length > 0) 
        tmluBloc.add(LoadData(segments: segments));

    //return BlocBuilder<TmluBloc, TmluState>(builder: (context, state) {        
      return Container(
        color: Colors.transparent,
        child: CustomPaint(
          painter: LinePainter(segments: segments, startCoord: startCoord),
          child: Center(
            //child: //MapTiles(),
            //add buttons for zooming +-, and recenter
          ),
        ),
      );
    //});
  }
}


class LinePainter extends CustomPainter{
  List<ModelSegment> segments;
  coord.LatLng startCoord;
  LinePainter({this.segments, this.startCoord});
  //https://medium.com/flutter-community/paths-in-flutter-a-visual-guide-6c906464dcd0
  List <ModelLinePoint> linePoints = [ModelLinePoint(station: 0, relX: 0, relY: 0, absX: 0, absY: 0)];  //list of all relative coordinates
  Iterable<ModelLinePoint> missingDataPoints = [];

  // //set absolute offset values for each line point
  // void setLinePointOffsets(ModelLinePoint linePoint) {
  //   int fromId = segments.singleWhere((data) => data.id == linePoint.station).frid;
  //   int currentId = linePoint.station;//segments.singleWhere((data) => data.id == linePoint.station).id;
  //   if (linePoints[currentId].absX != null && linePoints[currentId].absY != null) return;
  //   double absX = linePoints[fromId].absX != null 
  //     ? linePoints[fromId].absX + linePoints[currentId].relX 
  //     : null;
  //   double absY = linePoints[fromId].absY != null 
  //     ? linePoints[fromId].absY + linePoints[currentId].relY 
  //     : null;
  //   linePoints[currentId].absX = absX;
  //   linePoints[currentId].absY = absY;
  // }

  // //check if all absolute line offsets exists (for) jumps, Ts, etc.), if not run iteration until all are set
  // void addAbsoluteOffsets() {
  //   missingDataPoints = linePoints.where((point) => point.absX == null || point.absY == null);
  //   missingDataPoints.forEach((linePoint) {
  //     setLinePointOffsets(linePoint);
  //   });
  //   missingDataPoints = linePoints.where((point) => point.absX == null || point.absY == null);
  //   if (missingDataPoints != null && missingDataPoints.length > 0) {
  //     addAbsoluteOffsets();
  //   }
  // }

  // //get lines data and create list with all relative line points 
  // void setRelativeLinePoints(double scaleFactor) {
  //   //read all stations and calculate their relative points
  //   segments.forEach((seg) { 
  //     print(seg.toString());
  //     double depth = seg.dp ?? 0.0; 
  //     double prevDepth = seg.frid > -1 && segments.length > seg.frid != null && segments[seg.frid].dp != null 
  //       ? segments[seg.frid].dp : 0.0;
  //     double deltaDepth = depth - prevDepth;  
  //     double projectedDistance = deltaDepth != 0.0 
  //       ? math.sqrt(math.pow(seg.lg, 2)-math.pow(deltaDepth, 2)) * scaleFactor
  //       : seg.lg;
  //     double radians = (seg.az-90) * math.pi / 180;
  //     double relX = projectedDistance * cos(radians);
  //     double relY = projectedDistance * sin(radians);
  //     if (seg.frid > -1) linePoints.add(ModelLinePoint(station: seg.id, relX: relX, relY: relY)); 
  //   });
  //   //add absolute offsets for jumps, Ts, etc. 
  //   addAbsoluteOffsets();
  //   //linePoints.forEach((element) => print(element.toString()));
  // }


  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

    Path path = Path();

    // double scaleFactor = 1; //no longer needed  
    // setRelativeLinePoints(scaleFactor); //create the list of points to draw
    double zoomFactor = 5/6; //zooming cave with gestures or +- TODO

    // linePoints.forEach((seg) {
    //   if (seg.absX != null && !seg.absX.isNaN  && seg.absY != null && !seg.absY.isNaN )
    //     path.moveTo(seg.absX-seg.relX, seg.absY-seg.relY);
    //   if (seg.relX != null && !seg.relX.isNaN && seg.relY != null && !seg.relY.isNaN) 
    //     path.relativeLineTo(seg.relX, seg.relY);
    //  });

    // if (startCoord != null && startCoord.latitude != null && startCoord.longitude != null)
    //   path.moveTo(startCoord.latitude, startCoord.longitude);
    segments.forEach((seg) {
      //print(seg.toString());
      if (seg.frid < 0) return; //path.moveTo(startCoord.latitude, startCoord.longitude);
      if (seg.latlng.latitude != null && !seg.latlng.latitude.isNaN  && seg.latlng.longitude != null && !seg.latlng.longitude.isNaN ) {
        double prevLat = segments[seg.frid].latlng.latitude; //- startCoord.latitude;
        double prevLong = segments[seg.frid].latlng.longitude; //- startCoord.longitude;
        double latDiff = seg.latlng.latitude - prevLat;
        double longDiff = seg.latlng.longitude - prevLong;
//print(prevLat-startCoord.latitude);
        path.moveTo((prevLat-startCoord.latitude)*110000, (prevLong-startCoord.longitude)*110000);
        //path.moveTo(size.width/2, size.height/2);
        path.relativeLineTo(latDiff*110000, longDiff*110000);
      }
     });


    //center and scale canvas to fit path/cave 
    Rect bounds = path.getBounds();
    print(bounds);
    double xScale = size.width / bounds.width;
    double yScale = size.height / bounds.height;
    double scale = xScale > yScale ? yScale : xScale;
    double transX = size.width/2 + bounds.width/2*zoomFactor;  
    double transY = size.height/2 + bounds.height/2*zoomFactor; 
    print(xScale);
    print(yScale);
    print(scale);

    print(bounds.width);
    print(bounds.height);

    canvas.translate(transX, transY);
    canvas.scale(scale*zoomFactor, scale*zoomFactor);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}



