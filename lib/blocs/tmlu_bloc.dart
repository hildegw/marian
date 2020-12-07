
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

  final LocalStorage localStorage = LocalStorage();
  List<ModelCave> selectedCaves = [];

  @override
  Stream<TmluState> mapEventToState(TmluEvent event) async* {
  
    if (event is LoadCave) {
      print('tmlu bloc has data ${event.cave} ');
      selectedCaves.add(event.cave);
      localStorage.saveCave(event.cave); //saves cave locally and adds path to list of names, if necessary
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
