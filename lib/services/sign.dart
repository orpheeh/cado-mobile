import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cado/services/project.dart';

class Login {

  Future<Project> fetchProject(String url, int pid, int mid) async {
    Map<String, String> header = <String, String>{
      "content-type" : "application/json",
      "authorization": "Access mobileBearer 1"
    };
    Map<String, dynamic> b = {"pid": pid, "mid": mid};

    debugPrint(url);
    final response = await http.post(url + "/api/mobile/auth", headers: header, body: jsonEncode(b));
    if (response.statusCode == 200) {
      registerProjectData(url, pid, mid);
      return Project.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load project');
    }
  }

  void registerProjectData(url, pid, mid) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString('cadoURL', url);
    sp.setInt("projectId", pid);
    sp.setInt("mobileId", mid);
  }
}
