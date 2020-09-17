import 'package:flutter/material.dart';
import 'package:udharokhata/helpers/firebaseBackup.dart';

class Backup extends StatefulWidget {
  @override
  _BackupState createState() => _BackupState();
}

class _BackupState extends State<Backup> {
  Future<List<dynamic>> _backupList;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khata',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                fontFamily: 'Poppins')),
        elevation: 0,
        backgroundColor: Colors.grey.shade100,
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                RaisedButton(
                  onPressed: () {
                    FirebaseBackup().restoreAllData();
                  },
                  child: Text("Restore Now."),
                ),
                RaisedButton(
                  color: Colors.red,
                  onPressed: () {
                    FirebaseBackup().backupAllData();
                  },
                  child: Text("Backup to Firebase"),
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                  future:
                      _backupList, // a previously-obtained Future<String> or null
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.length == 0) return Container();
                      return Column(
                          children: snapshot.data.map((item) {
                        return InkWell(
                            child: Container(
                                padding: EdgeInsets.all(8),
                                child: Text(item['name'])));
                      }).toList());
                    }
                    return Container();
                  }),
            )
          ],
        ),
      ),
    );
  }
}
