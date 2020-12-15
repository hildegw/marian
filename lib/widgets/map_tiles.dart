// import 'dart:html';
// import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_map/flutter_map.dart'; //https://github.com/fleaflet/flutter_map/tree/master/example/lib/pages
import 'package:flutter_map/plugin_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/model_segment.dart';
import '../utils/responsive.dart';
import '../blocs/tmlu_bloc.dart';
import '../models/model_segment.dart';
import '../utils/mapbox_settings.dart';
import '../utils/tmlu_data_api.dart';
import '../utils/validations.dart';
import '../utils/validations.dart';
import './zoom_buttons.dart';
import '../models/model_cave.dart';
import '../utils/validations.dart';


class MapTiles extends StatefulWidget {
  @override
  _MapTilesState createState() => _MapTilesState();
}

class _MapTilesState extends State<MapTiles> {
  final _mapKey = GlobalKey<FormState>();
  final double startIconSize = 15;
  final double startZoom = 18.0;
  final FormValidations validate = FormValidations();
  
  //List<ModelSegment> segments = [];
  List <Polyline> lines = [];
  LatLng startLatLng;
  MapState map;
  LatLngBounds bounds;
  List<LatLng> tappedPoints = []; //for later use?
  MapController _mapController;
  List<Marker> stationIds = [];
  List<Marker> sectionNameMarkers = [];

  @override
  void initState() { //TODO make cave to load selectable, set cave name globally
    //TmluData().loadTmlu(context);
    _mapController = MapController();
    super.initState();
  }

  void _handleTap(LatLng latlng) {
    //_mapController.move(LatLng(latlng.latitude, latlng.longitude), _mapController.zoom);
    //setState(() { tappedPoints.add(latlng); });
  }

  createStationIds(ModelCave cave) {
    stationIds = [];
    Marker stationId;
    cave.segments.forEach((seg) {
      stationId = Marker(
        point: seg.latlng,  //lines[1].points.first,
        builder: (context) => Container(
          child: Text(seg.id.toString(), style: Theme.of(context).textTheme.bodyText1,),
        )
      );
      stationIds.add(stationId);
    });
  }

  createSectionNames(ModelCave cave) {
    sectionNameMarkers = [];
    Marker nameMarker;
    List<String> sectionNames = [];
    String nextSectionName;
    cave.segments.forEach((seg) {
      nextSectionName = seg.sc;
      nameMarker = Marker(
        width: 150,//resp.wp(90),
        point: seg.latlng,  
        builder: (context) => Container(
          child: Text(
            seg.sc, 
            overflow: TextOverflow.visible, 
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.bodyText1,),
        )
      );
      if (!sectionNames.contains(nextSectionName)) {
        sectionNameMarkers.add(nameMarker);
        sectionNames.add(nextSectionName);
      }
    });
    print(sectionNames);
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final Responsive _responsive = Responsive(context);
    print("building map");
    return BlocBuilder<TmluBloc, TmluState>(builder: (context, state) {   

    if (state.status == TmluStatus.hasTmlu && state.cave.polylines != null && state.cave.startCoord != null) {
      state.cave.polylines.asMap().forEach((idx, lineSegment) {
        lines.add(    
          Polyline(
            points: lineSegment,
            strokeWidth: 1.5,
            color: validate.formatColor(state.cave.segments[idx].cl),
          ));
      });
      startLatLng = LatLng(state.cave.startCoord.latitude, state.cave.startCoord.longitude); //LatLng(20.196525, -87.517539)
      print("start $startLatLng");
      createStationIds(state.cave);
      createSectionNames(state.cave);
      if (_mapController.ready)  _mapController.move(LatLng(startLatLng.latitude, startLatLng.longitude), _mapController.zoom);
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
                  key: _mapKey,
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
                        polylineCulling: true,
                      ),

                    MarkerLayerOptions(markers: [
                      Marker(
                        width: startIconSize,
                        height: startIconSize,
                        point: startLatLng,
                        builder: (context) => Container(
                          child: Icon(Icons.radio_button_unchecked, size: startIconSize, color: Theme.of(context).primaryColor,),
                        )
                      ),

                    ...stationIds,
                    ...sectionNameMarkers,

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


