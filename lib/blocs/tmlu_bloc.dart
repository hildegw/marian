
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'dart:async';
import 'package:latlong/latlong.dart';

import '../models/model_segment.dart';
//import '../utils/tmlu_data.dart';


abstract class TmluEvent {}

class LoadData extends TmluEvent {
  final List<ModelSegment> segments;
  final List<List<LatLng>> polylines;
  final LatLng startCoord;
  LoadData({ this.segments, this.polylines, this.startCoord });
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
  final List<ModelSegment> segments;
  final List<List<LatLng>> polylines;
  final LatLng startCoord;
  final double zoom;
  final String error;
  TmluState({
    this.status = TmluStatus.loading,
    this.segments,
    this.polylines,
    this.startCoord,
    this.zoom,
    this.error,
  });

  TmluState copyWith({
    TmluStatus status,
    List<ModelSegment> segments,
    List<List<LatLng>> polylines,
    LatLng startCoord,
    double zoom,
    String error,
  }) {
    return TmluState(
      status: status ?? this.status,
      segments: segments ?? this.segments,
      polylines: polylines ?? this.polylines,
      startCoord: startCoord ?? this.startCoord,
      zoom: zoom?? this.zoom,
      error: error ?? this.error,
    );
  }
}

class TmluBloc extends Bloc<TmluEvent, TmluState> {


  TmluBloc(this._myRepository) : super(TmluState(status: TmluStatus.loading));
  final String _myRepository;  //just in case TODO


  @override
  Stream<TmluState> mapEventToState(TmluEvent event) async* {
  
    if (event is LoadData) {
      print('tmlu bloc has data ${event.polylines} ');
      yield TmluState(
        segments: event.segments,
        polylines: event.polylines,
        startCoord: event.startCoord,
        status: TmluStatus.hasTmlu,
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
