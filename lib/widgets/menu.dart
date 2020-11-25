
import "package:flutter/material.dart";
import 'package:marian/models/model_git_search_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/tmlu_files_bloc.dart';
import '../utils/responsive.dart';
import './menu_search.dart';
import './menu_cave_item.dart';
import '../utils/tmlu_data_api.dart';


class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  bool addLine = false;
  List<ModelGitFile> files = [];
  List<String> fullNames = [];
  // List<Widget> menuList = [];
  List<Widget> caveList = [];

  void createCaveList() {
    //reset list 
    caveList = [];
    //add list widgets to menu list 
    fullNames.forEach((repo) {  //repo info / full name
      List<ModelGitFile> repoFiles = files.where((file) => file.fullName == repo).toList();
      caveList.add(MenuCaveItem(repo: repo));
      caveList.add(          //list of caves per repo
        ListView.builder(
          physics: ClampingScrollPhysics(),
          itemCount: repoFiles.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return MenuCaveItem(file: repoFiles[index], onSelected: () => onSelected(files[index]),);
          }
        ),
      );
    });
  }

  void onSelected(ModelGitFile file) {
    print(file.filename);
    TmluData().loadFromGithub(file, context);
  }


  @override
  Widget build(BuildContext context) {
    final Responsive resp = Responsive(context);

    return BlocBuilder<TmluFilesBloc, TmluFilesState>(builder: (context, state) {   

      if (state.status == TmluFilesStatus.hasTmluFiles && state.files != null) {
        //get file data for menu list
        files = state.files;
        files.forEach((file) { 
          if (!fullNames.contains(file.fullName)) fullNames.add(file.fullName);
        });
        createCaveList();
      }

      return Container(
        color: Theme.of(context).backgroundColor, 
        //height: resp.hp(80), 
        width: resp.wp(100),
        child: ListView(
          // mainAxisAlignment: MainAxisAlignment.start,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: 
          [
            MenuSearch(),
            Divider(indent: 10, endIndent: 10, height: 5,),
            ...caveList
          ]
          //List.from(menuList)..addAll(caveList),
        ),
      );
    });
  }
}