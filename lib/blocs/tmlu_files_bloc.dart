
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'dart:async';
import 'package:latlong/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/model_segment.dart';
import '../models/model_git_search_response.dart';
import '../models/model_cave.dart';


abstract class TmluFilesEvent {}

class LoadData extends TmluFilesEvent {
  final List<ModelGitFile> files;
  LoadData({ this.files });
}

class LoadLocalCaves extends TmluFilesEvent { 
  LoadLocalCaves(); 
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
  selectionDone,
  filesSelected,
  noSelectedFiles,
  error
}

class TmluFilesState {
  final TmluFilesStatus status;
  final List<ModelGitFile> files;
  final List<ModelCave> localCaves;
  final bool selectionDone;
  final List<ModelGitFile> filesSelected;
  final String error;
  TmluFilesState({
    this.status = TmluFilesStatus.loading,
    this.files,
    this.localCaves,
    this.selectionDone,
    this.filesSelected,
    this.error,
  });

  TmluFilesState copyWith({
    TmluFilesStatus status,
    List<ModelGitFile> files,
    List<ModelCave> localCaves,
    bool selectionDone,
    List<ModelGitFile> filesSelected,
    String error,
  }) {
    return TmluFilesState(
      status: status ?? this.status,
      files: files ?? this.files,
      localCaves: localCaves ?? this.localCaves,
      selectionDone: selectionDone ?? this.selectionDone,
      filesSelected: filesSelected ?? this.filesSelected,
      error: error ?? this.error,
    );
  }
}

class TmluFilesBloc extends Bloc<TmluFilesEvent, TmluFilesState> {
  TmluFilesBloc() : super(TmluFilesState(status: TmluFilesStatus.loading));

  List<ModelCave> localCaves = [];

  getSavedCaves() async {
    List<String> paths = []; //TODO save and load paths
    localCaves = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> jsonList = prefs.getStringList(paths[0]); 
      if (jsonList != null) {
        jsonList.forEach((cave) {
          Map caveString = jsonDecode(cave);
          localCaves.add(ModelCave.fromJson(caveString));
        });
      }
      else localCaves = null;
    } catch(err) { 
      print("error fetching cave from storage: $err");
      localCaves = null;
    }
  }

  @override
  Stream<TmluFilesState> mapEventToState(TmluFilesEvent event) async* {
  
    if (event is LoadData) {
      print('tmlu files bloc has data ${event.files} ');
      yield TmluFilesState(
        files: event.files,
        status: TmluFilesStatus.hasTmluFiles,
        localCaves: [],
        error: null,
      );
    }

    else if (event is LoadLocalCaves) {
      print('tmlu bloc checking storage for caves} ');
      getSavedCaves();
      yield state.copyWith(
        localCaves: localCaves,   //TODO show more than one cave
      );
    }

    //this event is not really necessary any more, called when menu is closed by viewer screen
    else if (event is TmluSelectionDone) { //called from main view when menu bar is clicked
      print('tmlu files bloc event file selection is done ${event.selectionDone} ');
      yield state.copyWith(
        selectionDone: event.selectionDone,
        status: TmluFilesStatus.selectionDone,
      );
    }

    //called when menu is closed, but menu component, once selectionDone is set
    else if (event is TmluFilesSelected) {
      print('tmlu files bloc event files were selected ${event.filesSelected} ');
      //save all selected files locally, then show first selected file
      if (event.filesSelected != null && event.filesSelected.length > 0) {
        //saveSelectedFiles(event.filesSelected);
        yield state.copyWith(
          filesSelected: event.filesSelected,
          status: TmluFilesStatus.filesSelected,
        );
      } else {
        yield state.copyWith(
          filesSelected: null,
          status: TmluFilesStatus.noSelectedFiles,
        );
      }
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
