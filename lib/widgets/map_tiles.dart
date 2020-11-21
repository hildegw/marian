import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_map/flutter_map.dart'; //https://github.com/fleaflet/flutter_map/tree/master/example/lib/pages
import 'package:flutter_map/plugin_api.dart';

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
  final double startZoom = 14.0;

  List <Polyline> lines = [];
  LatLng startLatLng;
  MapState map;
  LatLngBounds bounds;
  List<LatLng> tappedPoints = []; //for later use?
  MapController _mapController;

  @override
  void initState() {
    TmluData().loadFromGithub(context);
    //TmluData().loadTmlu(context);
    _mapController = MapController();
    super.initState();
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


