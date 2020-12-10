
import "package:flutter/material.dart";
import 'package:marian/models/model_git_search_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marian/models/model_segment.dart';
import 'package:latlong/latlong.dart';

import '../blocs/tmlu_files_bloc.dart';
import '../utils/responsive.dart';
import 'github_search_input.dart';
import 'menu_cave_item.dart';
import 'menu_path_item.dart';
import '../utils/tmlu_data_api.dart';
import '../models/model_cave.dart';
import '../blocs/tmlu_bloc.dart';
import '../utils/local_storage.dart';


class GithubSearch extends StatefulWidget {
  @override
  _GithubSearchState createState() => _GithubSearchState();
}

class _GithubSearchState extends State<GithubSearch> {
  final LocalStorage localStorage = LocalStorage();
  List<ModelGitFile> files = [];
  List<String> fullNames = [];
  List<Widget> githubList = [];
  List<String> paths = [];
  List<ModelGitFile> gitFilesSelected = [];


  void createGithubList() { //creates list of all available caves from search
    //reset list 
    githubList = [];
    //add list widgets to menu list 
    fullNames.forEach((repo) {  //repo info / full name
      List<ModelGitFile> repoFiles = files.where((file) => file.fullName == repo).toList();
      githubList.add(MenuCaveItem(repo: repo));
      githubList.add(          //list of caves per repo
        ListView.builder(
          physics: ClampingScrollPhysics(),
          itemCount: repoFiles.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return MenuCaveItem(
              file: repoFiles[index], 
              onSelected: (selected) => onGitSelected(selected, files[index]),
            );
          }
        ),
      );
    });
  }

  void onGitSelected(bool selected, ModelGitFile file) { //just keeps track of files de/selected
    print("selected file in menu {$file.filename} : $selected");
    if (selected) gitFilesSelected.add(file);
    else gitFilesSelected.remove(file);
    print(gitFilesSelected);
  }

  void onSelectionDone() async { //load tmlu for selected caves from github
    final tmluFilesBloc = BlocProvider.of<TmluFilesBloc>(context);
    final tmluBloc = BlocProvider.of<TmluBloc>(context);
    print("github search onSelectionDone");
    //save selected files to state
    tmluFilesBloc.add(TmluFilesSelected(gitFilesSelected: gitFilesSelected));
    //load files from github
    if (gitFilesSelected != null && gitFilesSelected.length > 0) 
        loadCavesFromGithub(tmluBloc);
    //update state with list of caves saved locally
    tmluFilesBloc.add(LoadLocalCaves());  
  }


  loadCavesFromGithub(TmluBloc tmluBloc) async {
    try {
      Future.forEach(gitFilesSelected, (file) async {
        ModelCave cave = await TmluData().loadFromGithub(file); 
        tmluBloc.add(LoadCave(cave: cave, isLocal: false));  //saves each cave to local storage in bloc, adds name to list of paths
        print("received data in menu for cave, added to tmlu bloc");
      });
    } catch (err) { print("Menu: Error saving selected files in files bloc: $err");}
  }



  @override
  Widget build(BuildContext context) {
    final Responsive resp = Responsive(context);

    return BlocBuilder<TmluFilesBloc, TmluFilesState>(builder: (context, state) {   

      print("github search state ${state.status } ");
      print("github search  state has cave paths: ${state.cavePaths} ");

      //once search result has loaded:
      if (state.status == TmluFilesStatus.hasTmluFiles && state.files != null) {
        //get file data for menu list
        files = state.files;
        files.forEach((file) { 
          if (!fullNames.contains(file.fullName)) fullNames.add(file.fullName);
        });
        createGithubList();
      }

      //upon closing the list of search results
      if (state.status == TmluFilesStatus.githubSearchSelectionDone){ 
        onSelectionDone();
      }


      return Container(
        color: Theme.of(context).backgroundColor, 
        //height: resp.hp(80), 
        width: resp.wp(100),
        child: ListView(
          children: 
          [
            GithubSearchInput(),
            Divider(indent: 10, endIndent: 10, height: 5,),
            ...githubList,
            Divider(indent: 10, endIndent: 10, height: 5,),
          ]
        ),
      );
    });
  }
}