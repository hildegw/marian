import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/tmlu_files_bloc.dart';
import '../utils/local_storage.dart';
import '../widgets/map_tiles.dart';
import '../widgets/filter_local_caves.dart';
import '../widgets/github_search.dart';
import '../blocs/tmlu_bloc.dart';
import '../widgets/settings.dart';


class Viewer extends StatefulWidget {
  Viewer({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _ViewerState createState() => _ViewerState();
}

class _ViewerState extends State<Viewer> {
  final LocalStorage localStorage = LocalStorage();
  bool openFilter = false;
  bool openSearch = false;
  bool openSettings = false;

  List <Widget> stackWidgets() {
     List <Widget>  stackList = [MapTiles()];
     if (openFilter) stackList.add(FilterLocalCaves());
     if (openSearch) stackList.add(GithubSearch());
     if (openSettings) stackList.add(Settings());
     return stackList;
  }

  @override
  void initState() { 
    final tmluFilesBloc = BlocProvider.of<TmluFilesBloc>(context);
    tmluFilesBloc.add(LoadLocalCaves());  //fetch list of caves saved locally
    tmluFilesBloc.add(TmluFilesSelected(gitFilesSelected: []));
    //TODO open list of caves that were open during last session
    //check if local list exists and open either github or filter menu
    List<String> cavePaths;
    WidgetsBinding.instance.addPostFrameCallback((_) async {  
      cavePaths = await localStorage.getCavePaths();  
      if (cavePaths != null && cavePaths.length > 0) 
        setState(() => openFilter = true);
      else setState(() => openSearch = true);
    });
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    final tmluFilesBloc = BlocProvider.of<TmluFilesBloc>(context);

    return BlocBuilder<TmluBloc, TmluState>(builder: (context, state) {   

      return Scaffold(
        backgroundColor: Theme.of(context).primaryColorDark,
        appBar: AppBar( 
          titleSpacing: 20.0,
          toolbarHeight: 40,
          centerTitle: false,
          elevation: 0,
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
                  style: Theme.of(context).textTheme.button.copyWith(fontSize: 13.0), 
                  overflow: TextOverflow.visible,
                  softWrap: true,
                ) 
            : Text(widget.title,),

          actions: <Widget>[

            Padding(
              padding: EdgeInsets.only(left: 0.0, right: 1.0, top: 1.0, bottom: 4.0),
              child: Container(
                width: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.transparent),
                  color: openFilter ? Theme.of(context).buttonColor : Colors.transparent,
                  boxShadow: [
                    BoxShadow(
                      color: openFilter ? Theme.of(context).shadowColor : Colors.transparent,
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: Offset(1, 1), 
                    ),],
                ),
                child: IconButton(
                  padding: EdgeInsets.all(0.0),
                  visualDensity: VisualDensity(horizontal: -4.0, vertical: -4.0), //remove more padding
                  icon: Icon(openFilter ? Icons.done_all : Icons.filter_list, size: 23, color: Theme.of(context).primaryColorDark,),
                  onPressed: () { 
                    tmluFilesBloc.add(TmluLocalCaveSelectionDone()); //sets status to selectino done
                    //delay menu closing, so that menu component can send off selected data to bloc
                    if (openFilter) Future.delayed(Duration(milliseconds: 500), () => setState(() => openFilter = false));
                      else setState(() { openSearch = false; openFilter = true; });
                  },
                ), 
              ),
            ), 


            Padding(
              padding: EdgeInsets.only(left: 1.0, right: 1.0, top: 1.0, bottom: 4.0),
              child: Container(
                width: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.transparent),
                  color: openSearch ? Theme.of(context).buttonColor : Colors.transparent,
                  boxShadow: [
                    BoxShadow(
                      color: openSearch ? Theme.of(context).shadowColor : Colors.transparent,
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: Offset(1, 1), 
                    ),],
                ),
                child: IconButton(
                  padding: EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
                  visualDensity: VisualDensity(horizontal: -4.0, vertical: -4.0), //remove more padding
                  icon: Icon(
                    openSearch ? Icons.done_all : Icons.search, 
                    size: 22, 
                    color: Theme.of(context).primaryColorDark,),
                  onPressed: () { 
                    tmluFilesBloc.add(TmluGithubSearchSelectionDone()); //sets status to selectino done
                    if (openSearch) Future.delayed(Duration(milliseconds: 500), () => setState(() => openSearch = false));
                    else setState(() { openSearch = true; openFilter = false; });
                  },
                ),
              ),
            ), 

            Padding(
              padding: EdgeInsets.only(left: 1.0, right: 4.0, top: 1.0, bottom: 4.0),
              child: Container(
                width: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.transparent),
                  color: openSettings ? Theme.of(context).buttonColor : Colors.transparent,
                  boxShadow: [
                    BoxShadow(
                      color: openSettings ? Theme.of(context).shadowColor : Colors.transparent,
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: Offset(1, 1), 
                    ),],
                ),
                child: IconButton(
                  padding: EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
                  visualDensity: VisualDensity(horizontal: -4.0, vertical: -4.0), //remove more padding
                  icon: Icon(openSettings ? Icons.settings_outlined : Icons.settings_outlined, size: 21, color: Theme.of(context).primaryColorDark,),
                  onPressed: () { 
                    tmluFilesBloc.add(TmluGithubSearchSelectionDone()); //sets status to selectino done
                    if (openSettings) Future.delayed(Duration(milliseconds: 500), () => setState(() => openSettings = false));
                    else setState(() { openSettings = true; });
                  },
                ), 
              ),
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




