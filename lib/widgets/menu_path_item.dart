
import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/responsive.dart';
import '../blocs/tmlu_bloc.dart';


class MenuPathItem extends StatefulWidget {
  final String path;
  final String title;
  final Function onSelected;
  final Function onDelete;
  MenuPathItem({ this.path, this.title, this.onSelected, this.onDelete });

  @override
  _MenuPathItemState createState() => _MenuPathItemState();
}

class _MenuPathItemState extends State<MenuPathItem> {
  bool selected = false;
  bool deleteItem = false;

  @override
  void initState() { 
    final tmluBloc = BlocProvider.of<TmluBloc>(context);
    selected = tmluBloc.state.cave.path == widget.path; //TODO for all selected caves
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