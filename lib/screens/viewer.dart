import 'package:flutter/material.dart';
import '../widgets/tmlu_view.dart';
import '../widgets/map_tiles.dart';


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
      appBar: AppBar(title: Text(widget.title,)),
      body: Stack(
        children: <Widget>[
          //MapTiles(),
          TmluView(),
        ]
      )
      
    );
  }
}

//TODO Canvas controller to move and resize cave
//https://blog.codemagic.io/multi-touch-canvas-with-flutter/
//https://github.com/rodydavis/flutter_multi_touch_canvas

//MobX https://circleci.com/blog/state-management-for-flutter-apps-with-mobx/
