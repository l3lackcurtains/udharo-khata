import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:udharokhata/helpers/firebaseBackup.dart';

class Backup extends StatefulWidget {
  @override
  _BackupState createState() => _BackupState();
}

class _BackupState extends State<Backup> {
  DateTime _lastBackup;
  @override
  void initState() {
    super.initState();
    getLastBackupInfo();
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
      body: Container(
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
