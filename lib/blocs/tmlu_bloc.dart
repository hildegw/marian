
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'dart:async';
import 'package:latlong/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

import '../models/model_segment.dart';
import '../models/model_cave.dart';
//import '../utils/tmlu_data.dart';


abstract class TmluEvent {}

class LoadCave extends TmluEvent {
  final ModelCave cave;
  LoadCave({ this.cave });
}

class Zooming extends TmluEvent {
  final double zoom;
  Zooming({ this.zoom });
}

class TmluError extends TmluEvent {
  final String error;
  TmluError({this.error});
}

enum TmluStatus {
  loading,
  hasTmlu,
  error
}

class TmluState {
  final TmluStatus status;
  final ModelCave cave;
  final double zoom;
  final String error;
  TmluState({
    this.status = TmluStatus.loading,
    this.cave,
    this.zoom,
    this.error,
  });

  TmluState copyWith({
    TmluStatus status,
    ModelCave cave,
    double zoom,
    String error,
  }) {
    return TmluState(
      status: status ?? this.status,
      cave: cave ?? this.cave,
      zoom: zoom?? this.zoom,
      error: error ?? this.error,
    );
  }
}

class TmluBloc extends Bloc<TmluEvent, TmluState> {

  TmluBloc(this._myRepository) : super(TmluState(status: TmluStatus.loading));
  final String _myRepository;  //just in case TODO

  List<ModelCave> selectedCaves = [];


  saveCave(ModelCave cave) async { //save each cave that was fetched from github
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String json = jsonEncode(cave.toJson());
    await prefs.setString(cave.path, json); 
    saveToListOfCavePaths(cave.path);
  }

  void saveToListOfCavePaths(String newPath) async { //keep a list with paths of all local caves in storage
    List<String> cavePaths = [];
    try {     //get list of saved paths from storage
      final prefs = await SharedPreferences.getInstance();
      cavePaths = prefs.getStringList("cavePaths"); 
      if (cavePaths != null && cavePaths.length > 0 && !cavePaths.contains(newPath))
           cavePaths.add(newPath);
      if (cavePaths == null || cavePaths.length == 0) cavePaths.add(newPath);     
      //save list of paths back to storage
      await prefs.setStringList("cavePaths", cavePaths);
      print("tmlu bloc saveToListOfCavePaths paths final list $cavePaths");
    } catch(err) { 
      print("tmlu bloc: error updating list of cave paths in storage: $err");
      cavePaths = null;
    }
  }

  @override
  Stream<TmluState> mapEventToState(TmluEvent event) async* {
  
    if (event is LoadCave) {
      print('tmlu bloc has data ${event.cave} ');
      selectedCaves.add(event.cave);
      saveCave(event.cave);
      yield TmluState(
        status: TmluStatus.hasTmlu,
        cave: selectedCaves[0],   //TODO show more than one cave
        zoom: 14.0,
        error: null,
      );
    }

    else if (event is Zooming) {
        yield state.copyWith(zoom: event.zoom);
    }

    else if (event is TmluError) {
        print('tmlu bloc event error ${event.error} ');
        yield state.copyWith(error: event.error);
    }

    else {
        print('tmlu bloc event unspecific error ');
        yield state.copyWith(error: 'unspecific error');
    }
    
  }
}
