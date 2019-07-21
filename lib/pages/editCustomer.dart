import 'package:flutter/material.dart';
import 'package:simple_khata/blocs/customerBloc.dart';
import 'package:simple_khata/models/customer.dart';
import 'package:simple_khata/pages/singleCustomer.dart';

class EditCustomer extends StatefulWidget {
  @override
  _EditCustomerState createState() => _EditCustomerState();
}

class _EditCustomerState extends State<EditCustomer> {
  final CustomerBloc customerBloc = CustomerBloc();
  String _name, _phone;
  Customer customer = Customer();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final EditCustomerScreenArguments args =
        ModalRoute.of(context).settings.arguments;
    Customer argCustomer = args.customer;

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Edit Customer',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),
      ),
      body: Container(
          decoration: BoxDecoration(color: Colors.white),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  initialValue: argCustomer.name,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    hintText: 'What is your customer name?',
                    labelText: 'Name *',
                  ),
                  autovalidate: false,
                  validator: (input) {
                    if (input.isEmpty) {
                      return 'Please type customer name';
                    }
                  },
                  onSaved: (input) => _name = input,
                ),
                TextFormField(
                  initialValue: argCustomer.phone,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.call_missed_outgoing),
                    hintText: 'Contact Number of customer.',
                    labelText: 'Phone Number *',
                  ),
                  autovalidate: false,
                  validator: (input) {
                    if (input.isEmpty) {
                      return 'Please type customer phone number';
                    }
                  },
                  onSaved: (input) => _phone = input,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.location_city),
                    hintText: 'Where your customer resides.',
                    labelText: 'Physical Address',
                  ),
                  autovalidate: false,
                  validator: null,
                ),
                const Padding(
                  padding: EdgeInsets.all(36),
                ),
                Row(
                  children: <Widget>[
                    Spacer(),
                    Expanded(
                      child: RaisedButton(
                        textColor: Colors.white,
                        color: Colors.purple,
                        onPressed: () {
                          updateCustomer(argCustomer.id);
                        },
                        padding: const EdgeInsets.all(16.0),
                        child: const Text('Update'),
                      ),
                    )
                  ],
                )
              ],
            ),
          )),
    );
  }

  void updateCustomer(int id) {
    final formState = _formKey.currentState;

    if (formState.validate()) {
      formState.save();
      customer.id = id;
      customer.name = _name;
      customer.phone = _phone;
      customerBloc.updateCustomer(customer);

      Navigator.pop(context);
    }
  }
}
