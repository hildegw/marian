import 'dart:math' as math;
import 'package:flutter/cupertino.dart';

class Responsive {
  double width, height, inch, safeTop, safeBottom;

  Responsive(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final _safeAreaTop = MediaQuery.of(context).padding.top;
    final _safeAreaBottom = MediaQuery.of(context).padding.bottom;
    //print('responsive safe area top $_safeAreaTop and bottom $_safeAreaBottom');

    width = size.width;
    height = size.height;
    safeTop = _safeAreaTop;
    safeBottom = _safeAreaBottom;

    // c2=a2+b2 => c = sqrt(a2+b2)

    inch = math.sqrt(math.pow(width, 2) + math.pow(height, 2));
  }

  double get safeAreaTop => safeTop;

  double get safeAreaBottom => safeBottom;

  double wp(double percent) {
    return width * percent / 100;
  }


  double hp(double percent) {
    return height * percent / 100;
  }


  double ip(double percent) {
    return inch * percent / 100;
  }
  
}
