import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:path/path.dart' as path;

class GoogleHttpClient extends IOClient {
  Map<String, String> _headers;

  GoogleHttpClient(this._headers) : super();

  @override
  Future<IOStreamedResponse> send(http.BaseRequest request) =>
      super.send(request..headers.addAll(_headers));

  @override
  Future<http.Response> head(Object url, {Map<String, String> headers}) =>
      super.head(url, headers: headers..addAll(_headers));
}

class GoogleClient {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static GoogleSignIn googleSignIn =
      GoogleSignIn(scopes: ['https://www.googleapis.com/auth/drive.appdata']);
  static GoogleSignInAccount googleSignInAccount;

  Future<String> signInWithGoogle() async {
    googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    return '$user';
  }

  uploadFileToGoogleDrive(String filepath) async {
    googleSignInAccount = await googleSignIn.signIn();
    var client = GoogleHttpClient(await googleSignInAccount.authHeaders);
    var drive = ga.DriveApi(client);
    ga.File fileToUpload = ga.File();
    File file = File(filepath);
    fileToUpload.parents = ["appDataFolder"];
    fileToUpload.name = path.basename(file.absolute.path);

    await drive.files.list(spaces: 'appDataFolder').then((list) async {
      for (var i = 0; i < list.files.length; i++) {
        if (list.files[i].name == 'customer.db') {
          var fileId = list.files[i].id;
          await drive.files.delete(
            fileId,
          );
        }
      }

      await drive.files.create(
        fileToUpload,
        uploadMedia: ga.Media(file.openRead(), file.lengthSync()),
      );
    });

    listGoogleDriveFiles();
  }

  Future<List<dynamic>> listGoogleDriveFiles() async {
    googleSignInAccount = await googleSignIn.signIn();
    var client = GoogleHttpClient(await googleSignInAccount.authHeaders);
    var drive = ga.DriveApi(client);
    List<dynamic> fileList = [];
    await drive.files.list(spaces: 'appDataFolder').then((list) {
      for (var i = 0; i < list.files.length; i++) {
        print("Id: ${list.files[i].id} File Name:${list.files[i].name}");
        fileList.add({"id": list.files[i].id, "name": list.files[i].name});
      }
    });
    return fileList;
  }

  Future<void> downloadGoogleDriveFile(String fName) async {
    googleSignInAccount = await googleSignIn.signIn();
    var client = GoogleHttpClient(await googleSignInAccount.authHeaders);
    var drive = ga.DriveApi(client);

    await drive.files.list(spaces: 'appDataFolder').then((list) async {
      var fileId = '0';
      for (var i = 0; i < list.files.length; i++) {
        if (list.files[i].name == 'customer.db') {
          fileId = list.files[i].id;
          break;
        }
      }

      if (fileId != '0') {
        ga.Media file = await drive.files
            .get(fileId, downloadOptions: ga.DownloadOptions.FullMedia);
        final saveFile = File(fName);
        List<int> dataStore = [];
        file.stream.listen((data) {
          dataStore.insertAll(dataStore.length, data);
        }, onDone: () {
          saveFile.writeAsBytes(dataStore);
          print("File saved at ${saveFile.path}");
        }, onError: (error) {
          print(error);
        });
      }
    });
  }
}
