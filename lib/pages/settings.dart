import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:udharokhata/pages/backup.dart';
import 'package:udharokhata/pages/businessInformation.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            height: 140,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Image(
                    image: AssetImage('images/google_logo.png'),
                    height: 40,
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                  child: Text(
                    "Udharo Khata \n Small business credit management app",
                    textAlign: TextAlign.center,
                    style: TextStyle(height: 1.6, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
          ListView(
            shrinkWrap: true,
            children: <Widget>[
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BusinessInformation(),
                    ),
                  );
                },
                child: ListTile(
                  leading: Image.asset(
                    "images/business.png",
                    width: 30,
                  ),
                  title: Text('Business Information'),
                  subtitle: Text("Setup your business informations."),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Backup(),
                    ),
                  );
                },
                child: ListTile(
                  leading: Image.asset(
                    "images/backup.png",
                    width: 30,
                  ),
                  title: Text('Backup'),
                  subtitle: Text("Back up your udharo khata data"),
                ),
              ),
              InkWell(
                onTap: () {
                  Share.share(
                      'Check out our blog: https://flutterblog.crumet.com');
                },
                child: ListTile(
                  leading: Image.asset(
                    "images/share.png",
                    width: 30,
                  ),
                  title: Text('Share'),
                  subtitle: Text("Spread the words of flutter blog crumet"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
