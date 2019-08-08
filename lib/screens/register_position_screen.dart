import 'package:cado/services/persistance.dart';
import 'package:cado/services/project.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';

class RegisterPositionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RegisterPositionPageState();
}

class RegisterPositionPageState extends State<RegisterPositionPage> {
  Future<Position> positionFuture;
  Future<int> requestFuture;

  Position currentPosition;
  bool _waitingForServerResponse = false;
  TextEditingController titleController = TextEditingController();
  TextEditingController detailsController = TextEditingController();

  Future<Position> _loadCurrentPosition() async {
    var position = await Geolocator().getCurrentPosition();
    currentPosition = position;
    return position;
  }

  /*Future<int> sendGeoPositionToServer() async {
    final persistance = Persistance();
    final database = await persistance.createDb();
    persistance.insertGoePosition(GeographicPosition(
      title: titleController.text,
      details: detailsController.text,
      position: LatLng(currentPosition.latitude, currentPosition.longitude)
    ), database);
    return 200;
  }*/

  _form() {
    return ListView(
      children: <Widget>[
        RaisedButton(
          onPressed: (){},
          child: Text("Collecter les déchets"),
          padding: EdgeInsets.all(16.0),
          color: Colors.green,
          textColor: Colors.white,
        ),

        RaisedButton(
          onPressed: (){},
          child: Text("Déployer les dispositifs"),
        ),

        RaisedButton(
          onPressed: (){},
          child: Text("Point d'accumulation des déchets"),
        ),
      ],
    );
  }

  @override
  void initState() {
    positionFuture = _loadCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Opérations'),
        ),
        body: FutureBuilder(
            future: positionFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                //Build form
                return _form();
              } else if (snapshot.hasError) {
                //Show error message
                return Text(snapshot.error.toString());
              }
              return Center(child: CircularProgressIndicator());
            }));
  }
}
