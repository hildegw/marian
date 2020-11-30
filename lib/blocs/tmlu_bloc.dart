
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

class LoadData extends TmluEvent {
  // final List<ModelSegment> segments;
  // final List<List<LatLng>> polylines;
  // final LatLng startCoord;
  final ModelCave cave;
  LoadData({ this.cave });
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
  // final List<ModelSegment> segments;
  // final List<List<LatLng>> polylines;
  // final LatLng startCoord;
  final ModelCave cave;
  final double zoom;
  final String error;
  TmluState({
    this.status = TmluStatus.loading,
    // this.segments,
    // this.polylines,
    // this.startCoord,
    this.cave,
    this.zoom,
    this.error,
  });

  TmluState copyWith({
    TmluStatus status,
    // List<ModelSegment> segments,
    // List<List<LatLng>> polylines,
    // LatLng startCoord,
    ModelCave cave,
    double zoom,
    String error,
  }) {
    return TmluState(
      status: status ?? this.status,
      // segments: segments ?? this.segments,
      // polylines: polylines ?? this.polylines,
      // startCoord: startCoord ?? this.startCoord,
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


  saveSegments(String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonList = [];
    selectedCaves.forEach((cave) => jsonList.add(jsonEncode(cave.toJson())) );
    await prefs.setStringList(path, jsonList); //TODO seg Json parse instead to read data
  }

  getSavedSegments(String path) async {
    selectedCaves = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> jsonList = prefs.getStringList(path); 
      if (jsonList != null) {
        jsonList.forEach((cave) {
          Map caveString = jsonDecode(cave);
          selectedCaves.add(ModelCave.fromJson(caveString));
        });
      }
      else selectedCaves = null;
    } catch(err) { 
      print("error fetching cave from storage: $err");
      selectedCaves = null;
    }
  }



  @override
  Stream<TmluState> mapEventToState(TmluEvent event) async* {
  
    if (event is LoadData) {
      print('tmlu bloc has data ${event.cave} ');
      selectedCaves.add(event.cave);
      yield TmluState(
        // segments: event.segments,
        // polylines: event.polylines,
        // startCoord: event.startCoord,
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
