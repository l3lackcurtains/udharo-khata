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
                  'Hello Madhav!',
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
                Text(
                  'Your Khata Summary',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            Padding(padding: EdgeInsets.all(10.0)),
            Container(
              padding: EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Card(
                      color: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            title: Text(
                              'Debit Amount',
                              style: TextStyle(
                                fontSize: 18,
                                height: 1.2,
                              ),
                            ),
                            subtitle: Text('\$ 10,000',
                                style: TextStyle(
                                    height: 1.2,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      color: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            title: Text(
                              'Credit Amount',
                              style: TextStyle(
                                fontSize: 18,
                                height: 1.2,
                              ),
                            ),
                            subtitle: Text('\$ 30,000',
                                style: TextStyle(
                                    height: 1.2,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Card(
                      color: Colors.white10,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            title: Text('Customers'),
                            subtitle: Text('300'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                    child: IconButton(
                      icon: Icon(Icons.add_circle_outline),
                      iconSize: 40,
                      onPressed: () {},
                    ),
                  )
                ],
              ),
            ),
          ],
        ));
  }
}
