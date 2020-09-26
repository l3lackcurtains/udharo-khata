import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:udharokhata/helpers/appLocalizations.dart';
import 'package:udharokhata/helpers/stateNotifier.dart';
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
                    image: AssetImage('assets/images/google_logo.png'),
                    height: 40,
                    width: 40,
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Text(
                    AppLocalizations.of(context).translate('appInfo'),
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
                    "assets/images/business.png",
                    width: 30,
                    height: 30,
                    scale: 1.0,
                  ),
                  title: Text(
                      AppLocalizations.of(context).translate('businessInfo')),
                  subtitle: Text(AppLocalizations.of(context)
                      .translate('businessInfoMeta')),
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
                    "assets/images/backup.png",
                    width: 30,
                    height: 30,
                    scale: 1.0,
                  ),
                  title: Text(
                      AppLocalizations.of(context).translate('backupInfo')),
                  subtitle: Text(
                      AppLocalizations.of(context).translate('backupInfoMeta')),
                ),
              ),
              ListTile(
                leading: Image.asset(
                  "assets/images/lang.png",
                  width: 30,
                  height: 30,
                  scale: 1.0,
                ),
                title: Text(
                    AppLocalizations.of(context).translate('languageInfo')),
                subtitle: Text(
                    AppLocalizations.of(context).translate('languageInfoMeta')),
                trailing: DropdownButton<String>(
                  value: Provider.of<AppStateNotifier>(context).appLocale,
                  onChanged: (String newValue) async {
                    await changeLanguage(context, newValue);
                  },
                  items: <String>["en", "ne"]
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                        value: value, child: Text(value));
                  }).toList(),
                ),
              ),
              InkWell(
                onTap: () {
                  Share.share(
                      'Check out our blog: https://flutterblog.crumet.com');
                },
                child: ListTile(
                  leading: Image.asset(
                    "assets/images/share.png",
                    width: 30,
                    height: 30,
                    scale: 1.0,
                  ),
                  title:
                      Text(AppLocalizations.of(context).translate('shareInfo')),
                  subtitle: Text(
                      AppLocalizations.of(context).translate('shareInfoMeta')),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
