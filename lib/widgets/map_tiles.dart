import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_map/flutter_map.dart'; //https://github.com/fleaflet/flutter_map/tree/master/example/lib/pages
import 'package:flutter_map/plugin_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../utils/responsive.dart';
import '../blocs/tmlu_bloc.dart';
import '../models/model_segment.dart';
import '../utils/mapbox_settings.dart';
import '../utils/tmlu_data.dart';
import './zoom_buttons.dart';


class MapTiles extends StatefulWidget {
  @override
  _MapTilesState createState() => _MapTilesState();
}

class _MapTilesState extends State<MapTiles> {
  final _houseAddressKey = GlobalKey<FormState>();
  final double startIconSize = 15;
  final double startZoom = 18.0;
  
  List<ModelSegment> segments = [];
  String caveName = "test"; //TODO set cave name
  List <Polyline> lines = [];
  LatLng startLatLng;
  MapState map;
  LatLngBounds bounds;
  List<LatLng> tappedPoints = []; //for later use?
  MapController _mapController;

  @override
  void initState() { //TODO make cave to load selectable, set cave name globally
    getSavedSegments(caveName); //check if data is available in storage, if not, load from github
    if (segments == null || segments.length < 1) {
      TmluData().loadFromGithub(context);
      saveSegments(caveName);
    }
    //TmluData().loadTmlu(context);
    _mapController = MapController();
    super.initState();
  }


  saveSegments(String caveName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonList;
    segments.forEach((seg) => jsonList.add(jsonEncode(seg)) );
    await prefs.setStringList(caveName, jsonList); //TODO seg Json parse instead to read data
  }

  getSavedSegments(String caveName) async {
    segments = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> jsonList = prefs.getStringList(caveName); 
      if (jsonList != null) {
        jsonList.forEach((seg) {
          Map segString = jsonDecode(seg);
          segments.add(ModelSegment.fromJson(segString));
        });
      }
      else segments = null;
    } catch(err) { print("error fetching cave from storage: $err");}
  }



  void _handleTap(LatLng latlng) {
    //_mapController.move(LatLng(latlng.latitude, latlng.longitude), _mapController.zoom);
    //setState(() { tappedPoints.add(latlng); });
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final Responsive _responsive = Responsive(context);
    
    return BlocBuilder<TmluBloc, TmluState>(builder: (context, state) {   
    
    if (state.status == TmluStatus.hasTmlu && state.polylines != null && state.startCoord != null) {
      state.polylines.forEach((lineSegment) {
        lines.add(    
          Polyline(
            points: lineSegment,
            strokeWidth: 1.0,
            color: Colors.white
          ));
      });
      startLatLng = LatLng(state.startCoord.latitude, state.startCoord.longitude); //LatLng(20.196525, -87.517539)
    }


    return Stack(
        children: <Widget>[
    
          Positioned(
            bottom: 0,
            child: Container(
              height: _responsive.hp(100) - _responsive.safeAreaTop,
              width: _responsive.wp(100),                
              child: Column(
                children: <Widget>[

//map
              Container(
                width: _responsive.wp(100),
                height: _responsive.hp(100) - _responsive.safeAreaBottom,              
                child: startLatLng != null 
                ? FlutterMap(
                  mapController: _mapController,
                  key: _houseAddressKey,
                  options:  MapOptions(
                    //bounds: state.bounds,
                    center: startLatLng,
                    zoom: startZoom,
                    plugins: [ZoomButtonsPlugin(),],
                    //onTap: _handleTap,
                  ),
                  layers: [
                    TileLayerOptions(
                      urlTemplate: MapboxSettings.TILE_STYLE + "/{z}/{x}/{y}@2x?access_token=" + MapboxSettings.ACCESS_TOKEN,
                      additionalOptions: {
                        'accessToken': MapboxSettings.ACCESS_TOKEN,
                        'id': MapboxSettings.MAPBOX_ID,
                      },
                      errorTileCallback: (Tile tile, error) {
                        print('loading err $error');
                      },                
                    ),

                    if (state.status == TmluStatus.hasTmlu)
                      PolylineLayerOptions(
                        polylines: lines,
                      ),

                    MarkerLayerOptions(markers: [
                      Marker(
                        width: startIconSize,
                        height: startIconSize,
                        point: startLatLng,
                        builder: (context) => Container(
                          child: Icon(Icons.radio_button_unchecked, size: startIconSize, color: Theme.of(context).primaryColor,),
                        )
                      )
                    ]),

                    ZoomButtonsPluginOption(startLatLng: startLatLng, startZoom: startZoom),


                  ]) : Container(),
                ),

              ],
            ),
          ),
        ),
      ],);
    });
  }

}


