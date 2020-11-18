



import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'dart:async';
import 'package:latlong/latlong.dart';

import '../models/model_segment.dart';



abstract class TmluEvent {}

class LoadData extends TmluEvent {
  final List<ModelSegment> segments;
  LoadData({ this.segments });
}
// class SignupEvent extends UserDataEvent {
//   final UserModel userData;
//   SignupEvent({this.userData});
// }
// class GetHomesNearBy extends TmluEvent {
//   GetHomesNearBy();
// }

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
  final List<LatLng> points;
  final String error;
  TmluState({
    this.status = TmluStatus.loading,
    this.segments,
    this.points,
    this.error,
  });

  TmluState copyWith({
    TmluStatus status,
    List<ModelSegment> segments,
    String error,
  }) {
    return TmluState(
      status: status ?? this.status,
      segments: segments ?? this.segments,
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
        print('tmlu bloc has data ${event.segments} ');
        List<LatLng> points = [];
        event.segments.forEach((seg) => points.add(LatLng(seg.latlng.latitude, seg.latlng.longitude)) );
        yield TmluState(
          segments: event.segments,
          points: points,
          status: TmluStatus.hasTmlu,
          error: null,
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
