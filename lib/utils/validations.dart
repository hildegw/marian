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
    if (colorString.length < 9) return null;
    else if (colorString.length == 9) return Color(int.parse(colorString.substring(1,8), radix: 16) + 0x00000000);
    else return Color(int.parse(colorString.substring(2,9), radix: 16) + 0x00000000);
  }

}

