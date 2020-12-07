
import "package:flutter/material.dart";
import 'package:marian/models/model_git_search_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marian/models/model_segment.dart';
import 'package:latlong/latlong.dart';

import '../blocs/tmlu_files_bloc.dart';
import '../utils/responsive.dart';
import './menu_search.dart';
import './menu_cave_item.dart';
import './menu_path_item.dart';
import '../utils/tmlu_data_api.dart';
import '../models/model_cave.dart';
import '../blocs/tmlu_bloc.dart';
import '../utils/local_storage.dart';


class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final LocalStorage localStorage = LocalStorage();
  bool addLine = false;
  List<ModelGitFile> files = [];
  List<String> fullNames = [];
  // List<Widget> menuList = [];
  List<Widget> githubList = [];
  List<Widget> localList = [];
  List<String> paths = [];
  List<ModelGitFile> gitFilesSelected = [];
  List<String> localFilesSelected = [];
  List<ModelCave> localCavesSelected = [];


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
            onDelete: (deleteItem) => onLocalDelete(deleteItem, cavePaths[index]),
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

  void onLocalDelete(bool deleteItem, String path) { //just keeps track of files de/selected
    if (deleteItem)localFilesSelected.remove(path);
    //tODO delete in storage
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
    tmluFilesBloc.add(TmluFilesSelected(gitFilesSelected: gitFilesSelected, localFilesSelected: localFilesSelected));
    print("onSelectionDone");
    try {
      Future.forEach(gitFilesSelected, (file) async {
        print("future for each");
        ModelCave cave = await TmluData().loadFromGithub(file); 
        tmluBloc.add(LoadCave(cave: cave));  //saves each cave to local storage in bloc
        print("received data in menu for cave, added to tmlu bloc");
      });
    } catch (err) { print("Error saving selected files in files bloc: $err");}
    //load first selected file - TODO load all selected
    getSavedCave(tmluBloc);
            //TmluData().loadFromGithub(files[0], context);
    //if (filesSelected != null && filesSelected.length > 0) print("menu show map ${filesSelected[0]}");
  }


//just for testing, otherwise runs when fetching data from github
  List<List<LatLng>>  calculatePolylineCoord(List<ModelSegment> segments) {
    List<List<LatLng>> polylines = [];
    List<String> sectionNames = [];
    //create list of section names to identify line sections for polylines
    segments.forEach((seg) { if (!sectionNames.contains(seg.sc)) sectionNames.add(seg.sc); }); 
    if (segments == null || segments.length < 1) return polylines = null;
    //identify jumps and Ts to split into separate polylines
    sectionNames.forEach((name) { 
      List<LatLng> polyline = [];
      //create section list with all segments that have the same name
      List<ModelSegment> section = segments.where((seg) => seg.sc == name && seg.latlng != null).toList(); 
      //sort section based on frid, see compare method in model segment
      section.sort((a, b) => a.compareTo(b));
      //find previous segment with different name and add as first item to polyline
      Iterable<ModelSegment> prevSegs = [];
      ModelSegment prevSegToAdd;
      if (section != null && section.length > 0) section.forEach((sectionSeg) {
        if (sectionSeg.frid == -1) return prevSegs = null;
        prevSegs = segments.where((prev) => prev.id == sectionSeg.frid && prev.sc != name); //should be array with only one element found
        //if (prevSegs != null &&  prevSegs.length > 0) print("attaching jump from ${prevSegs.first.sc} ${prevSegs.first.id}  ");
        if (prevSegs != null &&  prevSegs.length > 0) prevSegs.forEach((prevseg) { //add segment to poly-section 
          if (prevseg.latlng != null) prevSegToAdd = prevseg; //add segment to section rather than polyline        
          else prevSegToAdd = null; 
               //polyline.add(prevseg.latlng);
        });
      });
      //add previous segment at start of section
      if (prevSegToAdd != null) section.insert(0, prevSegToAdd); 
      //add line section as polyline
      section.forEach((seg) => polyline.add(LatLng(seg.latlng.latitude, seg.latlng.longitude)));
      polylines.add(polyline);
      print(name);
      section.forEach((seg) => print("section after sorting: from ${seg.frid} to ${seg.id}: ${seg.sc}"));
    });
    print("polylines");
    print(polylines.length);
    return polylines;
    //polylines.forEach((element) => print(element.toString()));
  }



  //get selected local caves TODO more than one
  getSavedCave(TmluBloc tmluBloc) async {  
    try {
      ModelCave cave = await localStorage.getSavedCave(localFilesSelected[0]);
//cave.segments.sort((a, b) => a.compareTo(b));
cave.polylines = calculatePolylineCoord(cave.segments); //just for testing
      tmluBloc.add(LoadCave(cave: cave));  //saves each cave to local storage in bloc
      localCavesSelected.add(cave); //TODO not sure what to do with this yet
    } catch(err) { 
      print("menu: error fetching cave from storage: $err");
      localCavesSelected = null; //TODO ???
    }
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

      //upon closing the list of caves
      if (state.status == TmluFilesStatus.selectionDone){ 
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
                child: Text(" search github and save files locally", textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyText1), 
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