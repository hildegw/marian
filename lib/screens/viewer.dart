import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/tmlu_files_bloc.dart';
import '../widgets/map_tiles.dart';
import '../widgets/menu.dart';
import '../blocs/tmlu_bloc.dart';


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
  void initState() { 
    final tmluFilesBloc = BlocProvider.of<TmluFilesBloc>(context);
    tmluFilesBloc.add(LoadLocalCaves());  //fetch list of caves saved locally
    tmluFilesBloc.add(TmluFilesSelected(filesSelected: []));
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    final tmluFilesBloc = BlocProvider.of<TmluFilesBloc>(context);

    return BlocBuilder<TmluFilesBloc, TmluFilesState>(builder: (context, state) {   

      return Scaffold(
        appBar: AppBar(       //TODO set file name in header
          title: state.files != null && state.files.length > 0 ? Text(state.files[0].filename) : Text(widget.title,),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(openMenu ? Icons.done_all : Icons.menu, size: 20, color: Theme.of(context).primaryColorDark,),
            onPressed: () { 
              tmluFilesBloc.add(TmluSelectionDone(selectionDone: openMenu)); //not really needed
              //delay menu closing, so that menu comkponent can send off selected data to bloc
              if (openMenu) Future.delayed(Duration(milliseconds: 500), () => setState(() => openMenu = false));
              else setState(() => openMenu = true);
            },
          ), 
        ),
        body: Stack(
          children: stackWidgets(),
        )
        
      );
    });
  }
}




