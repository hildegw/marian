import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter/services.dart';

class FormValidations {

  String checkGitUser(String user) {
    print("checking search");
    if (user == null || user.length < 4) return 'Git user required.';
    RegExp r = RegExp(r"([a-zA-Z])");
    bool hasUser = r.hasMatch(user);
    return !hasUser ? 'Git user is required.' : null;
  }

  Color formatColor(String colorString) {
    if (colorString.length == 9) return Color(int.parse(colorString.substring(1,7), radix: 16) + 0xff000000);
    else if (colorString.length == 10) return Color(int.parse(colorString.substring(2,8), radix: 16) + 0xff000000);
    else return Colors.white;
  }

}

