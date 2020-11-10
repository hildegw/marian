import 'dart:ffi';
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

  String bones;
  XmlDocument tmlu;
  Iterable srvd = [];
  List segments = [];
  
  @override
  void initState() {
    loadTmlu();
    super.initState();
  }


  loadTmlu() async {
    bones = await rootBundle.loadString('assets/tmlu/bones.xml');
    //print("loaded tmlu $bones");
    tmlu = XmlDocument.parse(bones);
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
    path.moveTo(size.width/2, size.height/2); //starting point
      print(size.width);

    for (var i=4; i<segments.length; i++) {
      double distance = segments[i][2] / 10 * size.width;
      double radians = segments[i][0] * math.pi / 180;
      double x = distance * sin(radians) + size.width/2;
      double y = distance * cos(radians) + size.height/2;
      print("x: $x, y: $y");
      print("x-y-distance $distance");
      print("length ${segments[i][2]}");
      print("radians $radians");
      print("azimuth ${segments[i][0]}");
      path.lineTo(x, y); 

    }

    //path.moveTo(size.width, size.height); //starting point
    //path.lineTo(size.width/3, size.height/3+100); //end point
    
    // Path secondPath = Path();
    // secondPath.lineTo(size.width / 2, size.height / 2);
    // path.addPath(secondPath, Offset(16, 16));


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



