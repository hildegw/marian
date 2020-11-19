
import "package:flutter/material.dart";

import '../utils/responsive.dart';


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
      color: Theme.of(context).dividerColor, 
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
                ? Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 20),
                  child: IconButton(
                    icon: Icon(Icons.add_circle_outline, size: 40, color: Theme.of(context).primaryColor,),
                    onPressed: () => setState(() => addLine = !addLine ),
                  ),
                )
                : Container(
                  height: 50,
                  child: Text(
                    "TEXT",
                    style: Theme.of(context).textTheme.headline2,
                    ),
                  ),
              Divider(),
            ],
          );
        }
      ),
    );

  }
}