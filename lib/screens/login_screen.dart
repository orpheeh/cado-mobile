import 'dart:convert';

import 'package:cado/services/persistance.dart';
import 'package:cado/services/project.dart';
import 'package:cado/services/sign.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'map_screen.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool _loginRequestSend;
  Future<Project> _project;
  Login _login;
  int pid;
  int mid;
  String url;
  TextEditingController _codeEditController = TextEditingController();
  TextEditingController _urlEditController = TextEditingController();

  _onLoginButtonPressed() {
    setState(() {
      _project = null;
      _loginRequestSend = true;
      pid = int.parse(_codeEditController.text.split('P')[1].split('M')[0]);
      mid = int.parse(_codeEditController.text.split('M')[1]);
      url = _urlEditController.text;
      debugPrint(url);
      _project = _login.fetchProject(url, pid, mid);
    });
  }

  @override
  void initState() {
    _login = Login();
    _loginRequestSend = false;
    _codeEditController = TextEditingController();
  }

  @override
  void dispose() {
    _codeEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CADO'),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(8.0),
            margin: EdgeInsets.all(20.0),
            child: _loginRequestSend
                ? FutureBuilder(
                    future: _project,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        //Save project zone and markers on local database
                        SchedulerBinding.instance.addPostFrameCallback((_) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MapPage(
                                        project: snapshot.data,
                                        url: url,
                                        pid: pid,
                                        mid: mid,
                                      )));
                        });
                        Login().saveProject(snapshot.data);
                        return Container();
                      } else if (snapshot.hasError) {
                        return Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red),
                        );
                      }
                      return Center(child: CircularProgressIndicator());
                    },
                  )
                : Text(''),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            margin: EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
                controller: _urlEditController,
                decoration:
                    InputDecoration(hintText: 'Entrez le lien de cado')),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            margin: EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
                controller: _codeEditController,
                decoration:
                    InputDecoration(hintText: 'Entrez le code du projet')),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            margin: EdgeInsets.symmetric(horizontal: 16.0),
            child: RaisedButton(
              onPressed: _onLoginButtonPressed,
              child: Text(
                'Se connecter',
                style: TextStyle(fontSize: 16.0),
              ),
              color: Colors.green,
              textColor: Colors.white,
              splashColor: Colors.greenAccent,
            ),
          )
        ],
      ),
    );
  }
}
