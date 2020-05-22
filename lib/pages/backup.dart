import 'package:flutter/material.dart';
import 'package:udharokhata/helpers/googleDrive.dart';

class Backup extends StatefulWidget {
  @override
  _BackupState createState() => _BackupState();
}

class _BackupState extends State<Backup> {
  Future<List<dynamic>> _backupList;
  @override
  void initState() {
    super.initState();
    _getBackupList();
  }

  void _getBackupList() {
    setState(() {
      _backupList = GoogleClient().listGoogleDriveFiles();
    });
  }

  void backupData() async {
    // var trans = await TransactionBloc().getTransactions();
    // var transJson = trans[0].toDatabaseJson();

    // print(transJson);

    GoogleClient().uploadFileToGoogleDrive();
  }

  void restoreData() async {
    GoogleClient().downloadGoogleDriveFile();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  backupData();
                },
                child: Text("Backup Now."),
              ),
              RaisedButton(
                onPressed: () {
                  restoreData();
                },
                child: Text("Restore Now."),
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
    );
  }
}
