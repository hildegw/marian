
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
  final bool selectionDone;
  LoadLocalCaves({this.selectionDone});
}

class TmluSelectionDone extends TmluFilesEvent {
  TmluSelectionDone();
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
  selectionDone,
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
    bool selectionDone,
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

  List<String> cavePaths = [];


  getSavedCavePaths() async {
    try {     //get list of saved paths from storage
      final prefs = await SharedPreferences.getInstance();
      List<String> jsonList = prefs.getStringList("cavePaths"); 
      if (jsonList != null) {
        jsonList.forEach((json) {
          //print("tmlu files bloc getSavedCavePaths $json ");
          cavePaths.add(json);
        });
      }
    } catch(err) { 
      print("tmlu files bloc: error fetching list of cave paths from storage: $err");
      cavePaths = null;
    }
  }



  @override
  Stream<TmluFilesState> mapEventToState(TmluFilesEvent event) async* {
  
    if (event is LoadData) {
      print('tmlu files bloc has data ${event.files} ');
      yield TmluFilesState(
        files: event.files,
        status: TmluFilesStatus.hasTmluFiles,
        cavePaths: [],
        error: null,
      );
    }

    else if (event is LoadLocalCaves) { //called when app opens
      print('tmlu files bloc event LoadLocalCaves from storage');
      await getSavedCavePaths();
      yield state.copyWith(
        cavePaths: cavePaths,
      );
    }

    //this event is not really necessary any more, called when menu is closed by viewer screen
    else if (event is TmluSelectionDone) { //called from main view when menu bar is clicked
      print('tmlu files bloc event file selection is done} ');
      yield state.copyWith(
        status: TmluFilesStatus.selectionDone,
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
