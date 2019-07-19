import 'dart:convert';

import 'package:cado/models/my_location.dart';
import 'package:cado/screens/register_position_screen.dart';
import 'package:cado/services/persistance.dart';
import 'package:cado/services/project.dart';
import 'package:cado/services/sign.dart';
import 'package:cado/widgets/map_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqlite_api.dart';

import 'home_screen.dart';

enum PopupMenuItemActions { LOGOUT }

class MapPage extends StatefulWidget {
  MapPage({this.pid, this.mid, this.url, this.project = null});

  Project project;
  int pid;
  int mid;
  String url;

  @override
  State<StatefulWidget> createState() =>
      MapPageState(project: project, pid: pid, mid: mid, cadoUrl: url);
}

class MapPageState extends State<MapPage> {
  MapPageState({this.project, this.pid, this.mid, this.cadoUrl}) {
    loadProject = false;
    _myLocation = MyLocation();
    if (project == null) {
      loadProject = true;
    } else {
      _mapWidget = MapWidget(
        project: project,
        myLocation: _myLocation,
      );
    }
  }

  Project project;
  int pid;
  int mid;
  String cadoUrl;
  Future<Project> projectFuture;
  bool loadProject;
  MapWidget _mapWidget;
  MyLocation _myLocation;

  _onPopupMenuItemSelected(PopupMenuItemActions actions) async {
    if (actions == PopupMenuItemActions.LOGOUT) {
      SharedPreferences sp = await SharedPreferences.getInstance();
      sp.remove('projectId');
      sp.remove('mobileId');
      sp.remove('cadoURL');
      await deleteSavedDatabase();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (ctx) => HomePage()));
    }
  }

  _onAppBarLocationIconTap() {
    setState(() {
      _myLocation.show = !_myLocation.show;
      if (_myLocation.show) {
        _myLocation.startStreamMyLocation();
      } else {
        _myLocation.stopStreamMyLocation();
      }
    });
  }

  Future<void> deleteSavedDatabase() async{
    final persistance = Persistance();
    final database = await persistance.createDb();

    await persistance.deleteZone(database);
    await persistance.deleteAllGeoPosition(database);
  }

  Future<int> sendGeoPositionToServer(List<GeographicPosition> list, Database database) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String url = sp.getString("cadoURL");
    int projectId = sp.getInt("projectId");
    int mobileId = sp.getInt("mobileId");

    Map<String, String> header = <String, String>{
      "content-type": "application/json",
      "authorization": "Access mobileBearer 1"
    };
    Map<String, dynamic> b = {
      "pid": projectId,
      "mid": mobileId,
      "marker": list
    };
    var response = await http.post(url + "/api/mobile/marker",
        headers: header, body: jsonEncode(b));
    if (response.statusCode == 200) {
      list.forEach((gp) => Persistance().deleteGeoPosition(gp.id, database));
      return 200;
    } else {
      throw Exception("Failed to send current position at $url $projectId");
    }
  }

  _sendDatatoServerAndShowMap() async {
    final database = await Persistance().createDb();
    List<GeographicPosition> geoPos =
        await Persistance().geographicPositions(database);
    debugPrint("${geoPos.length}");
    geoPos.removeWhere((gp) => gp.isForDelete == false);
    if(geoPos.isEmpty == false) {
      sendGeoPositionToServer(geoPos, database);
    }
  }

  _onRefresh(){
    setState((){
      loadProject = true;
      _sendDatatoServerAndShowMap();
      projectFuture = Login().fetchProject(cadoUrl, pid, mid);
    });
  }

  @override
  void initState() {
    if (loadProject) {
      projectFuture = Login().loadProjectFromPersistance();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('CADO'),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RegisterPositionPage()));
              },
              icon: Icon(
                Icons.save,
                color: Colors.white,
              )),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.white
            ),
            onPressed: (){ _onRefresh(); },
          ),
          IconButton(
            icon: Icon(
              _myLocation.show ? Icons.location_on : Icons.location_off,
              color: Colors.white,
            ),
            onPressed: () {
              _onAppBarLocationIconTap();
            },
        ),
          PopupMenuButton<PopupMenuItemActions>(
            onSelected: _onPopupMenuItemSelected,
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<PopupMenuItemActions>>[
                PopupMenuItem<PopupMenuItemActions>(
                  value: PopupMenuItemActions.LOGOUT,
                  child: Text('Se déconnecter'),
                )
              ];
            },
          )
        ],
      ),
      body: loadProject
          ? FutureBuilder(
              future: projectFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _mapWidget = MapWidget(
                    project: snapshot.data,
                    myLocation: _myLocation,
                  );
                  Login().saveProject(snapshot.data);
                  return _mapWidget;
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }
                return Center(child: CircularProgressIndicator());
              },
            )
          : _mapWidget,
    );
  }
}
