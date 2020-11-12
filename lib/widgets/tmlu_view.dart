//import 'dart:ffi';
//import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math' as math;

class TmluView extends StatefulWidget {
  @override
  _TmluViewState createState() => _TmluViewState();
}

class _TmluViewState extends State<TmluView> {

  String cave;
  XmlDocument tmlu;
  Iterable srvd = [];
  List segments = [];
  
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
    srvd.forEach((segment) {
      //XmlElement az = segment.getElement("AZ");
      double az = double.parse(segment.getElement("AZ").text);
      double dp = double.parse(segment.getElement("DP").text);
      double lg = double.parse(segment.getElement("LG").text);
      segments.add([az, dp, lg]);
    });
    print(segments);
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
  List segments;
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

    for (var i=0; i<segments.length -100; i++) {
      double deltaDepth = i > 0 ? segments[i][1] - segments[i-1][1] : 0;
      //double distance = segments[i][2] * scaleFactor;
      double projectedDistance = deltaDepth != 0.0 
        ? math.sqrt(math.pow(segments[i][2], 2)-math.pow(deltaDepth, 2)) * scaleFactor
        : segments[i][2];
      double radians = segments[i][0] * math.pi / 180;
      double x = projectedDistance * sin(radians);
      double y = projectedDistance * cos(radians);
      // print("depth at station $i: ${segments[i][1]}");
      // print("x: $x, y: $y");
      // print("length ${segments[i][2]}");
      // print("azimuth ${segments[i][0]}");
      print("deltaDepth $i: $deltaDepth");
      print("projectedDistance $projectedDistance");
      print(segments[i][2] * scaleFactor); //uncorrected distance
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



