import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:udharokhata/helpers/appLocalizations.dart';
import 'package:udharokhata/helpers/constants.dart';
import 'package:udharokhata/helpers/stateNotifier.dart';
import 'package:udharokhata/pages/backup.dart';
import 'package:udharokhata/pages/businessInformation.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _formKey = GlobalKey<FormState>();
  String _currency = "Rs";

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
                    image: AssetImage('assets/images/logo-long.png'),
                    width: 130,
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
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Transform.translate(
                offset: Offset(0.0, 10.0),
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(25.0),
                          topLeft: Radius.circular(25.0)),
                      color: Colors.white,
                    ),
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
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
                            leading: Image(
                              image: AssetImage(
                              "assets/images/business.png"),
                              width: 30,
                              height: 30,
                            ),
                            title: Text(AppLocalizations.of(context)
                                .translate('businessInfo')),
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
                            leading: Image(image: AssetImage(
                              "assets/images/backup.png"),
                              width: 30,
                              height: 30,
                            ),
                            title: Text(AppLocalizations.of(context)
                                .translate('backupInfo')),
                            subtitle: Text(AppLocalizations.of(context)
                                .translate('backupInfoMeta')),
                          ),
                        ),
                        ListTile(
                          leading: Image(
                            image: AssetImage(
                            "assets/images/lang.png"),
                            width: 30,
                            height: 30,
                          ),
                          title: Text(AppLocalizations.of(context)
                              .translate('languageInfo')),
                          subtitle: Text(AppLocalizations.of(context)
                              .translate('languageInfoMeta')),
                          trailing: DropdownButton<String>(
                            value: Provider.of<AppStateNotifier>(context)
                                .appLocale,
                            onChanged: (String newValue) async {
                              await changeLanguage(context, newValue);
                            },
                            items: <String>["en", "ne"]
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                  value: value,
                                  child: Row(
                                    children: [
                                      Image(
                                        image: AssetImage(
                                        "assets/images/$value.png"),
                                        width: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                          value == "en" ? "English" : "नेपाली"),
                                    ],
                                  ));
                            }).toList(),
                          ),
                        ),
                        ListTile(
                          leading: Image(image: AssetImage(
                            "assets/images/calendar.png"),
                            width: 30,
                            height: 30,
                          ),
                          title: Text(AppLocalizations.of(context)
                              .translate('changeCalendar')),
                          subtitle: Text(AppLocalizations.of(context)
                              .translate('changeCalendarMeta')),
                          trailing: DropdownButton<String>(
                            value:
                                Provider.of<AppStateNotifier>(context).calendar,
                            onChanged: (String newValue) async {
                              await changeCalendar(context, newValue);
                            },
                            items: <String>["en", "ne"]
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                  value: value,
                                  child: Row(
                                    children: [
                                      Text(
                                          value == "en" ? "English" : "Nepali"),
                                    ],
                                  ));
                            }).toList(),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            showBottomSheet(
                              context: context,
                              builder: (context) => StatefulBuilder(builder:
                                  (BuildContext context, StateSetter setState) {
                                return Transform.translate(
                                  offset: Offset(0.0, 80.0),
                                  child: contactForm(context),
                                );
                              }),
                            );
                          },
                          child: ListTile(
                            leading: Image(image: AssetImage(
                              "assets/images/currency.png"),
                              width: 30,
                              height: 30,
                            ),
                            title: Text(AppLocalizations.of(context)
                                .translate('changeCurrency')),
                            subtitle: Text(AppLocalizations.of(context)
                                .translate('changeCurrencyMeta')),
                            trailing: Text(
                                Provider.of<AppStateNotifier>(context)
                                    .currency),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Share.share(
                                'Check out our blog: https://flutterblog.crumet.com');
                          },
                          child: ListTile(
                            leading: Image(
                              image: AssetImage(
                              "assets/images/share.png"),
                              width: 30,
                              height: 30,
                            ),
                            title: Text(AppLocalizations.of(context)
                                .translate('shareInfo')),
                            subtitle: Text(AppLocalizations.of(context)
                                .translate('shareInfoMeta')),
                          ),
                        ),
                      ],
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget contactForm(BuildContext context) {
    _currency = Provider.of<AppStateNotifier>(context).currency;
    return Container(
      height: 350,
      padding: EdgeInsets.all(36),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          color: Colors.blueGrey.shade100),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context).translate('changeCurrency'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            TextFormField(
              textAlign: TextAlign.left,
              initialValue: _currency,
              onSaved: (String val) {
                _currency = val;
              },
              validator: (value) {
                if (value.isEmpty) {
                  return AppLocalizations.of(context)
                      .translate('currencyError');
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            RaisedButton(
              color: xDarkBlue,
              child: Text(
                AppLocalizations.of(context).translate('updateCurrency'),
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  await changeCurrency(context, _currency);
                  Navigator.of(context).pop();
                }
              },
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
