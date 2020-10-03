import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:loading/indicator/ball_beat_indicator.dart';
import 'package:loading/loading.dart';
import 'package:udharokhata/helpers/constants.dart';
import 'package:udharokhata/helpers/firebaseBackup.dart';
import 'package:udharokhata/pages/signin.dart';

class Backup extends StatefulWidget {
  @override
  _BackupState createState() => _BackupState();
}

class _BackupState extends State<Backup> {
  bool _absorbing = true;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _goToLoginScreen();
  }

  Future<void> _initFirebase() async {
    final FirebaseOptions firebaseOptions = const FirebaseOptions(
      appId: '1:971278159109:android:f46a79ab3703bf888c7b6c',
      apiKey: 'AIzaSyAHB23gI-q8C48a6aYPtHol3yZNQ0a1z08',
      projectId: 'udharokhata',
      messagingSenderId: '971278159109',
    );
    await Firebase.initializeApp(options: firebaseOptions);
  }

  void _goToLoginScreen() async {
    await _initFirebase();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    if (_auth.currentUser == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) {
            return SignIn();
          },
        ),
      );
    }

    setState(() {
      _absorbing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Backup',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                fontFamily: 'Poppins')),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
        backgroundColor: Colors.grey.shade100,
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(24),
            child: Column(
              children: <Widget>[
                Image.asset(
                  "assets/images/data-copy.jpg",
                  width: 300,
                ),
                Column(
                  children: <Widget>[
                    FlatButton.icon(
                      icon: Icon(Icons.restore),
                      onPressed: () async {
                        setState(() {
                          _absorbing = true;
                        });
                        bool restored = await FirebaseBackup().restoreAllData();

                        if (restored) {
                          _scaffoldKey.currentState.showSnackBar(SnackBar(
                            content: Text(
                              "Backup restored.",
                            ),
                          ));
                        }

                        setState(() {
                          _absorbing = false;
                        });
                      },
                      label: Text("Restore Now"),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    FlatButton.icon(
                      icon: Icon(
                        Icons.restore,
                        color: Colors.white,
                      ),
                      color: xDarkBlue,
                      onPressed: () async {
                        setState(() {
                          _absorbing = true;
                        });

                        bool res = await FirebaseBackup().backupAllData();
                        if (res) {
                          _scaffoldKey.currentState.showSnackBar(SnackBar(
                            content: Text(
                              "Backup Successful",
                            ),
                          ));
                        }

                        setState(() {
                          _absorbing = false;
                        });
                      },
                      label: Text(
                        "Backup to the cloud",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    Text("We backup your data every weekend"),
                  ],
                ),
              ],
            ),
          ),
          _absorbing
              ? AbsorbPointer(
                  absorbing: _absorbing,
                  child: Container(
                    child: Center(
                      child: Loading(
                          indicator: BallBeatIndicator(),
                          size: 60.0,
                          color: Theme.of(context).accentColor),
                    ),
                    constraints: BoxConstraints.expand(),
                    color: Colors.white,
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
