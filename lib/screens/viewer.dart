import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/tmlu_files_bloc.dart';
import '../widgets/map_tiles.dart';
import '../widgets/menu.dart';


class Viewer extends StatefulWidget {
  Viewer({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _ViewerState createState() => _ViewerState();
}

class _ViewerState extends State<Viewer> {

  bool openMenu = false;

  List <Widget> stackWidgets() {
     List <Widget>  stackList = [MapTiles()];
     if (openMenu) stackList.add(Menu());
     return stackList;
  }

  @override
  Widget build(BuildContext context) {
    
    return BlocBuilder<TmluFilesBloc, TmluFilesState>(builder: (context, state) {   

      return Scaffold(
        appBar: AppBar(       //TODO set file name in header
          title: state.files != null && state.files.length > 0 ? Text(state.files[0].filename) : Text(widget.title,),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(openMenu ? Icons.close : Icons.menu, size: 20, color: Theme.of(context).primaryColorDark,),
            onPressed: () => setState(() => openMenu = !openMenu ),
          ), 
        ),
        body: Stack(
          children: stackWidgets(),
        )
        
      );
    });
  }
}




