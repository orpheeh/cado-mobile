import 'package:cado/models/my_location.dart';
import 'package:cado/services/project.dart';
import 'package:cado/services/sign.dart';
import 'package:cado/widgets/map_widget.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

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
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (ctx) => HomePage()));
    }
  }

  _onAppBarLocationIconTap() {
    setState((){
      _myLocation.show = !_myLocation.show;
      if(_myLocation.show){
        _myLocation.startStreamMyLocation();
      } else {
        _myLocation.stopStreamMyLocation();
      }
    });
  }

  @override
  void initState() {
    if (loadProject) {
      projectFuture = Login().fetchProject(cadoUrl, pid, mid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CADO'),
        actions: <Widget>[
          IconButton(
              icon: Icon(
            Icons.save,
            color: Colors.white,
          )),
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
