import 'package:latlong/latlong.dart';

import 'dart:core';

class Project {
  String title;
  String description;
  int pid;
  List<LatLng> zone;

  Project.fromJson(Map<String, dynamic> json) {
    this.title = json['project']['title'];
    this.description = json['project']['description'];
    this.pid = json['project']['pid'];

    zone = <LatLng>[];
    for (int i = 0; i < json['project']['zone'].length; i++) {
      var latlng = json['project']['zone'][i];
      zone.add(LatLng(latlng['lat'], latlng['lng']));
    }
  }
}