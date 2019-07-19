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

  Future<int> sendGeoPositionToServer() async {
    final persistance = Persistance();
    final database = await persistance.createDb();
    debugPrint("DELETE");
    persistance.insertGoePosition(GeographicPosition(
      title: titleController.text,
      details: detailsController.text,
      position: LatLng(currentPosition.latitude, currentPosition.longitude)
    ), database);
    return 200;
  }

  _form() {
    return ListView(
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(16.0),
          child: _waitingForServerResponse
              ? FutureBuilder(
                  future: requestFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      _waitingForServerResponse = false;
                      return Text(
                        'Position Enregistrer avec succès',
                        style: TextStyle(color: Colors.green), textAlign: TextAlign.center,
                      );
                    } else if (snapshot.hasError) {
                      _waitingForServerResponse = false;
                      return Text(
                        snapshot.error.toString(),
                        style: TextStyle(color: Colors.red),
                      );
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                )
              : Text(''),
        ),
        Container(
          margin: EdgeInsets.all(16.0),
          child: TextField(
            controller: titleController,
            decoration: InputDecoration(hintText: 'Titre'),
          ),
        ),
        Container(
          margin: EdgeInsets.all(16.0),
          child: TextField(
            controller: detailsController,
            decoration: InputDecoration(hintText: 'Details'),
          ),
        ),
        Container(
          margin: EdgeInsets.all(16.0),
          child: RaisedButton(
            onPressed: () {
              setState(() {
                _waitingForServerResponse = true;
                requestFuture = sendGeoPositionToServer();
              });
            },
            child: Text('Enregistrer'),
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
          ),
        )
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
          title: Text('Position Géographique'),
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
