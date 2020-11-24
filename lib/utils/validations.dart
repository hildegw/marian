import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter/services.dart';

class FormValidations {

  String checkSearch(String searchString) {
    print("checking search");
    if (searchString == null || searchString.length < 5) return 'Please enter a cave name.';
    RegExp r = RegExp(r"([a-zA-Z])");
    bool hasSearchString = r.hasMatch(searchString);
    return !hasSearchString ? 'Please enter a cave name.' : null;
  }



}

