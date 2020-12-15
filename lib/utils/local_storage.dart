
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import '../models/model_cave.dart';
import '../models/model_segment.dart';


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
      print("local storage util error fetching cave from storage: $err");
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
    final prefs = await SharedPreferences.getInstance();
    try {     //get list of saved paths from storage
      List<String> cavePaths = [];
      cavePaths = prefs.getStringList("cavePaths"); 
      if (cavePaths != null && cavePaths.length > 0 && !cavePaths.contains(newPath))
           cavePaths.add(newPath);
      if (cavePaths == null || cavePaths.length == 0) cavePaths.add(newPath);     
      //save list of paths back to storage
      await prefs.setStringList("cavePaths", cavePaths);
      print("local storage util: paths final list $cavePaths");
    } catch(err) { 
      print("local storage util: error updating list of cave paths in storage: $err, creating new list");
      //if no cavePaths exist in storage, create new
      List<String> cavePaths = [];
      cavePaths.add(newPath);  
      await prefs.setStringList("cavePaths", cavePaths);
    }
  }

  void deleteCave(String cavePath) async {  
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

//>> saving cave instead, includes segments
  // void saveSegments(String caveName, List<ModelSegment> segments) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   List<String> jsonList = [];
  //   segments.forEach((seg) => jsonList.add(jsonEncode(seg.toJson())) );
  //   await prefs.setStringList(caveName, jsonList); //TODO seg Json parse instead to read data
  // }

  // Future<List<ModelSegment>> getSegments(String caveName) async {
  //   List<ModelSegment> segments = [];
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     List<String> jsonList = prefs.getStringList(caveName); 
  //     if (jsonList != null) {
  //       jsonList.forEach((seg) {
  //         Map segString = jsonDecode(seg);
  //         segments.add(ModelSegment.fromJson(segString));
  //       });
  //       return segments;
  //     }
  //     else throw("local storage util error: no segments in local storage"); 
  //   } catch(err) { 
  //     print("error fetching cave from storage: $err");
  //     return segments = null;
  //   }
  // }

  void saveGitUser(String gitUser) async { //save git user to preload
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("gitUser", gitUser); 
  }

  Future<String> getGitUser() async { //save git user to preload
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String gitUser = prefs.getString("gitUser"); 
    return gitUser;
  }

}

