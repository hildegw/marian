
import "package:flutter/material.dart";
import 'package:marian/models/model_git_search_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/tmlu_files_bloc.dart';
import '../utils/responsive.dart';
import './menu_search.dart';
import './menu_cave_item.dart';
import './menu_path_item.dart';
import '../utils/tmlu_data_api.dart';
import '../models/model_cave.dart';
import '../blocs/tmlu_bloc.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  bool addLine = false;
  List<ModelGitFile> files = [];
  List<String> fullNames = [];
  // List<Widget> menuList = [];
  List<Widget> githubList = [];
  List<Widget> localList = [];
  List<ModelGitFile> gitFilesSelected = [];
  List<String> localFilesSelected = [];
  List<String> paths = [];


  void createLocalList(List<String> cavePaths) {
    //resetn Widget list 
    localList = [];
    localList.add(MenuPathItem(title: "local files")); //header
    //add list widgets to menu list 
    localList.add(          //list of caves per repo
      ListView.builder(
        physics: ClampingScrollPhysics(),
        itemCount: cavePaths.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return MenuPathItem(
            path: cavePaths[index], 
            onSelected: (selected) => onLocalSelected(selected, cavePaths[index]),
          );
        }
      ),
    );
  }

  void onLocalSelected(bool selected, String path) { //just keeps track of files de/selected
    if (selected) localFilesSelected.add(path);
    else localFilesSelected.remove(path);
    print(localFilesSelected);
  }

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
    tmluFilesBloc.add(TmluFilesSelected(gitFilesSelected: gitFilesSelected));
    print("onSelectionDone");
    try {
      Future.forEach(gitFilesSelected, (file) async {
        print("future for each");
        ModelCave cave = await TmluData().loadFromGithub(file); 
        tmluBloc.add(LoadCave(cave: cave));  //saves each cave to local storage in bloc
        print("received data in menu for cave, added to tmlu bloc");
      });
    } catch (err) { print("Error saving selected files in files bloc: $err");}
        //load first selected file - TODO
            //TmluData().loadFromGithub(files[0], context);
    //if (filesSelected != null && filesSelected.length > 0) print("menu show map ${filesSelected[0]}");
  }


  @override
  Widget build(BuildContext context) {
    final Responsive resp = Responsive(context);

    return BlocBuilder<TmluFilesBloc, TmluFilesState>(builder: (context, state) {   

      print("menu state ${state.status } ");
      print("menu state has cave paths: ${state.cavePaths} ");

      //once search result has loaded:
      if (state.status == TmluFilesStatus.hasTmluFiles && state.files != null) {
        //get file data for menu list
        files = state.files;
        files.forEach((file) { 
          if (!fullNames.contains(file.fullName)) fullNames.add(file.fullName);
        });
        createGithubList();
      }

      if (state.cavePaths != null && state.cavePaths.length > 0) 
          createLocalList(state.cavePaths);

   //TODO move closing info into this component, so that onDone gets called before closing!
      //upon closing the list of caves
      if (state.status == TmluFilesStatus.selectionDone){ //&& filesSelected != null && filesSelected.length > 0) {
        print("menu selection is done");
        onSelectionDone();
      }


      return Container(
        color: Theme.of(context).backgroundColor, 
        //height: resp.hp(80), 
        width: resp.wp(100),
        child: ListView(
          children: 
          [
            ...localList,
            Padding(
              padding: EdgeInsets.only(left: 10.0, right:  15, top: 10, bottom: 5),
              child: Container(  //repo name
                child: Text(" search github", textAlign: TextAlign.left, style: Theme.of(context).textTheme.bodyText1), 
              ),
            ),
            //Divider(indent: 10, endIndent: 10, height: 5,),
            MenuSearch(),
            Divider(indent: 10, endIndent: 10, height: 5,),
            ...githubList
          ]
        ),
      );
    });
  }
}