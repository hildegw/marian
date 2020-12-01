
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'dart:async';
import 'package:latlong/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  selectionDone,
  filesSelected,
  noSelectedFiles,
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

//called from menu directly, so that tmlu bloc can be accessed
  // void saveSelectedFiles(List<ModelGitFile> files) {
  //   try {
  //     Future.forEach(files, (file) async* {
  //       ModelCave cave = await TmluData().loadFromGithub(file); 
  //   final tmluBloc = BlocProvider.of<TmluBloc>(context);
  //   tmluBloc.add(LoadData(cave: cave));

  //     });
  //   } catch (err) { print("Error saving selected files in files bloc: $err");}
  //       //load first selected file - TODO
  //           //TmluData().loadFromGithub(files[0], context);

  // }


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
