import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart';

class ZoomButtonsPluginOption extends LayerOptions {
  final int minZoom;
  final int maxZoom;
  final bool mini;
  final double padding;
  final Alignment alignment;
  final Color zoomInColor;
  final Color zoomOutColor;
  final IconData zoomInIcon;
  final IconData zoomOutIcon;
  final IconData resetIcon;
  final double startZoom;
  final LatLng startLatLng;

  ZoomButtonsPluginOption({
    Key key,
    this.minZoom = 1,
    this.maxZoom = 19,
    this.mini = true,
    this.padding = 10.0,
    this.alignment = Alignment.bottomRight,
    this.zoomInColor,
    this.zoomInIcon = Icons.zoom_in,
    this.zoomOutColor,
    this.zoomOutIcon = Icons.zoom_out,
    this.resetIcon = Icons.center_focus_weak,  
    this.startZoom,
    this.startLatLng,
    rebuild,
  }) : super(key: key, rebuild: rebuild);
}

class ZoomButtonsPlugin implements MapPlugin {
  @override
  Widget createLayer(
      LayerOptions options, MapState mapState, Stream<Null> stream) {
    if (options is ZoomButtonsPluginOption) {
      return ZoomButtons(options, mapState, stream);
    }
    throw Exception('Unknown options type for ZoomButtonsPlugin: $options');
  }

  @override
  bool supportsLayer(LayerOptions options) {
    return options is ZoomButtonsPluginOption;
  }
}

class ZoomButtons extends StatelessWidget {
  final ZoomButtonsPluginOption zoomButtonsOpts;
  final MapState map;
  final Stream<Null> stream;
  final FitBoundsOptions options = const FitBoundsOptions(padding: EdgeInsets.all(12.0));

  ZoomButtons(this.zoomButtonsOpts, this.map, this.stream)
      : super(key: zoomButtonsOpts.key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: zoomButtonsOpts.alignment,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
                left: zoomButtonsOpts.padding,
                top: zoomButtonsOpts.padding,
                right: zoomButtonsOpts.padding),
            child: FloatingActionButton(
              heroTag: 'zoomInButton',
              mini: zoomButtonsOpts.mini,
              backgroundColor:
                  zoomButtonsOpts.zoomInColor ?? Theme.of(context).primaryColor,
              onPressed: () {
                var bounds = map.getBounds();
                var centerZoom = map.getBoundsCenterZoom(bounds, options);
                var zoom = centerZoom.zoom + 0.5;
                if (zoom < zoomButtonsOpts.minZoom) {
                  zoom = zoomButtonsOpts.minZoom as double;
                } else {
                  map.move(centerZoom.center, zoom);
                }
              },
              child: Icon(zoomButtonsOpts.zoomInIcon),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(zoomButtonsOpts.padding),
            child: FloatingActionButton(
              heroTag: 'zoomOutButton',
              mini: zoomButtonsOpts.mini,
              backgroundColor: zoomButtonsOpts.zoomOutColor ??
                  Theme.of(context).primaryColor,
              onPressed: () {
                var bounds = map.getBounds();
                var centerZoom = map.getBoundsCenterZoom(bounds, options);
                var zoom = centerZoom.zoom - 0.5;
                if (zoom > zoomButtonsOpts.maxZoom) {
                  zoom = zoomButtonsOpts.maxZoom as double;
                } else {
                  map.move(centerZoom.center, zoom);
                }
              },
              child: Icon(zoomButtonsOpts.zoomOutIcon),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(zoomButtonsOpts.padding),
            child: FloatingActionButton(
              heroTag: 'centerButton',
              mini: zoomButtonsOpts.mini,
              backgroundColor: zoomButtonsOpts.zoomOutColor ?? Theme.of(context).primaryColor,
              onPressed: () {
                double zoom = zoomButtonsOpts.startZoom ?? 14.0;
                map.move(zoomButtonsOpts.startLatLng, zoom);
              },
              child: Icon(zoomButtonsOpts.resetIcon),
            ),
          )
        ],
      ),
    );
  }
}