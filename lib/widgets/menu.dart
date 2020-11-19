
import "package:flutter/material.dart";

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            IconButton(
              Icons.menu, color: Theme.of(context).primaryColorDark,
            ),
            //our code.
            SizedBox(height: 600)
          ],
        ),
    );
  }
}