import 'dart:convert';

import 'package:cado/services/persistance.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cado/services/project.dart';

class Login {
  Future<Project> fetchProject(String url, int pid, int mid) async {
    Map<String, String> header = <String, String>{
      "content-type": "application/json",
      "authorization": "Access mobileBearer 1"
    };
    Map<String, dynamic> b = {"pid": pid, "mid": mid};

    final response = await http.post(url + "/api/mobile/auth",
        headers: header, body: jsonEncode(b));
    if (response.statusCode == 200) {
      Project project = Project.fromJson(jsonDecode(response.body));
      registerProjectData(url, pid, mid, project.title, project.description);
      return project;
    } else {
      throw Exception('Failed to load project');
    }
  }

  void registerProjectData(url, pid, mid, title, description) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString('cadoURL', url);
    sp.setInt("projectId", pid);
    sp.setInt("mobileId", mid);
    sp.setString('cadoProjectTitle', title);
    sp.setString('cadoProjectDescription', description);
  }

  Future<Project> loadProjectFromPersistance() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    final title = sp.getString("cadoProjectTitle");
    final description = sp.getString("cadoProjectDescription");
    final pid = sp.getInt("projectId");

    Persistance persistance = await Persistance();
    final database = await persistance.createDb();

    final zone = await persistance.zone(database);
    final markers = await persistance.geographicPositions(database);
    markers.removeWhere((m) => m.isForDelete);

    debugPrint(jsonEncode(zone));
    debugPrint(jsonEncode(markers));

    final projectMap = {
      "project": {
        "title": title,
        "description": description,
        "pid": pid,
        "zone": zone,
        "markers":
        List.generate(markers.length, (index) => markers[index].toJson())
      },
      "status" : 200
    };

    debugPrint(jsonEncode(projectMap));

    return Project.fromJson(projectMap);
  }

  Future<void> saveProject(Project project) async {
    final persistance = Persistance();
    final database = await persistance.createDb();

    persistance.deleteAllGeoPosition(database);
    persistance.deleteZone(database);

    persistance.insertZone(project.zoneToJson(), database);

    project.geographicPositions.forEach((marker){
      persistance.insertGoePosition(marker, database);
    });

    final zone = await persistance.zone(database);
    final markers = await persistance.geographicPositions(database);
    markers.removeWhere((m) => m.isForDelete);

    debugPrint(jsonEncode(zone));
    debugPrint(jsonEncode(markers));
  }
}
