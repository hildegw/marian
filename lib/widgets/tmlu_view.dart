//import 'dart:ffi';
//import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math' as math;
import '../models/model_segment.dart';


class TmluView extends StatefulWidget {
  @override
  _TmluViewState createState() => _TmluViewState();
}

class _TmluViewState extends State<TmluView> {

  String cave;
  XmlDocument tmlu;
  Iterable srvd = [];
  List<ModelSegment> segments = [];
  
  @override
  void initState() {
    loadTmlu();
    super.initState();
  }


  loadTmlu() async {
    cave = await rootBundle.loadString('assets/tmlu/hatzutz.xml');
    //print("loaded tmlu $bones");
    tmlu = XmlDocument.parse(cave);
    //final caveFile = tmlu.findElements('CaveFile');
    //final data = caveFile.elementAt(0).findElements('Data');
    // final Iterable data = tmlu.findAllElements("Data");
    srvd = tmlu.findAllElements(("SRVD"));
    print(srvd.length);
    srvd.forEach((item) {
      //XmlElement az = segment.getElement("AZ");
      double az = double.parse(item.getElement("AZ").text);
      double dp = double.parse(item.getElement("DP").text);
      double lg = double.parse(item.getElement("LG").text);
      int id = int.parse(item.getElement("ID").text);
      int frid = int.parse(item.getElement("FRID").text);
      segments.add(ModelSegment(id: id, frid: frid, az: az, dp: dp, lg: lg));
      //print(ModelSegment(id: id, frid: frid, az: az, dp: dp, lg: lg).toString());
    });
  }


  @override
  Widget build(BuildContext context) {    
    return Container(
      color: Colors.amberAccent,
      child: CustomPaint(
        painter: LinePainter(segments: segments),
        child: Center(
          child: Text("paint"),
        ),
      ),

    );
  }
}


class LinePainter extends CustomPainter{
  List<ModelSegment> segments;
  LinePainter({this.segments});
  //https://medium.com/flutter-community/paths-in-flutter-a-visual-guide-6c906464dcd0
  List <ModelLinePoint> linePoints = [ModelLinePoint(station: 0, relX: 0, relY: 0, absX: 0, absY: 0)];  //list of all relative coordinates
  Iterable<ModelLinePoint> missingDataPoints = [];

  //set absolute offset values for each line point
  void setLinePointOffsets(ModelLinePoint linePoint) {
    int fromId = segments.singleWhere((data) => data.id == linePoint.station).frid;
    int currentId = linePoint.station;//segments.singleWhere((data) => data.id == linePoint.station).id;
    if (linePoints[currentId].absX != null && linePoints[currentId].absY != null) return;
    double absX = linePoints[fromId].absX != null 
      ? linePoints[fromId].absX + linePoints[currentId].relX 
      : null;
    double absY = linePoints[fromId].absY != null 
      ? linePoints[fromId].absY + linePoints[currentId].relY 
      : null;
    linePoints[currentId].absX = absX;
    linePoints[currentId].absY = absY;
    // print("from $fromId to $currentId");
    // print("check jumps, iteration $count: ${linePoints[currentId].toString()}");
  }

  //check if all absolute line offsets exists (for) jumps, Ts, etc.), if not run iteration until all are set
  void addAbsoluteOffsets() {
    missingDataPoints = linePoints.where((point) => point.absX == null || point.absY == null);
    missingDataPoints.forEach((linePoint) {
      setLinePointOffsets(linePoint);
    });
    missingDataPoints = linePoints.where((point) => point.absX == null || point.absY == null);
    if (missingDataPoints != null && missingDataPoints.length > 0) {
      // print("still missing data points");
      // print(missingDataPoints.length);
      addAbsoluteOffsets();
    }
  }

  //get lines data and create list with all relative line points 
  void setRelativeLinePoints(double scaleFactor) {
    //read all stations and calculate their relative points
    //for (var i=1; i<segments.length-27; i++) { //155 segments.length
    segments.forEach((seg) { 
      print(seg.toString());
      double depth = seg.dp ?? 0.0; 
      double prevDepth = seg.frid > -1 && segments.length > seg.frid != null && segments[seg.frid].dp != null 
        ? segments[seg.frid].dp : 0.0;
      double deltaDepth = depth - prevDepth;  
      double projectedDistance = deltaDepth != 0.0 
        ? math.sqrt(math.pow(seg.lg, 2)-math.pow(deltaDepth, 2)) * scaleFactor
        : seg.lg;
      double radians = seg.az * math.pi / 180 + 180;
      double relX = projectedDistance * cos(radians);
      double relY = projectedDistance * sin(radians);
      //print("$i: ${segments[i]} ");
      if (seg.frid > -1) linePoints.add(ModelLinePoint(station: seg.id, relX: relX, relY: relY)); 
    });
    //add absolute offsets for jumps, Ts, etc. 
    addAbsoluteOffsets();
    //linePoints.forEach((element) => print(element.toString()));
  }


  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

    Path path = Path();
    //print(size.width);
    double scaleFactor =  size.width / 600;   //size to 50m as screen width

    double offX = size.width/2;
    double offY = size.height/2;
    path.moveTo(offX, offY); //starting point
    
    if (segments == null || segments.length == 0) return;

    setRelativeLinePoints(scaleFactor);

    print(linePoints.length);
    print(linePoints[139].toString());
    print(linePoints[155].toString());
    print(linePoints[156].toString());
    print(segments.length);
    print(segments[139].toString());
    print(segments[156].toString());
    print(segments[155].toString());

    linePoints.forEach((seg) {
      if (seg.absX != null && !seg.absX.isNaN  && seg.absY != null && !seg.absY.isNaN )
        path.moveTo(seg.absX-seg.relX+offX, seg.absY-seg.relY+offY);
      if (seg.relX != null && !seg.relX.isNaN && seg.relY != null && !seg.relY.isNaN) 
        path.relativeLineTo(seg.relX, seg.relY);
      //else path.relativeLineTo(0, 0);
     });



   //print(path.getBounds());
    
    //add jump
    // Path secondPath = Path();
    // secondPath.lineTo(size.width / 2, size.height / 2);
    // path.addPath(secondPath, Offset(16, 16));
    //path.extendWithPath(path, Offset(10, 0));
    
    
    
    canvas.drawPath(path, paint);
    



    // canvas.drawLine(
    //   Offset(0, size.height / 2),
    //   Offset(size.width, size.height / 2),
    //   paint,
    // );

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}



