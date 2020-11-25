
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
        crossAxisAlignment: CrossAxisAlignment.start,        
        children: [
          Container(
            //height: 50,
            child: 
            Text(
              repo ?? file.path,
              style: Theme.of(context).textTheme.bodyText2,
              ),
          ),
        
        Divider(indent: 10, endIndent: 10, height: 5,),

        ],
      );

  }
}