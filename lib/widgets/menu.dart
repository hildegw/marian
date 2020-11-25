
import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marian/models/model_git_search_response.dart';

import '../blocs/tmlu_files_bloc.dart';
import '../utils/responsive.dart';
import './menu_search.dart';
import './menu_cave_item.dart';


class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  bool addLine = false;
  List<ModelGitFile> files = [];
  List<String> fullNames = [];
  List<Widget> menuList = [];

  @override
  Widget build(BuildContext context) {
    final Responsive resp = Responsive(context);

    return BlocBuilder<TmluFilesBloc, TmluFilesState>(builder: (context, state) {   
    
      if (state.status == TmluFilesStatus.hasTmluFiles && state.files != null) {
        //get file data for menu list
        files = state.files;
        files.forEach((file) { 
          if (!fullNames.contains(file.fullName)) fullNames.add(file.fullName);
          print(fullNames);
        });
        //reset menuList if builder is called again
        menuList = [];
        //add all widgets to menu list 
        menuList.add(MenuSearch()); //search box
        fullNames.forEach((repo) {  //repo info / full name
          List<ModelGitFile> repoFiles = files.where((file) => file.fullName == repo).toList();
          menuList.add(Container(
                  //height: 50,
                  child: 
                  Text(
                    "repo: " + repo,
                    style: Theme.of(context).textTheme.bodyText2,
                    ),
                ));
          menuList.add(          //list of caves per repo
            ListView.builder(
              itemCount: repoFiles.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      MenuCaveItem(file: repoFiles[index]),
                    Divider(indent: 10, endIndent: 10, height: 5,),
                  ],
                );
              }
            ),
          );
        });
      }

      return Container(
        color: Theme.of(context).backgroundColor, 
        //height: resp.hp(80), 
        width: resp.wp(100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: menuList,
        ),
      );
    });
  }
}