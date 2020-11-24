
import "package:flutter/material.dart";

import '../utils/responsive.dart';
import './menu_search.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  bool addLine = false;


  @override
  Widget build(BuildContext context) {
    final Responsive resp = Responsive(context);

    return Container(
      color: Theme.of(context).backgroundColor, 
      //height: resp.hp(80), 
      width: resp.wp(100),
      child: ListView.builder(
        itemCount: 6,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              index == 0 
                ? MenuSearch()
                : Container(
                  height: 50,
                  child: Text(
                    "TEXT",
                    style: Theme.of(context).textTheme.headline2,
                    ),
                  ),
              Divider(indent: 10, endIndent: 10, height: 5,),
            ],
          );
        }
      ),
    );

  }
}