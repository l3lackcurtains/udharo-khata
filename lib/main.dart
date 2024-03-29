import 'dart:async';
import 'dart:convert';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:udharokhata/helpers/constants.dart';
import 'package:udharokhata/helpers/stateNotifier.dart';
import 'package:udharokhata/pages/customers.dart';
import 'package:udharokhata/pages/settings.dart';
import 'package:udharokhata/services/autoBackup.dart';

import 'blocs/businessBloc.dart';
import 'helpers/appLocalizations.dart';
import 'helpers/stateNotifier.dart';
import 'models/business.dart';
import 'pages/addBusiness.dart';
import 'services/loadBusinessInfo.dart';

void main() {
  runApp(
    ChangeNotifierProvider<AppStateNotifier>(
      create: (context) => AppStateNotifier(),
      child: MyApp(),
    ),
  );
  BackgroundFetch.registerHeadlessTask(autoBackupData);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateNotifier>(builder: (context, appState, child) {
      return MaterialApp(
        title: 'Khata',
        debugShowCheckedModeBanner: false,
        supportedLocales: AppLocalizations.delegate.supportedLocales,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        theme: ThemeData(
          primaryColor: Color(0xFF192a56),
          accentColor: Color(0xFFe74c3c),
          fontFamily: 'Roboto',
          textTheme: TextTheme(
            headline1: TextStyle(
              fontSize: 18,
              color: Colors.black,
              height: 1.2,
              fontWeight: FontWeight.w700,
              fontFamily: "Quicksand",
            ),
          ),
          backgroundColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: MyHomePage(),
        locale: Locale(appState.appLocale),
      );
    });
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final BusinessBloc businessBloc = BusinessBloc();
  int _selectedIndex = 0;
  List<Business> _businesses = [];
  Business _selectedBusiness;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getTheLocale();
    BackButtonInterceptor.add(myInterceptor);
    initPlatformState();
    getAllBusinesses();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    getAllBusinesses();
    return false;
  }

  void getAllBusinesses() async {
    List<Business> businesses = await businessBloc.getBusinesss();

    if (businesses.length == 0) {
      await loadBusinessInfo(context);
    }
    businesses = await businessBloc.getBusinesss();
    final prefs = await SharedPreferences.getInstance();
    int selectedBusinessId = prefs.getInt('selected_business') ?? 0;
    Business selectedBusiness;
    businesses.forEach((business) {
      if (business.id == selectedBusinessId) {
        selectedBusiness = business;
      }
    });

    businesses.add(null);
    setState(() {
      _businesses = businesses;
      _selectedBusiness = selectedBusiness;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void getTheLocale() async {
    await fetchLocale(context);
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;
    BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 60,
            stopOnTerminate: false,
            enableHeadless: false,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            requiredNetworkType: NetworkType.NONE), (String taskId) async {
      BackgroundFetch.finish(taskId);
    }).then((int status) {
      print('[BackgroundFetch] configure success: $status');
    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
    });
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Scaffold(
        appBar: AppBar(
          title: Image(
            image: AssetImage('assets/images/logo-long.png'),
            width: 100,
          ),
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          actions: [
            Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: DropdownButton<Business>(
                value: _selectedBusiness,
                underline: Container(
                  height: 0,
                ),
                onChanged: (Business newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedBusiness = newValue;
                    });
                    changeSelectedBusiness(context, newValue.id);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddBusiness(),
                      ),
                    );
                  }
                },
                items: _businesses
                    .map<DropdownMenuItem<Business>>((Business business) {
                  if (business != null) {
                    return DropdownMenuItem<Business>(
                      value: business,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                        child: Row(
                          children: [
                            business.logo != ""
                                ? CircleAvatar(
                                    backgroundColor: xDarkBlue,
                                    radius: 15,
                                    child: ClipOval(
                                      child: Image.memory(
                                        Base64Decoder().convert(business.logo),
                                        width: 30,
                                        height: 30,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                : SizedBox(width: 16),
                            SizedBox(width: 8),
                            Text(
                              business.companyName,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return DropdownMenuItem<Business>(
                      value: business,
                      child: Row(
                        children: [
                          Icon(
                            Icons.add,
                            size: 18,
                            color: Colors.redAccent,
                          ),
                          Text(
                            AppLocalizations.of(context)
                                .translate('addRemoveBusiness'),
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ));
                }).toList(),
              ),
            )
          ],
        ),
        body: Center(
          child: [
            Customers(),
            Settings(),
          ].elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: AppLocalizations.of(context).translate('customers')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.menu),
                  label: AppLocalizations.of(context).translate('more')),
            ],
            currentIndex: _selectedIndex,
            fixedColor: Colors.deepPurple,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed),
      ),
      _isLoading
          ? Scaffold(backgroundColor: Theme.of(context).primaryColor)
          : Center()
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
