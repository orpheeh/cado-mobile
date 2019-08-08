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
  State<StatefulWidget> createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {
  String markerTitle;
  String markerDetails;
  bool showMarkerInformations = false;

  _loadAllMarkers() {
    List<Marker> markers = <Marker>[];
    if (widget.myLocation.show && widget.myLocation.myPosition != null) {
      markers.add(Marker(
          point: LatLng(widget.myLocation.myPosition.latitude,
              widget.myLocation.myPosition.longitude),
          width: 80.0,
          height: 80.0,
          builder: (context) => Container(
                child: Icon(
                  Icons.location_on,
                  color: Colors.purple,
                  size: 40.0,
                ),
              )));
    }
    widget.project.geographicPositions.forEach((geoPos) {
      debugPrint("${geoPos.position.latitude}, ${geoPos.position.longitude} ");
      markers.add(Marker(
          point: LatLng(geoPos.position.latitude, geoPos.position.longitude),
          width: 80.0,
          height: 80.0,
          builder: (context) => GestureDetector(
              onTap: () {
                //Show mark information
                setState(() {
                  showMarkerInformations = true;
                  markerTitle = geoPos.title;
                  markerDetails = geoPos.details;
                });
              },
              child: Container(
                child: Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40.0,
                ),
              ))));
    });
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      FlutterMap(
        options: MapOptions(
            center: widget.project.zone.length > 0
                ? LatLng(widget.project.zone[0].latitude,
                    widget.project.zone[0].longitude)
                : LatLng(51.1, -0.09),
            zoom: 15.0,
            maxZoom: 19.0,
            minZoom: 10.0),
        layers: [
          TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c']),
          MarkerLayerOptions(markers: _loadAllMarkers())
        ],
      ),
      showMarkerInformations
          ? Container(
              padding: EdgeInsets.all(16.0),
              margin: EdgeInsets.all(32.0),
              decoration: BoxDecoration(color: Colors.white),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      markerTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),
                  ),
                  Container(
                    child: Text(
                      markerDetails,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    margin: EdgeInsets.all(4.0),
                    child: FlatButton(
                      onPressed: () {
                        setState(() {
                          showMarkerInformations = false;
                          markerTitle = "";
                          markerDetails = "";
                        });
                      },
                      child: Text("Fermer"),
                      textColor: Theme.of(context).primaryColor,
                    ),
                  )
                ],
              ))
          : Container(),
    ]);
  }
}
