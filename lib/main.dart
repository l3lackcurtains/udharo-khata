import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:udharokhata/pages/customers.dart';
import 'package:udharokhata/pages/settings.dart';
import 'package:udharokhata/services/autoBackup.dart';
import 'package:udharokhata/services/loadBusinessInfo.dart';

import 'pages/signin.dart';

void main() {
  runApp(MyApp());
  BackgroundFetch.registerHeadlessTask(autoBackupData);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Khata',
        theme: ThemeData(
            primaryColor: Color(0xFF192a56),
            accentColor: Color(0xFFe74c3c),
            fontFamily: 'Roboto'),
        home: SignIn());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = [
    Customers(),
    Settings(),
  ];

  @override
  void initState() {
    super.initState();
    loadBusinessInfo();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;
    BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 1,
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
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.people), title: Text('Customers')),
            BottomNavigationBarItem(
                icon: Icon(Icons.menu), title: Text('More')),
          ],
          currentIndex: _selectedIndex,
          fixedColor: Colors.deepPurple,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
