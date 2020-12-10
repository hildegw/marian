
import "package:flutter/material.dart";
import 'package:marian/models/model_git_search_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marian/models/model_segment.dart';
import 'package:latlong/latlong.dart';

import '../blocs/tmlu_files_bloc.dart';
import '../utils/responsive.dart';
import 'github_search_input.dart';
import 'github_cave_item.dart';
import 'filter_local_path_item.dart';
import '../utils/tmlu_data_api.dart';
import '../models/model_cave.dart';
import '../blocs/tmlu_bloc.dart';
import '../utils/local_storage.dart';


class FilterLocalCaves extends StatefulWidget {
  @override
  _FilterLocalCavesState createState() => _FilterLocalCavesState();
}

class _FilterLocalCavesState extends State<FilterLocalCaves> {
  final LocalStorage localStorage = LocalStorage();
  bool addLine = false;
  List<String> fullNames = [];
  List<Widget> localList = [];
  List<String> paths = [];
  List<ModelGitFile> gitFilesSelected = [];
  List<String> localFilesSelected = [];
  List<ModelCave> localCavesSelected = [];
  List<String> localFilesToDelete = [];

//TODO: show selected caves in local list as selected

  void createLocalList(List<String> cavePaths) {
    //resetn Widget list 
    localList = [];
    //localList.add(FilterLocalPathItem(title: "local files")); //header
    //add list widgets to menu list 
    localList.add(          //list of caves per repo
      ListView.builder(
        physics: ClampingScrollPhysics(),
        itemCount: cavePaths.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return FilterLocalPathItem(
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
    else if (localFilesSelected != null && localFilesSelected.length > 0) localFilesSelected.remove(path);
    print("menu: local files selected  $selected : $localFilesSelected");
  }

  void onLocalDelete(bool deleteItem, String path) { //just keeps track of files de/selected
    if (deleteItem) {
      if (localFilesSelected != null && localFilesSelected.length > 0) localFilesSelected.remove(path);
      localFilesToDelete.add(path);
    }
    print("menu: deleted file $path");
  }

  void onSelectionDone() async { //load tmlu for selected caves from github
    final tmluFilesBloc = BlocProvider.of<TmluFilesBloc>(context);
    final tmluBloc = BlocProvider.of<TmluBloc>(context);
    print("filter local files onSelectionDone");
    //delete local files
    print("filter local files: to delete $localFilesToDelete");
    if (localFilesToDelete != null && localFilesToDelete.length > 0) {
      await Future.forEach(localFilesToDelete, (path) => localStorage.deleteCave(path));
    }
    //save selected files to state
    tmluFilesBloc.add(TmluFilesSelected(localFilesSelected: localFilesSelected));
    //update state with list of caves saved locally
    tmluFilesBloc.add(LoadLocalCaves());  
    //load first selected file - TODO load all selected
    if (localFilesSelected != null && localFilesSelected.length > 0) 
        getSavedCaves(tmluBloc);
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

  //get selected local caves
  getSavedCaves(TmluBloc tmluBloc) async* {  
    Future.forEach(localFilesSelected, (cave) async {
      try {
        ModelCave cave = await localStorage.getCave(localFilesSelected[0]);
  //cave.segments.sort((a, b) => a.compareTo(b));
  cave.polylines = calculatePolylineCoord(cave.segments); //just for testing
       localCavesSelected.add(cave); 
      } catch(err) { 
        print("menu: error fetching cave from storage: $err");
        localCavesSelected = null; //TODO ???
      }
    });
    tmluBloc.add(LocalCavesSelected(localSelectedCaves: localCavesSelected));  //saves all selected caves fetched from storage to state
  }


  @override
  Widget build(BuildContext context) {
    final Responsive resp = Responsive(context);

    return BlocBuilder<TmluFilesBloc, TmluFilesState>(builder: (context, state) {   

      print("menu state ${state.status } ");
      print("menu state has cave paths: ${state.cavePaths} ");

      if (state.cavePaths != null && state.cavePaths.length > 0) 
          createLocalList(state.cavePaths);

      //upon closing the list of caves
      if (state.status == TmluFilesStatus.localFileSelectionDone){ 
        print("filter local files selection is done");
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
            Divider(indent: 10, endIndent: 10, height: 5,),
          ]
        ),
      );
    });
  }
}