import 'package:flutter/material.dart';
import 'package:simple_khata/pages/addCustomer.dart';
import 'package:simple_khata/pages/addTransaction.dart';
import 'package:simple_khata/pages/customers.dart';
import 'package:simple_khata/pages/home.dart';
import 'package:simple_khata/pages/transactions.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Khata',
      theme: ThemeData(
          primarySwatch: Colors.purple,
          primaryColor: Colors.deepPurple,
          fontFamily: 'Roboto'),
      home: MyHomePage(title: 'Khata'),
      routes: <String, WidgetBuilder>{
        '/addcustomer': (BuildContext context) => AddCustomer(),
        '/addtransaction': (BuildContext context) => AddTransaction(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = [
    Home(),
    Customers(),
    Transactions(),
    const Text('Index 4: School'),
  ];

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
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.home), title: Text('Dashboard')),
            BottomNavigationBarItem(
                icon: Icon(Icons.people), title: Text('Customers')),
            BottomNavigationBarItem(
                icon: Icon(Icons.perm_media), title: Text('Transactions')),
            BottomNavigationBarItem(
                icon: Icon(Icons.school), title: Text('Profile')),
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
