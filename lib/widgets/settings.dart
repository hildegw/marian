
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
  bool showSegmentNames = false;
  bool showStationIds = false;



  @override
  Widget build(BuildContext context) {
    final Responsive resp = Responsive(context);
    final tmluBloc = BlocProvider.of<TmluBloc>(context);


    return BlocBuilder<TmluBloc, TmluState>(builder: (context, state) {   


      return Positioned(
        right: 0,
        child: Container(
          width: 45,
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
              
              Padding(
                padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 1.0, bottom: 5.0),
                child: Container(
                  width: 34,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.transparent),
                    color: showStationIds ? Theme.of(context).buttonColor : Colors.transparent,
                    boxShadow: [
                      BoxShadow(
                        color: showStationIds ? Theme.of(context).shadowColor : Colors.transparent,
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(1, 1), 
                      ),],
                  ),
                  child: IconButton(
                    padding: EdgeInsets.all(0.0),
                    visualDensity: VisualDensity(horizontal: -4.0, vertical: -4.0), //remove more padding
                    icon: Icon(showStationIds ? Icons.pin_drop_rounded : Icons.pin_drop_outlined, size: 23, color: Theme.of(context).primaryColorDark,),
                    onPressed: () { 
                      if (showStationIds) setState(() => showStationIds = false);
                      else setState(() { showStationIds = true; }); 
                      tmluBloc.add(SettingsSelected(showSegmentNames: showSegmentNames, showStationIds: showStationIds)); 
                    },
                  ), 
                ),
              ), 

              Padding(
                padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0, bottom: 4.0),
                child: Container(
                  width: 34,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.transparent),
                    color: showSegmentNames ? Theme.of(context).buttonColor : Colors.transparent,
                    boxShadow: [
                      BoxShadow(
                        color: showSegmentNames ? Theme.of(context).shadowColor : Colors.transparent,
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(1, 1), 
                      ),],
                  ),
                  child: IconButton(
                    padding: EdgeInsets.all(0.0),
                    visualDensity: VisualDensity(horizontal: -4.0, vertical: -4.0), //remove more padding
                    icon: Icon(showSegmentNames ? Icons.label : Icons.label_outline, size: 23, color: Theme.of(context).primaryColorDark,),
                    onPressed: () { 
                      if (showSegmentNames) setState(() => showSegmentNames = false);
                      else setState(() { showSegmentNames = true; }); 
                      tmluBloc.add(SettingsSelected(showSegmentNames: showSegmentNames, showStationIds: showStationIds)); 
                    },
                  ), 
                ),
              ), 

              SizedBox(height: 5),
            ],
          ), 
        ), 
      );
    });
  }
}