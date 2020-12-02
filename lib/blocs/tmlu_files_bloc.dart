
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
  final List<ModelCave> selectedCaves;
  final List<String> cavePaths;
  final bool selectionDone;
  final List<ModelGitFile> filesSelected;
  final String error;
  TmluFilesState({
    this.status = TmluFilesStatus.loading,
    this.files,
    this.selectedCaves,
    this.cavePaths,
    this.selectionDone,
    this.filesSelected,
    this.error,
  });

  TmluFilesState copyWith({
    TmluFilesStatus status,
    List<ModelGitFile> files,
    List<ModelCave> selectedCaves,
    List<String> cavePaths,
    bool selectionDone,
    List<ModelGitFile> filesSelected,
    String error,
  }) {
    return TmluFilesState(
      status: status ?? this.status,
      files: files ?? this.files,
      selectedCaves: selectedCaves ?? this.selectedCaves,
      cavePaths: cavePaths ?? this.cavePaths,
      selectionDone: selectionDone ?? this.selectionDone,
      filesSelected: filesSelected ?? this.filesSelected,
      error: error ?? this.error,
    );
  }
}

class TmluFilesBloc extends Bloc<TmluFilesEvent, TmluFilesState> {
  TmluFilesBloc() : super(TmluFilesState(status: TmluFilesStatus.loading));

  List<ModelCave> selectedCaves = [];
  List<String> cavePaths = [];


  getSavedCavePaths() async {
    try {     //get list of saved paths from storage
      final prefs = await SharedPreferences.getInstance();
      List<String> jsonList = prefs.getStringList("cavePaths"); 
      if (jsonList != null) {
        jsonList.forEach((json) {
          print("getSavedCavePaths $json ");
          //String oldPath = jsonDecode(json);
          cavePaths.add(json);
        });
      }
    } catch(err) { 
      print("tmlu files bloc: error fetching list of cave paths from storage: $err");
      cavePaths = null;
    }
  }

  getSavedCave() async {  //TODO need function to fetch selected caves only
    try {
      final prefs = await SharedPreferences.getInstance();
      String json = prefs.getString(cavePaths[0]); //TODO more than 1 cave
      if (json != null) {
        print("getSavedCave $json ");
        selectedCaves.add(ModelCave.fromJson(jsonDecode(json))); //TODO json decoder is not working!!!
        // jsonList.forEach((cave) {
        //   Map caveString = jsonDecode(cave);
        //   selectedCaves.add(ModelCave.fromJson(caveString));
        // });
      }
      else selectedCaves = null;
    } catch(err) { 
      print("tmlu files bloc: error fetching cave from storage: $err");
      selectedCaves = null;
    }
  }


  @override
  Stream<TmluFilesState> mapEventToState(TmluFilesEvent event) async* {
  
    if (event is LoadData) {
      print('tmlu files bloc has data ${event.files} ');
      yield TmluFilesState(
        files: event.files,
        status: TmluFilesStatus.hasTmluFiles,
        selectedCaves: [],
        cavePaths: [],
        error: null,
      );
    }

    else if (event is LoadLocalCaves) { //called when app opens
      print('tmlu files bloc checking storage for caves');
      await getSavedCavePaths();
      await getSavedCave(); //TODO here show all caves from last session, not just one
      yield state.copyWith(
        selectedCaves: selectedCaves,   //TODO show more than one cave, set to caves from last session here
        cavePaths: cavePaths,
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
          //TODO should update selectedCaves list
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
