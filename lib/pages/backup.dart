import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading/indicator/ball_beat_indicator.dart';
import 'package:loading/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:udharokhata/helpers/firebaseBackup.dart';
import 'package:udharokhata/pages/signin.dart';

class Backup extends StatefulWidget {
  @override
  _BackupState createState() => _BackupState();
}

class _BackupState extends State<Backup> {
  DateTime _lastBackup;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _goToLoginScreen();
  }

  void _goToLoginScreen() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    if (await _auth.currentUser() == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) {
            return SignIn();
          },
        ),
      );
    } else {
      setState(() {
        _loading = false;
      });
      getLastBackupInfo();
    }
  }

  void getLastBackupInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_backup', DateTime.now().toString());

    String lastBackupDate = prefs.getString("last_backup");

    if (lastBackupDate != null) {
      setState(() {
        _lastBackup = DateTime.parse(lastBackupDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: _loading
          ? Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: 280,
              child: Loading(
                  indicator: BallBeatIndicator(),
                  size: 60.0,
                  color: Theme.of(context).accentColor),
            )
          : Container(
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
                        onPressed: () {
                          FirebaseBackup().restoreAllData();
                        },
                        label: Text("Restore Now"),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      FlatButton.icon(
                        icon: Icon(Icons.restore),
                        color: Colors.blue,
                        onPressed: () {
                          FirebaseBackup().backupAllData();
                        },
                        label: Text("Backup to Firebase"),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Text("We backup your data every weekend"),
                      SizedBox(
                        height: 24,
                      ),
                      _lastBackup != null
                          ? Text(
                              "Last backup on ${DateFormat('MMM d, yyyy').format(_lastBackup)}")
                          : Text("No backups")
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
