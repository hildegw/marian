
import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marian/models/model_git_search_response.dart';

import '../blocs/tmlu_files_bloc.dart';
import '../utils/responsive.dart';
import '../models/model_git_search_response.dart';


class MenuCaveItem extends StatelessWidget {
  final ModelGitFile file;
  MenuCaveItem({ this.file });


  @override
  Widget build(BuildContext context) {
    final Responsive resp = Responsive(context);

      return Container(
                    height: 50,
                    child: Text(
                      file.filename + " " + file.path,
                      style: Theme.of(context).textTheme.bodyText2,
                      ),
                    );

  }
}