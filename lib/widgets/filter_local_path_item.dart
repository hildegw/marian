
import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/responsive.dart';
import '../blocs/tmlu_bloc.dart';
import '../models/model_cave.dart';

class FilterLocalPathItem extends StatefulWidget {
  final String path;
  final String title;
  final Function onSelected;
  final Function onDelete;
  FilterLocalPathItem({ this.path, this.title, this.onSelected, this.onDelete });

  @override
  _FilterLocalPathItemState createState() => _FilterLocalPathItemState();
}

class _FilterLocalPathItemState extends State<FilterLocalPathItem> {
  bool selected = false;
  bool deleteItem = false;

  @override
  void initState() { 
    final tmluBloc = BlocProvider.of<TmluBloc>(context);
    if (tmluBloc.state.selectedCaves != null && tmluBloc.state.selectedCaves.length > 0) {
      ModelCave selectedCave = tmluBloc.state.selectedCaves.firstWhere((cave) => cave.path == widget.path, orElse: () => null);
      selected = selectedCave != null ? true : false;
    } 
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Responsive resp = Responsive(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: widget.title == null ? CrossAxisAlignment.start : CrossAxisAlignment.center,        
      children: [
        widget.title == null
        ? Padding(
          padding: EdgeInsets.only(left: 10.0, right:  15, top: 0, bottom: 0),
          child: Row(
            children: [
              Container(
                width: 25,
                child: FlatButton(
                  padding: EdgeInsets.all(0.0),
                  onPressed: () {
                    setState(() { 
                      selected = !selected;
                      deleteItem = false;
                    } );
                    widget.onSelected(selected);
                  },
                  child: Icon(
                    selected ? Icons.check_box : Icons.check_box_outline_blank, 
                    size: 20, color: Theme.of(context).dividerColor),
                ),
              ),
              SizedBox(width: 3,),
              Container(
                width: 25,
                child: FlatButton(
                  padding: EdgeInsets.all(0.0),
                  onPressed: () {
                    setState(() { 
                      selected = false;
                      deleteItem = !deleteItem;
                    } );
                    widget.onDelete(deleteItem);
                  },
                  child: Icon(
                    deleteItem ? Icons.delete_sharp : Icons.delete_outline, 
                    size: 23, color: Theme.of(context).dividerColor),
                ),
              ),
              SizedBox(width: 10,),
              Expanded(   //cave name
                child: Text(widget.path, overflow: TextOverflow.visible , style: Theme.of(context).textTheme.bodyText2),
              ),
            ],
          ),
        )
        
        : Padding(
          padding: EdgeInsets.only(left: 10.0, right:  15, top: 5, bottom: 5),
          child: Container(  //repo name
            child: Text( widget.title , style: Theme.of(context).textTheme.bodyText1), 
          ),
        ),
        
        Divider(indent: 10, endIndent: 10, height: 5,),

        ],
      );

  }
}