import 'package:latlong/latlong.dart';

class Map {
  Map({this.showUsertLocation = false, this.zonePoints = const <LatLng>[]});

  bool showUsertLocation;
  List<LatLng> zonePoints;
  LatLng center;
  var userLocation;
}
