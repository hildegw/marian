
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
import '../utils/local_storage.dart';


abstract class TmluFilesEvent {}

class LoadData extends TmluFilesEvent {
  final List<ModelGitFile> files;
  LoadData({ this.files });
}


class LoadLocalCaves extends TmluFilesEvent {
  final bool selectionDone;
  LoadLocalCaves({this.selectionDone});
}

class TmluLocalCaveSelectionDone extends TmluFilesEvent {
  TmluLocalCaveSelectionDone();
}

class TmluGithubSearchSelectionDone extends TmluFilesEvent {
  TmluGithubSearchSelectionDone();
}

class TmluFilesSelected extends TmluFilesEvent {
  final List<ModelGitFile> gitFilesSelected;
  final List<String> localFilesSelected;
  TmluFilesSelected({this.gitFilesSelected, this.localFilesSelected});
}

class TmluFilesError extends TmluFilesEvent {
  final String error;
  TmluFilesError({this.error});
}

enum TmluFilesStatus {
  loading,
  hasTmluFiles,
  localFileSelectionDone,
  githubSearchSelectionDone,
  gitFilesSelected,
  localFilesSelected,
  error
}

class TmluFilesState {
  final TmluFilesStatus status;
  final List<ModelGitFile> files;
  final List<String> cavePaths;
  final bool selectionDone;
  final List<ModelGitFile> gitFilesSelected;
  final List <String> localFilesSelected;
  final String error;
  TmluFilesState({
    this.status = TmluFilesStatus.loading,
    this.files,
    this.cavePaths,
    this.selectionDone,
    this.gitFilesSelected,
    this.localFilesSelected,
    this.error,
  });

  TmluFilesState copyWith({
    TmluFilesStatus status,
    List<ModelGitFile> files,
    List<String> cavePaths,
    bool selectionDone,  //currently not in use, status is used instead
    List<ModelGitFile> gitFilesSelected,
    List<String> localFilesSelected,
    String error,
  }) {
    return TmluFilesState(
      status: status ?? this.status,
      files: files ?? this.files,
      cavePaths: cavePaths ?? this.cavePaths,
      selectionDone: selectionDone ?? this.selectionDone,
      gitFilesSelected: gitFilesSelected ?? this.gitFilesSelected,
      localFilesSelected: localFilesSelected ?? this.localFilesSelected,
      error: error ?? this.error,
    );
  }
}

class TmluFilesBloc extends Bloc<TmluFilesEvent, TmluFilesState> {
  TmluFilesBloc() : super(TmluFilesState(status: TmluFilesStatus.loading));

  final LocalStorage localStorage = LocalStorage();
  List<String> cavePaths = [];


  @override
  Stream<TmluFilesState> mapEventToState(TmluFilesEvent event) async* {
  
    if (event is LoadData) {
      print('tmlu files bloc has data ${event.files} ');
      yield TmluFilesState(
        files: event.files,
        status: TmluFilesStatus.hasTmluFiles,
        cavePaths: cavePaths,
        error: null,
      );
    }

    else if (event is LoadLocalCaves) { //called when app is started and later to update list of local cave paths
      print('tmlu files bloc event LoadLocalCaves from storage');
      cavePaths = await localStorage.getCavePaths();
      yield state.copyWith(
        cavePaths: cavePaths,
      );
    }

    //TODO add event called from Viewer initState to load list of last opened caves

    //event triggered by app bar when filter or search are closed, triggers filter/search component "on-done"
    else if (event is TmluGithubSearchSelectionDone) { //called from main view when menu bar is clicked
      print('tmlu files bloc event github selection is done');
      yield state.copyWith(
        status: TmluFilesStatus.githubSearchSelectionDone,
      );
    }

     //event triggered by app bar when filter or search are closed, triggers filter/search component "on-done"
    else if (event is TmluLocalCaveSelectionDone) { //called from main view when menu bar is clicked
      print('tmlu files bloc event local file selection is done');
      yield state.copyWith(
        status: TmluFilesStatus.localFileSelectionDone,
      );
    }

    //called when menu is closed, but menu component, once selectionDone is set
    else if (event is TmluFilesSelected) {
      print('tmlu files bloc event files were selected from git ${event.gitFilesSelected}, and locally ${event.localFilesSelected}');
      //save all selected files locally, then show first selected file TODO ???
      //saveSelectedFiles(event.filesSelected);
      yield state.copyWith(
        gitFilesSelected: event.gitFilesSelected,
        localFilesSelected: event.localFilesSelected,
        status: TmluFilesStatus.gitFilesSelected,
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
