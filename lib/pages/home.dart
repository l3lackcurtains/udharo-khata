import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          children: <Widget>[
            const Padding(padding: EdgeInsets.all(20.0)),
            Row(
              children: <Widget>[
                const Padding(padding: EdgeInsets.all(8.0)),
                Text(
                  'Hello Madhav!',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.all(10.0)),
            Row(
              children: <Widget>[
                const Padding(padding: EdgeInsets.all(8.0)),
                Text(
                  'Your have \$1000 in your account',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.all(30.0)),
            Row(
              children: <Widget>[
                const SizedBox(
                  width: 100,
                ),
                Expanded(
                  flex: 1,
                  child: RaisedButton(
                    onPressed: () {},
                    elevation: 5.0,
                    padding: const EdgeInsets.all(20),
                    color: Colors.purple,
                    child: Text('Add Customers',
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                  ),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.all(10.0)),
            Row(
              children: <Widget>[
                const SizedBox(
                  width: 100,
                ),
                Expanded(
                  flex: 1,
                  child: RaisedButton(
                    onPressed: () {},
                    elevation: 5.0,
                    padding: const EdgeInsets.all(20),
                    color: Colors.purple,
                    child: Text('Add Transaction',
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
