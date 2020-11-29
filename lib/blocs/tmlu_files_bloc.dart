
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

class TmluSelectionDone extends TmluFilesEvent {
  final bool selectionDone;
  TmluSelectionDone({this.selectionDone});
}

class TmluFilesSelected extends TmluFilesEvent {
  final List<ModelGitFile> filesSelected;
  TmluFilesSelected({this.filesSelected});
}

class TmluFilesError extends TmluFilesEvent {
  final String error;
  TmluFilesError({this.error});
}

enum TmluFilesStatus {
  loading,
  hasTmluFiles,
  filesSelected,
  error
}

class TmluFilesState {
  final TmluFilesStatus status;
  final List<ModelGitFile> files;
  final bool selectionDone;
  final List<ModelGitFile> filesSelected;
  final String error;
  TmluFilesState({
    this.status = TmluFilesStatus.loading,
    this.files,
    this.selectionDone,
    this.filesSelected,
    this.error,
  });

  TmluFilesState copyWith({
    TmluFilesStatus status,
    List<ModelGitFile> files,
    bool selectionDone,
    List<ModelGitFile> filesSelected,
    String error,
  }) {
    return TmluFilesState(
      status: status ?? this.status,
      files: files ?? this.files,
      selectionDone: selectionDone ?? this.selectionDone,
      filesSelected: filesSelected ?? this.filesSelected,
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

    else if (event is TmluSelectionDone) { //called from main view when menu bar is clicked
        print('tmlu files bloc event file selection is done ${event.selectionDone} ');
        yield state.copyWith(
          selectionDone: event.selectionDone,
          status: TmluFilesStatus.filesSelected,
        );
    }

    else if (event is TmluFilesSelected) {
        print('tmlu files bloc event files were selected ${event.filesSelected} ');
        yield state.copyWith(
          filesSelected: event.filesSelected,
          status: TmluFilesStatus.filesSelected,
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
