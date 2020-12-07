
import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marian/models/model_git_search_response.dart';

import '../blocs/tmlu_files_bloc.dart';
import '../utils/responsive.dart';
import '../models/model_git_search_response.dart';

//github path and cave info returned from search

class MenuCaveItem extends StatefulWidget {
  final ModelGitFile file;
  final String repo;
  final Function onSelected;
  MenuCaveItem({ this.file, this.repo, this.onSelected });

  @override
  _MenuCaveItemState createState() => _MenuCaveItemState();
}

class _MenuCaveItemState extends State<MenuCaveItem> {
  bool selected = false;


  @override
  Widget build(BuildContext context) {
    final Responsive resp = Responsive(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: widget.repo == null ? CrossAxisAlignment.start : CrossAxisAlignment.center,        
      children: [
        widget.repo == null
        ? Padding(
          padding: EdgeInsets.only(left: 10.0, right:  15, top: 0, bottom: 0),
          child: Row(
            children: [
              Container(
                width: 25,
                child: FlatButton(
                  padding: EdgeInsets.all(0.0),
                  onPressed: () {
                    setState(() => selected = !selected );
                    widget.onSelected(selected);
                  },
                  child: Icon(
                    selected ? Icons.save_alt_rounded : Icons.check_box_outline_blank, 
                    size: 20, color: Theme.of(context).dividerColor),
                ),
              ),
              SizedBox(width: 10,),
              Expanded(   //cave name
                child: Text(widget.file.path, overflow: TextOverflow.visible , style: Theme.of(context).textTheme.bodyText2),
              ),
            ],
          ),
        )
        
        : Padding(
          padding: EdgeInsets.only(left: 10.0, right:  15, top: 5, bottom: 5),
          child: Container(  //repo name
            child: Text( widget.repo + " search results", style: Theme.of(context).textTheme.bodyText1), 
          ),
        ),
        
        Divider(indent: 10, endIndent: 10, height: 5,),

        ],
      );

  }
}