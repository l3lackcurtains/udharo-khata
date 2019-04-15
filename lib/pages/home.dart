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
            Padding(padding: EdgeInsets.all(20.0)),
            Row(
              children: <Widget>[
                Padding(padding: EdgeInsets.all(8.0)),
                Text(
                  'Hello Madhav Jee!',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.all(10.0)),
            Row(
              children: <Widget>[
                Padding(padding: EdgeInsets.all(8.0)),
                Text('Your have \$1000 in your account',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black54,
                    ),
                ),
              ],
            ),
          ],
        ));
  }
}
