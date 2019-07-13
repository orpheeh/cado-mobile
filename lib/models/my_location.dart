
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

import 'dart:async';

import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';

class MyLocation {
  MyLocation({this.show = false});

  bool show;
  Geolocator geolocator = Geolocator();
  StreamSubscription myLocationStreamSubscription;
  Position myPosition;

  
  void startStreamMyLocation(){
    var locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);

    myLocationStreamSubscription = geolocator.getPositionStream(locationOptions).listen(
            (Position position) {
              myPosition = position;
          debugPrint(position == null ? 'Unknown' : position.latitude.toString() + ', ' + position.longitude.toString());
        });
  }
  
  void stopStreamMyLocation(){
    if(myLocationStreamSubscription != null){
      myLocationStreamSubscription.cancel();
    }
  }
}
