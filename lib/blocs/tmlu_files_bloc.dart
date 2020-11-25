
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'dart:async';
import 'package:latlong/latlong.dart';

import '../models/model_segment.dart';
import '../models/model_git_search_response.dart';


abstract class TmluFilesEvent {}

class LoadData extends TmluFilesEvent {
  final List<ModelGitFile> files;
  LoadData({ this.files });
}

class TmluFilesError extends TmluFilesEvent {
  final String error;
  TmluFilesError({this.error});
}

enum TmluFilesStatus {
  loading,
  hasTmluFiles,
  error
}

class TmluFilesState {
  final TmluFilesStatus status;
  final List<ModelGitFile> files;
  final String error;
  TmluFilesState({
    this.status = TmluFilesStatus.loading,
    this.files,
    this.error,
  });

  TmluFilesState copyWith({
    TmluFilesStatus status,
    List<ModelGitFile> files,
    String error,
  }) {
    return TmluFilesState(
      status: status ?? this.status,
      files: files ?? this.files,
      error: error ?? this.error,
    );
  }
}

class TmluFilesBloc extends Bloc<TmluFilesEvent, TmluFilesState> {
  TmluFilesBloc() : super(TmluFilesState(status: TmluFilesStatus.loading));

  @override
  Stream<TmluFilesState> mapEventToState(TmluFilesEvent event) async* {
  
    if (event is LoadData) {
        print('tmlu files bloc has data ${event.files} ');
        yield TmluFilesState(
          files: event.files,
          status: TmluFilesStatus.hasTmluFiles,
          error: null,
        );
    }

    else if (event is TmluFilesError) {
        print('tmlu files bloc event error ${event.error} ');
        yield state.copyWith(error: event.error);
    }

    else {
        print('tmlu files bloc event unspecific error ');
        yield state.copyWith(error: 'unspecific error');
    }
    
  }
}
