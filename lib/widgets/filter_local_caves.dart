
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
  }

  void onLocalDelete(bool deleteItem, String path) { //just keeps track of files de/selected
    if (deleteItem) {
      if (localFilesSelected != null && localFilesSelected.length > 0) localFilesSelected.remove(path);
      localFilesToDelete.add(path);
    }
    print("filter local files: deleted file $path");
  }

  void onSelectionDone() async { //load tmlu for selected caves from github
    final tmluFilesBloc = BlocProvider.of<TmluFilesBloc>(context);
    final tmluBloc = BlocProvider.of<TmluBloc>(context);
    print("filter local files onSelectionDone");
    print("filter local files: local files selected $localFilesSelected");
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
    if (localFilesSelected != null && localFilesSelected.length > 0) {
      try {
        getSavedCaves(tmluBloc);
      } catch(err) { 
        print("menu: error fetching cave from storage: $err");
        localCavesSelected = null; 
      }
    }
    //if (filesSelected != null && filesSelected.length > 0) print("menu show map ${filesSelected[0]}");
  }


//just for testing, otherwise runs when fetching data from github
  Map<String, dynamic>  calculatePolylineCoord(List<ModelSegment> segments) {
    List<List<LatLng>> polylines = [];
    List<String> sectionNames = [];
    List<String> sectionColors = [];
    if (segments == null || segments.length < 1) return polylines = null;
    //create list of section names to identify line sections for polylines, add colors to list
    segments.forEach((seg) { 
      sectionColors.add(seg.cl);
      if (!sectionNames.contains(seg.sc)) {
        sectionNames.add(seg.sc); 
      }
    });
    //create a polyline for each station, going from frid to id
    ModelSegment prevSeg;
    segments.forEach((seg) {
      if (seg.frid == -1) prevSeg = null;
      prevSeg = segments.firstWhere((prev) => prev.id == seg.frid, orElse: () => null); //should be array with only one element found
      if (prevSeg != null && prevSeg.latlng != null) 
        polylines.add([LatLng(prevSeg.latlng.latitude, prevSeg.latlng.longitude), LatLng(seg.latlng.latitude, seg.latlng.longitude)]);
    });
    print("stations");
    print(polylines.length);
    return { "polylines": polylines, "sectionColors": sectionColors };
    //polylines.forEach((element) => print(element.toString()));
  }

  //get selected local caves
  getSavedCaves(TmluBloc tmluBloc) async {  
      await Future.forEach(localFilesSelected, (path) async {
        ModelCave cave = await localStorage.getCave(path);
    // //cave.segments.sort((a, b) => a.compareTo(b));
    // Map<String, dynamic> result = calculatePolylineCoord(cave.segments); //just for testing
    // cave.polylines = result["polylines"];
    // cave.sectionColors = result["sectionColors"];
        localCavesSelected.add(cave); 
      });
    tmluBloc.add(LocalCavesSelected(localSelectedCaves: localCavesSelected));  //saves all selected caves fetched from storage to state
  }


  @override
  Widget build(BuildContext context) {
    final Responsive resp = Responsive(context);

    return BlocBuilder<TmluFilesBloc, TmluFilesState>(builder: (context, state) {   

      if (state.cavePaths != null && state.cavePaths.length > 0) 
          createLocalList(state.cavePaths);

      //upon closing the list of caves
      if (state.status == TmluFilesStatus.localFileSelectionDone){ 
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