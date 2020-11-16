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
  }

  //check if all absolute line offsets exists (for) jumps, Ts, etc.), if not run iteration until all are set
  void addAbsoluteOffsets() {
    missingDataPoints = linePoints.where((point) => point.absX == null || point.absY == null);
    missingDataPoints.forEach((linePoint) {
      setLinePointOffsets(linePoint);
    });
    missingDataPoints = linePoints.where((point) => point.absX == null || point.absY == null);
    if (missingDataPoints != null && missingDataPoints.length > 0) {
      addAbsoluteOffsets();
    }
  }

  //get lines data and create list with all relative line points 
  void setRelativeLinePoints(double scaleFactor) {
    //read all stations and calculate their relative points
    segments.forEach((seg) { 
      //print(seg.toString());
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

    double scaleFactor = 1; //no longer needed  
    setRelativeLinePoints(scaleFactor); //create the list of points to draw

    linePoints.forEach((seg) {
      if (seg.absX != null && !seg.absX.isNaN  && seg.absY != null && !seg.absY.isNaN )
        path.moveTo(seg.absX-seg.relX, seg.absY-seg.relY);
      if (seg.relX != null && !seg.relX.isNaN && seg.relY != null && !seg.relY.isNaN) 
        path.relativeLineTo(seg.relX, seg.relY);
     });

    //center and scale canvas to fit path/cave 
    Rect bounds = path.getBounds();
    print(bounds);
    double xScale = size.width / bounds.width;
    double yScale = size.height / bounds.height;
    double scale = xScale > yScale ? yScale : xScale;
    print(xScale);
    print(yScale);
    print(bounds.width);
    print(bounds.height);
    canvas.translate(bounds.width, bounds.height);
    canvas.scale(scale/2, scale/2);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}



