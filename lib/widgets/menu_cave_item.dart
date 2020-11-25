
import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marian/models/model_git_search_response.dart';

import '../blocs/tmlu_files_bloc.dart';
import '../utils/responsive.dart';
import '../models/model_git_search_response.dart';


class MenuCaveItem extends StatelessWidget {
  final ModelGitFile file;
  final String repo;
  MenuCaveItem({ this.file, this.repo });


  @override
  Widget build(BuildContext context) {
    final Responsive resp = Responsive(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: repo == null ? CrossAxisAlignment.start : CrossAxisAlignment.center,        
      children: [
        repo == null
        ? Padding(
          padding: EdgeInsets.only(left: 15.0, right:  15, top: 5, bottom: 5),
          child: Container(   //cave name
            //height: 50,
            child: Text( file.path, style: Theme.of(context).textTheme.bodyText2),
          ),
        )
        
        : Padding(
          padding: EdgeInsets.only(left: 15.0, right:  15, top: 5, bottom: 5),
          child: Container(  //repo name
            //height: 50,
            child: Text( repo + " search results", style: Theme.of(context).textTheme.bodyText1), 
          ),
        ),
        
        Divider(indent: 10, endIndent: 10, height: 5,),

        ],
      );

  }
}