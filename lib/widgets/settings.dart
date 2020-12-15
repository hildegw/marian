
import "package:flutter/material.dart";
import 'package:marian/models/model_git_search_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marian/models/model_segment.dart';
import 'package:latlong/latlong.dart';

import '../utils/responsive.dart';
import '../blocs/tmlu_bloc.dart';
import '../utils/local_storage.dart';


class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final LocalStorage localStorage = LocalStorage();
  bool openSettings = false;




  @override
  Widget build(BuildContext context) {
    final Responsive resp = Responsive(context);


    return BlocBuilder<TmluBloc, TmluState>(builder: (context, state) {   


      return Positioned(
        right: 0,
        child: Container(
          width: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0)),
            border: Border.all(color: Colors.transparent),
            color: Theme.of(context).primaryColor,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor,
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(1, 1), 
              ),],
          ),
          child: Column(
            children: [
              SizedBox(height: 5),
              
              IconButton(
                padding: EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
                visualDensity: VisualDensity(horizontal: -4.0, vertical: -4.0), //remove more padding
                icon: Icon(openSettings ? Icons.settings_outlined : Icons.settings_outlined, size: 21, color: Theme.of(context).primaryColorDark,),
                onPressed: () { 
                  if (openSettings) Future.delayed(Duration(milliseconds: 500), () => setState(() => openSettings = false));
                  else setState(() { openSettings = true; });
                },
              ),

              SizedBox(height: 5),
            ],
          ), 
        ), 
      );
    });
  }
}