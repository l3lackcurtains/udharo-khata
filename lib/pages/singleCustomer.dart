import 'package:flutter/material.dart';
import 'package:simple_khata/blocs/customerBloc.dart';

class AddCustomer extends StatefulWidget {
  @override
  _AddCustomerState createState() => _AddCustomerState();
}

class _AddCustomerState extends State<AddCustomer> {
  final CustomerBloc customerBloc = CustomerBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Add Customer',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Text('Customer name'),
            Text('Customer Phone Number'),
            const Padding(
              padding: EdgeInsets.all(36),
            ),
          ],
        ),
      ),
    );
  }
}
