
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
import '../utils/local_storage.dart';


abstract class TmluEvent {}

class LoadedCaveFromGithub extends TmluEvent {
  final ModelCave cave;
  LoadedCaveFromGithub({ this.cave });
}

class LocalCavesSelected extends TmluEvent {
  final List<ModelCave> localSelectedCaves;
  LocalCavesSelected({ this.localSelectedCaves });
}

class InitialViewDone extends TmluEvent {
  InitialViewDone();
}


class Zooming extends TmluEvent {
  final double zoom;
  Zooming({ this.zoom });
}

class SettingsSelected extends TmluEvent {
  final bool showStationIds, showSegmentNames;
  SettingsSelected({ this.showStationIds, this.showSegmentNames });
}

class TmluError extends TmluEvent {
  final String error;
  TmluError({this.error});
}

enum TmluStatus {
  loading,
  hasTmlu,
  initialViewDone,
  error
}

class TmluState {
  final TmluStatus status;
  //final ModelCave cave;
  final List<ModelCave> selectedCaves;  //adds both caves selected locally and loaded from github
  final double zoom;
  final bool showStationIds;
  final bool showSegmentNames;
  final String error;
  TmluState({
    this.status = TmluStatus.loading,
    //this.cave,
    this.selectedCaves,
    this.zoom,
    this.showStationIds,
    this.showSegmentNames,
    this.error,
  });

  TmluState copyWith({
    TmluStatus status,
    //ModelCave cave,
    List<ModelCave> selectedCaves,
    double zoom,
    bool showStationIds,
    bool showSegmentNames,
    String error,
  }) {
    return TmluState(
      status: status ?? this.status,
      //cave: cave ?? this.cave,
      selectedCaves: selectedCaves ?? this.selectedCaves,
      zoom: zoom?? this.zoom,
      showStationIds: showStationIds?? this.showStationIds,
      showSegmentNames: showSegmentNames?? this.showSegmentNames,
      error: error ?? this.error,
    );
  }
}

class TmluBloc extends Bloc<TmluEvent, TmluState> {

  TmluBloc(this._myRepository) : super(TmluState(
      status: TmluStatus.loading,
      showStationIds: false,
      showSegmentNames: false,
    ));
  final String _myRepository;  //just in case TODO

  final LocalStorage localStorage = LocalStorage();
  List<ModelCave> selectedCaves = []; //both caves selected from github, and localSelectedCaves

  @override
  Stream<TmluState> mapEventToState(TmluEvent event) async* {
  
    if (event is LoadedCaveFromGithub) { //is called both by github search widget
      print('tmlu bloc has data ${event.cave} ');
      selectedCaves.insert(0, event.cave);  //add each cave that is loaded to list of selected caves
      localStorage.saveCave(event.cave); //saves cave locally and adds path to list of names, if necessary
      yield state.copyWith(
        status: TmluStatus.hasTmlu,
        //cave: selectedCaves[0],   >> use selectedCaves instead
        selectedCaves: selectedCaves, //all caves from github and selected locally 
        zoom: 14.0,
        error: null,
      );
    }

    else if (event is LocalCavesSelected) { //is called by filter local caves widget
      print('tmlu bloc has local selected caves ${event.localSelectedCaves.length} ');
      //add existing list to local selected caves
      selectedCaves = List.from(event.localSelectedCaves)..addAll(selectedCaves);  
      yield state.copyWith(
        status: TmluStatus.hasTmlu,
        //cave: selectedCaves[0],   >> use selectedCaves instead
        selectedCaves: selectedCaves, //all caves from github and selected locally 
        zoom: 14.0,
        error: null,
      );
    }

    else if (event is InitialViewDone) {
        yield state.copyWith(status: TmluStatus.initialViewDone);
    }

    else if (event is Zooming) {
        yield state.copyWith(zoom: event.zoom);
    }

    else if (event is SettingsSelected) {
        yield state.copyWith(
          showStationIds: event.showStationIds,
          showSegmentNames: event.showSegmentNames,
        );
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
