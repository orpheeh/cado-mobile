import 'dart:async';

import 'package:cado/models/my_location.dart';
import 'package:cado/services/project.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

class MapWidget extends StatefulWidget {
  MapWidget({this.project, this.myLocation});

  Project project;
  MyLocation myLocation;

  @override
  State<StatefulWidget> createState() => MapWidgetState(project: project, myLocation: myLocation);
}

class MapWidgetState extends State<MapWidget> {
  MapWidgetState({this.project, this.myLocation}) {}

  Project project;
  MyLocation myLocation;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: project.zone.length > 0
            ? LatLng(project.zone[0].latitude, project.zone[0].longitude)
            : LatLng(51.1, -0.09),
        zoom: 19.0,
      ),
      layers: [
        TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c']),
        PolygonLayerOptions(
          polygons: [
            Polygon(
                points: project.zone,
                borderStrokeWidth: 5.0,
                color: Colors.transparent,
                borderColor: Colors.blue)
          ],
        ),
      ],
    );
  }
}
