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
      print(ModelSegment(id: id, frid: frid, az: az, dp: dp, lg: lg).toString());
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
  int count = 0;
  Iterable<ModelLinePoint> missingDataPoints = [];

  void checkMissingDataPoints(ModelLinePoint linePoint) {
    int currentId = segments.singleWhere((data) => data.id == linePoint.station).id;
    int fromId = segments.singleWhere((data) => data.id == linePoint.station).frid;
    if (linePoints[currentId].absX != null && linePoints[currentId].absY != null) return;
    double absX = linePoints[fromId].absX != null 
      ? linePoints[fromId].absX + linePoints[currentId].relX 
      : null;
    double absY = linePoints[fromId].absY != null 
      ? linePoints[fromId].absY + linePoints[currentId].relY 
      : null;
    linePoints[currentId].absX = absX;
    linePoints[currentId].absY = absY;
    print("from $fromId to $currentId");
    print("check jumps, iteration $count: ${linePoints[currentId].toString()}");
  }

  void checkJumpOffsets() {
    print("iteration count ${count++}");
    missingDataPoints = linePoints.where((point) => point.absX == null || point.absY == null);
    missingDataPoints.forEach((linePoint) {
      checkMissingDataPoints(linePoint);
    });
    missingDataPoints = linePoints.where((point) => point.absX == null || point.absY == null);
    if (missingDataPoints != null && missingDataPoints.length > 0) {
      print("still missing data points");
      print(missingDataPoints.length);
      checkJumpOffsets();
    }
  }

  //get lines data and create list with all relative line points 
  void setRelativeLinePoints(double scaleFactor) {
    //read all stations and calculate their relative points
    for (var i=1; i<155; i++) { //155 segments.length
      double depth = segments.singleWhere((data) => data.id == i).dp;  //TODO catch error
      double prevDepth = segments.singleWhere((data) => data.id == i-1).dp;
      double deltaDepth = depth - prevDepth;  
      double projectedDistance = deltaDepth != 0.0 
        ? math.sqrt(math.pow(segments[i].lg, 2)-math.pow(deltaDepth, 2)) * scaleFactor
        : segments[i].lg;
      double radians = segments[i].az * math.pi / 180 + 180;
      double relX = projectedDistance * cos(radians);
      double relY = projectedDistance * sin(radians);
      //print("$i: ${segments[i]} ");
      linePoints.add(ModelLinePoint(station: i, relX: relX, relY: relY)); 
    }
    checkJumpOffsets();
  }


  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

    Path path = Path();
    print(size.width);
    double scaleFactor =  size.width / 600;   //size to 50m as screen width

    double offX = size.width/2;
    double offY = size.height/2;
    path.moveTo(offX, offY); //starting point
    
    if (segments == null || segments.length == 0) return;

    setRelativeLinePoints(scaleFactor);

    linePoints.forEach((seg) {
      if (seg.absX != null && seg.absY != null) path.moveTo(seg.absX+offX, seg.absY+offY);
      path.relativeLineTo(seg.relX, seg.relY);
      //print(seg.toString());
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



