
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import '../models/model_cave.dart';


class LocalStorage {

  Future<ModelCave> getCave(String cavePath) async {  
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

  void saveCave(ModelCave cave) async { //save each cave that was fetched from github
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String json = jsonEncode(cave.toJson());
    await prefs.setString(cave.path, json); 
    saveCavePaths(cave.path); //add cave to list of paths, if new
  }

  void saveCavePaths(String newPath) async { 
    List<String> cavePaths = [];
    try {     //get list of saved paths from storage
      final prefs = await SharedPreferences.getInstance();
      cavePaths = prefs.getStringList("cavePaths"); 
      if (cavePaths != null && cavePaths.length > 0 && !cavePaths.contains(newPath))
           cavePaths.add(newPath);
      if (cavePaths == null || cavePaths.length == 0) cavePaths.add(newPath);     
      //save list of paths back to storage
      await prefs.setStringList("cavePaths", cavePaths);
      print("local storage util: paths final list $cavePaths");
    } catch(err) { 
      print("local storage util: error updating list of cave paths in storage: $err");
      cavePaths = null;
    }
  }

  deleteCave(String cavePath) async {  
    try {
      final prefs = await SharedPreferences.getInstance();
      bool isDeleted = await prefs.remove(cavePath); 
      print("local storage util deleting cave $cavePath : $isDeleted");
      if (isDeleted) removeCavePath(cavePath);
      else throw("local storage util error deleting cave $cavePath"); 
    } catch(err) { 
      print("ocal storage util error deleting cave from storage: $err");
    }
  }

  void removeCavePath(String path) async { 
    List<String> cavePaths = [];
    try {     //get list of saved paths from storage
      final prefs = await SharedPreferences.getInstance();
      cavePaths = prefs.getStringList("cavePaths"); 
      if (cavePaths != null && cavePaths.length > 0 && cavePaths.contains(path))
           cavePaths.remove(path);
      //save list of paths back to storage
      await prefs.setStringList("cavePaths", cavePaths);
      print("local storage util: removed path $path");
    } catch(err) { 
      print("local storage util: error removing paths: $err");
      cavePaths = null;
    }
  }

  Future<List<String>> getCavePaths() async {
    List<String> cavePaths = [];
    try {     //get list of saved paths from storage
      final prefs = await SharedPreferences.getInstance();
      List<String> jsonList = prefs.getStringList("cavePaths"); 
      if (jsonList != null) {
        jsonList.forEach((json) {
          //print("tmlu files bloc getSavedCavePaths $json ");
          cavePaths.add(json);
        });
        return cavePaths;
      }
      else throw("local storage util error: no cave paths in local storage"); 
    } catch(err) { 
      print("tocal storage util:: error fetching list of cave paths from storage: $err");
      return null;
    }
  }


}

