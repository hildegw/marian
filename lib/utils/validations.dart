import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter/services.dart';

class FormValidations {

  String checkGitUser(String user) {
    print("checking search");
    if (user == null || user.length < 4) return 'Git user required.';
    RegExp r = RegExp(r"([a-zA-Z])");
    bool hasUser = r.hasMatch(user);
    return !hasUser ? 'Git user required.' : null;
  }



}

