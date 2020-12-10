import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/tmlu_files_bloc.dart';
import '../widgets/map_tiles.dart';
import '../widgets/filter_local_caves.dart';
import '../widgets/github_search.dart';
import '../blocs/tmlu_bloc.dart';


class Viewer extends StatefulWidget {
  Viewer({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _ViewerState createState() => _ViewerState();
}

class _ViewerState extends State<Viewer> {

  bool openFilter = false;
  bool openSearch = false;

  List <Widget> stackWidgets() {
     List <Widget>  stackList = [MapTiles()];
     if (openFilter) stackList.add(FilterLocalCaves());
     if (openSearch) stackList.add(GithubSearch());
     return stackList;
  }

  @override
  void initState() { 
    final tmluFilesBloc = BlocProvider.of<TmluFilesBloc>(context);
    tmluFilesBloc.add(LoadLocalCaves());  //fetch list of caves saved locally
    tmluFilesBloc.add(TmluFilesSelected(gitFilesSelected: []));
    //TODO open list of caves that were open during last session
    //if no tmlu available yet, open cave filter
    final tmluBloc = BlocProvider.of<TmluBloc>(context);
    if (tmluBloc.state.status == TmluStatus.loading) openFilter = true;
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    final tmluFilesBloc = BlocProvider.of<TmluFilesBloc>(context);

    return BlocBuilder<TmluBloc, TmluState>(builder: (context, state) {   

      return Scaffold(
        backgroundColor: Theme.of(context).primaryColorDark,
        appBar: AppBar( 
          titleSpacing: 0.0,
          toolbarHeight: 40,
          centerTitle: true,
          title: 
            //show filter or github search texts
            openSearch
            ? Text("search github for tmlu files", 
                style: Theme.of(context).textTheme.button, 
              ) 
            : openFilter
            ? Text("please select caves", 
                style: Theme.of(context).textTheme.button, 
              ) 
              
             //show either title or cave name when menues are closed 
            : state.cave != null 
            ? Text(state.cave.path, 
                  style: Theme.of(context).textTheme.button.copyWith(fontSize: 12.0), 
                  overflow: TextOverflow.visible,
                  softWrap: true,
                ) 
            : Text(widget.title,),
          leading: IconButton(
            padding: EdgeInsets.all(0.0),
            icon: Icon(openFilter ? Icons.done_all : Icons.filter_list, size: 25, color: Theme.of(context).primaryColorDark,),
            onPressed: () { 
              tmluFilesBloc.add(TmluLocalCaveSelectionDone()); //sets status to selectino done
              //delay menu closing, so that menu component can send off selected data to bloc
              if (openFilter) Future.delayed(Duration(milliseconds: 500), () => setState(() => openFilter = false));
                else setState(() { openSearch = false; openFilter = true; });
            },
          ), 

          actions: <Widget>[
            IconButton(
              padding: EdgeInsets.all(0.0),
              icon: Icon(openSearch ? Icons.done_all : Icons.search, size: 25, color: Theme.of(context).primaryColorDark,),
              onPressed: () { 
                tmluFilesBloc.add(TmluGithubSearchSelectionDone()); //sets status to selectino done
                if (openSearch) Future.delayed(Duration(milliseconds: 500), () => setState(() => openSearch = false));
                else setState(() { openSearch = true; openFilter = false; });
              },
            ), 

          ],


        ),
        body: SafeArea(
                  child: Stack(
            children: stackWidgets(),
          ),
        )
        
      );
    });
  }
}




