import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

import '../utils/responsive.dart';
// import '../blocs/houses_bloc.dart';
// import '../models/house_model.dart';
import '../utils/mapbox_settings.dart';


class MapTiles extends StatefulWidget {


  @override
  _MapTilesState createState() => _MapTilesState();
}

class _MapTilesState extends State<MapTiles> {
  final _houseAddressKey = GlobalKey<FormState>();



  @override
  void initState() {
    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final Responsive _responsive = Responsive(context);
     

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
                      bounds: LatLngBounds(LatLng(20.19, -87.49), LatLng(20.2, -87.53)),
                      // center: LatLng(20.196525, -87.517539), //TODO get from tmlu
                      // zoom: 14.0
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

                    // PolylineLayerOptions(
                    //   polylines: [
                    //     Polyline(
                    //         points: points,
                    //         strokeWidth: 4.0,
                    //         color: Colors.purple),
                    //   ],
                    // ),

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

  }
}


