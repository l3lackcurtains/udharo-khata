import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as pathx;
import 'package:path_provider/path_provider.dart';

class FirebaseBackup {
  Future<bool> backupAllData() async {
    FirebaseApp app = await Firebase.initializeApp();

    final FirebaseStorage storage = FirebaseStorage(
        storageBucket: 'gs://udharokhata.appspot.com/', app: app);

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String dbPath = pathx.join(documentsDirectory.path, 'udharoKhata.db');
    File file = File(dbPath);

    final FirebaseAuth _auth = FirebaseAuth.instance;

    final StorageReference ref = storage
        .ref()
        .child('udharo-khata-database')
        .child(_auth.currentUser.uid)
        .child('udharoKhata.db');

    ref.putFile(
      file,
    );
    await Future.delayed(Duration(seconds: 5));
    return true;
  }

  Future<bool> restoreAllData() async {
    FirebaseApp app = await Firebase.initializeApp();
    final FirebaseStorage storage = FirebaseStorage(
        storageBucket: 'gs://udharokhata.appspot.com/', app: app);

    final FirebaseAuth _auth = FirebaseAuth.instance;

    final StorageReference ref = storage
        .ref()
        .child('udharo-khata-database')
        .child(_auth.currentUser.uid)
        .child('udharoKhata.db');
    final String url = await ref.getDownloadURL();
    final http.Response downloadData = await http.get(url);

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String dbPath = pathx.join(documentsDirectory.path, 'udharoKhata.db');
    File(dbPath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(downloadData.bodyBytes);
    return true;
  }

  Future<bool> downloadBackup() async {
    FirebaseApp app = await Firebase.initializeApp();

    final FirebaseStorage storage = FirebaseStorage(
        storageBucket: 'gs://udharokhata.appspot.com/', app: app);

    final FirebaseAuth _auth = FirebaseAuth.instance;

    final StorageReference ref = storage
        .ref()
        .child('udharo-khata-database')
        .child(_auth.currentUser.uid)
        .child('udharoKhata.db');

    final String url = await ref.getDownloadURL();
    final http.Response downloadData = await http.get(url);

    final File tempFile = File('/storage/emulated/0/Download/udharoKhata.db');
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }
    await tempFile.create();
    await tempFile.writeAsString(downloadData.body);

    return true;
  }
}
