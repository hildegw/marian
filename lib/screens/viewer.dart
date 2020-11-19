import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu, size: 20, color: Theme.of(context).primaryColorDark,),
          onPressed: () => setState(() => openMenu = !openMenu ),
        ), 
      ),
      body: Stack(
        children: stackWidgets(),
      )
      
    );
  }
}




