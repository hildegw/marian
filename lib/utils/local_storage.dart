
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import '../models/model_cave.dart';


class LocalStorage {


  //get selected local caves TODO more than one
  Future<ModelCave> getSavedCave(String cavePath) async {  
    try {
      final prefs = await SharedPreferences.getInstance();
      String json = prefs.getString(cavePath); 
      if (json != null) {
        ModelCave cave = ModelCave.fromJson(jsonDecode(json));
        print("local storage util: getSavedCave $cavePath} ");
        return cave;
      } else throw("local storage util error decoding json for $cavePath"); 
    } catch(err) { 
      print("ocal storage util error fetching cave from storage: $err");
      return null;
    }
  }


}

