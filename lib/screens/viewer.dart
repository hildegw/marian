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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,),
        centerTitle: true,
        leading: Menu(), 
      ),
      body: Stack(
        children: <Widget>[
          MapTiles(),
        ]
      )
      
    );
  }
}




