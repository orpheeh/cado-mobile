import 'package:latlong/latlong.dart';

import 'dart:core';

class Project {
  String title;
  String description;
  int pid;
  List<LatLng> zone;
  List<GeographicPosition> geographicPositions;

  Project.fromJson(Map<String, dynamic> json) {
    this.title = json['project']['title'];
    this.description = json['project']['description'];
    this.pid = json['project']['pid'];

    zone = <LatLng>[];
    for (int i = 0; i < json['project']['zone'].length; i++) {
      var latlng = json['project']['zone'][i];
      zone.add(LatLng(latlng['lat'], latlng['lng']));
    }

    geographicPositions = <GeographicPosition>[];
    for (int i = 0; i < json['project']['markers'].length; i++) {
      var geoPos = GeographicPosition.fromJson(json['project']['markers'][i]);
      geographicPositions.add(geoPos);
    }
  }

  List<Map<String, dynamic>> zoneToJson(){
    final list = <Map<String, dynamic>>[];
    zone.forEach((latlng) => list.add({ "lat": latlng.latitude, "lng": latlng.longitude}));
    return list;
  }
}

class GeographicPosition {
  int id;
  LatLng position;
  String title;
  String details;
  bool isForDelete;

  GeographicPosition({this.id, this.position, this.title, this.details, this.isForDelete = true});

  GeographicPosition.fromJson(Map<String, dynamic> json){
    this.position = LatLng(json['lat'], json['lng']);
    this.title = json['title'];
    this.details = json['details'];
    this.isForDelete = false;
  }

  toJson() {
    Map<String, dynamic> json = <String, dynamic>{
      'lat' : position.latitude,
      'lng' : position.longitude,
      'title' : title,
      'details' : details,
      'isForDelete' : isForDelete == true ? 1 : 0
    };

    return json;
  }
}