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
  
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

    Path path = Path();
    print(size.width);

    double offX = size.width/2;
    double offY = size.height/2;
    path.moveTo(offX, offY); //starting point
    double scaleFactor =  size.width / 600;   //size to 50m as screen width
    List <ModelLinePoint> linePoints = [ModelLinePoint(station: 0, x: 0, y: 0)];  //list of all relative coordinates

    if (segments == null || segments.length == 0) return;

    //read all stations and calculate their relative points
    for (var i=1; i<segments.length; i++) { //155
      double depth = segments.singleWhere((data) => data.id == i).dp;  //TODO catch error
      double prevDepth = segments.singleWhere((data) => data.id == i-1).dp;
      double deltaDepth = depth - prevDepth;  
      double projectedDistance = deltaDepth != 0.0 
        ? math.sqrt(math.pow(segments[i].lg, 2)-math.pow(deltaDepth, 2)) * scaleFactor
        : segments[i].lg;
      double radians = segments[i].az * math.pi / 180 + 180;
      double x = projectedDistance * cos(radians);
      double y = projectedDistance * sin(radians);
      print("$i: ${segments[i]} ");
      linePoints.add(ModelLinePoint(station: i, x: x, y: y)); 
    }

    //then check for jumps/Ts and paint line
    for (var i=0; i<155; i++) { //segments.length -29
      int currentId = segments.singleWhere((data) => data.id == i).id;
      int fromId = segments.singleWhere((data) => data.id == i).frid;
      //check where ids are discontinuous, and calculate jump/T tie-in point
      if (fromId + 1 != currentId && linePoints.length > 0) {
        print(fromId);
        print(currentId);
        List <double> startCoord = [0.0, 0.0];
        linePoints.forEach((segment) {
          if (segment.station <= fromId) startCoord = [startCoord[0] + segment.x, startCoord[1] + segment.y];
        });
        //move to tie-in point
        print("move to $startCoord ");
        //move to [-48.94182047421762, -14.34621069655474]: 14
        // x=50;
        // y=50;
        path.moveTo(startCoord[0]+offX, startCoord[1]+offY);
      }
      //paint line relative to previous point or to jump/T tie-in point
      path.relativeLineTo(linePoints[i].x, linePoints[i].y);
    }


    print(linePoints[linePoints.length -1]);
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



