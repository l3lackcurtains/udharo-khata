import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:udharokhata/helpers/googleDrive.dart';

class Backup extends StatefulWidget {
  @override
  _BackupState createState() => _BackupState();
}

class _BackupState extends State<Backup> {
  void backupData() async {
    // var trans = await TransactionBloc().getTransactions();
    // var transJson = trans[0].toDatabaseJson();

    // print(transJson);

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String customerDbFile = join(documentsDirectory.path, 'customer.db');

    GoogleClient().uploadFileToGoogleDrive(customerDbFile);
  }

  void restoreData() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String customerDbFile = join(documentsDirectory.path, 'customer.db');

    GoogleClient().downloadGoogleDriveFile(customerDbFile);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
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
    );
  }
}
