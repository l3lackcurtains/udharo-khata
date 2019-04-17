import 'package:flutter/material.dart';

class Customers extends StatefulWidget {
  @override
  _CustomersState createState() => _CustomersState();
}

class _CustomersState extends State<Customers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: Column(
            children: <Widget>[
              ListBody(children: <Widget>[
                ListTile(
                    dense: true,
                    onTap: () {},
                    title: const Text('Madhav Poudel'),
                    subtitle: const Text('9824119696'),
                    trailing: const Text('-1000')),
                ListTile(
                  dense: true,
                  onTap: () {},
                  title: const Text('Milan Poudel'),
                  subtitle: const Text('9824119696'),
                  trailing: const Text('+1000'),
                ),
              ]),
            ],
          )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Add Customer'),
      ),
    );
  }
}
