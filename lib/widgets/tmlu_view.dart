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

    double scaleFactor =  size.width / 1000;   //size to 50m as screen width

    if (segments == null || segments.length == 0) return;

    for (var i=1; i<155; i++) { //segments.length -29
      double depth = segments.singleWhere((data) => data.id == i).dp;  //TODO catch error
      double prevDepth = segments.singleWhere((data) => data.id == i-1).dp;
      double deltaDepth = depth - prevDepth;  
      double projectedDistance = deltaDepth != 0.0 
        ? math.sqrt(math.pow(segments[i].lg, 2)-math.pow(deltaDepth, 2)) * scaleFactor
        : segments[i].lg;
      double radians = segments[i].az * math.pi / 180;
      double x = projectedDistance * sin(radians);
      double y = projectedDistance * cos(radians);

      path.relativeLineTo(x, y);
    }
    print(path.getBounds());
    
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



