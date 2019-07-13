import 'package:cado/services/project.dart';
import 'package:cado/services/sign.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'home_screen.dart';
import 'map_screen.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool _loginRequestSend;
  Future<Project> _project;
  Login _login;
  TextEditingController _codeEditController = TextEditingController();
  TextEditingController _urlEditController = TextEditingController();

  _onLoginButtonPressed() {
    setState(() {
      _loginRequestSend = true;
      int pid = int.parse(_codeEditController.text.split('P')[1].split('M')[0]);
      int mid = int.parse(_codeEditController.text.split('M')[1]);
      String url = _urlEditController.text;
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(8.0),
            margin: EdgeInsets.all(20.0),
            child: _loginRequestSend
                ? FutureBuilder(
                    future: _project,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        SchedulerBinding.instance.addPostFrameCallback((_) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MapPage(project: snapshot.data)));
                        });
                        return Container();
                      } else if (snapshot.hasError) {
                        return Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red),
                        );
                      }
                      return CircularProgressIndicator();
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
