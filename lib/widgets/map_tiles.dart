import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

import '../utils/responsive.dart';
import '../blocs/tmlu_bloc.dart';
import '../models/model_segment.dart';
import '../utils/mapbox_settings.dart';
import '../utils/tmlu_data.dart';


class MapTiles extends StatefulWidget {


  @override
  _MapTilesState createState() => _MapTilesState();
}

class _MapTilesState extends State<MapTiles> {
  final _houseAddressKey = GlobalKey<FormState>();

  List <Polyline> lines = [];


  @override
  void initState() {
    TmluData().loadTmlu(context);
    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final Responsive _responsive = Responsive(context);
    //final tmluBloc = BlocProvider.of<TmluBloc>(context);

    return BlocBuilder<TmluBloc, TmluState>(builder: (context, state) {   
    
    if (state.status == TmluStatus.hasTmlu) {
      state.polylines.forEach((lineSegment) {
        lines.add(    
          Polyline(
            points: lineSegment,
            strokeWidth: 1.0,
            color: Colors.white
          ));
      });
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
                child: FlutterMap(
                  key: _houseAddressKey,
                  options:  MapOptions(
                    //bounds: LatLngBounds(LatLng(20.19, -87.49), LatLng(20.2, -87.53)),
                    center: LatLng(20.196525, -87.517539), //TODO get from tmlu
                    zoom: 16.0
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
                        width: 45.0,
                        height: 45.0,
                        point: LatLng(20.196525, -87.517539),
                        builder: (context) => Container(
                          child: Icon(Icons.location_on, size: 45, color: Theme.of(context).errorColor,),
                        )
                      )
                    ])
                  ]),
                ),

              ],
            ),
          ),
        ),
      ],);
    });
  }

}


