
import 'package:cado/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';
import 'map_screen.dart';

class HomePage extends StatelessWidget {

  Future<SharedPreferences> _sharedPreferences(){
    return SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _sharedPreferences(),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          var projectId = snapshot.data.getInt('projectId');
          if(projectId == null){
            return LoginPage();
          } else {
            return MapPage(pid: projectId,
            mid: snapshot.data.getInt('mobileId'),
            url: snapshot.data.getString('cadoURL'),);
          }
        } else {
          return SplashScreen();
        }
      },
    );
  }
}
