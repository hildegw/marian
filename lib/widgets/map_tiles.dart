// import 'dart:html';
// import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_map/flutter_map.dart'; //https://github.com/fleaflet/flutter_map/tree/master/example/lib/pages
import 'package:flutter_map/plugin_api.dart';

import '../utils/responsive.dart';
import '../blocs/tmlu_bloc.dart';
import '../utils/mapbox_settings.dart';
import '../utils/validations.dart';
import './zoom_buttons.dart';
import '../models/model_cave.dart';


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
  List<Marker> startMarkers = [];

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

  createLines(List<ModelCave> selectedCaves) {
    lines = [];
    selectedCaves.forEach((cave) { 
      if (cave.polylines != null && cave.startCoord != null) {
        cave.polylines.asMap().forEach((idx, lineSegment) {
          lines.add(    
            Polyline(
              points: lineSegment,
              strokeWidth: 1.5,
              color: validate.formatColor(cave.segments[idx].cl),
            ));
        });
      }
    });
  }

  createStationIds(List<ModelCave> selectedCaves) {
    stationIds = [];
    Marker stationId;
    selectedCaves.forEach((cave) {
      cave.segments.forEach((seg) {
        stationId = Marker(
          point: seg.latlng,  //lines[1].points.first,
          anchorPos: AnchorPos.align(AnchorAlign.right),
          builder: (context) => Container(
            child: Text(seg.id.toString(), style: Theme.of(context).textTheme.bodyText1,),
          )
        );
        stationIds.add(stationId);
      });
    });
  }

  createSectionNames(List<ModelCave> selectedCaves) {
    sectionNameMarkers = [];
    Marker nameMarker;
    List<String> sectionNames = [];
    String nextSectionName;
    selectedCaves.forEach((cave) {
      cave.segments.forEach((seg) {
        nextSectionName = seg.sc;
        nameMarker = Marker(
          width: 150,//resp.wp(90),
          point: seg.latlng,  
          anchorPos: AnchorPos.align(AnchorAlign.right),
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
    });
  }

  createStartMarkers(List<ModelCave> selectedCaves) {
    selectedCaves.forEach((cave) {
      if (cave.startCoord != null) {
        Marker startMarker =  Marker(
          width: startIconSize,
          height: startIconSize,
          point: LatLng(cave.startCoord.latitude, cave.startCoord.longitude),
          builder: (context) => Container(
            child: Icon(Icons.radio_button_unchecked, size: startIconSize, color: Theme.of(context).primaryColor,),
          )
        );
        startMarkers.add(startMarker);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final Responsive _responsive = Responsive(context);
    final tmluBloc = BlocProvider.of<TmluBloc>(context);

    print("building map");
    return BlocBuilder<TmluBloc, TmluState>(builder: (context, state) {   

    if (state.status == TmluStatus.hasTmlu) {
      createLines(state.selectedCaves);
      createStartMarkers(state.selectedCaves); //indicating cenote / start of line / from station -1
      createStationIds(state.selectedCaves);
      createSectionNames(state.selectedCaves);
      //go to first selected cave and center map
      startLatLng = LatLng(state.selectedCaves[0].startCoord.latitude, state.selectedCaves[0].startCoord.longitude); //LatLng(20.196525, -87.517539)
      if (_mapController.ready)  _mapController.move(LatLng(startLatLng.latitude, startLatLng.longitude), _mapController.zoom);
      print("start $startLatLng");
      //set initial view status once data is initialized
      tmluBloc.add(InitialViewDone());
   }
    print("viewer done $lines");

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

                    if (state.status == TmluStatus.initialViewDone )
                      PolylineLayerOptions(
                        polylines: lines,
                        polylineCulling: false,
                      ),

                    MarkerLayerOptions(markers: [
                    ...startMarkers,
                    if (state.showStationIds) ...stationIds,
                    if (state.showSegmentNames) ...sectionNameMarkers,

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


