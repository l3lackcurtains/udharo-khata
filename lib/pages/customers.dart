import 'package:flutter/material.dart';
import 'package:simple_khata/blocs/customerBloc.dart';
import 'package:simple_khata/models/customer.dart';

class Customers extends StatefulWidget {
  @override
  _CustomersState createState() => _CustomersState();
}

class _CustomersState extends State<Customers> {
  final CustomerBloc customerBloc = CustomerBloc();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: getCustomersList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/addcustomer');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Customer'),
      ),
    );
  }

  Widget getCustomersList() {
    return StreamBuilder(
        stream: customerBloc.customers,
        builder:
            (BuildContext context, AsyncSnapshot<List<Customer>> snapshot) {
          return getCustomerCard(snapshot);
        });
  }

  Widget getCustomerCard(AsyncSnapshot<List<Customer>> snapshot) {
    if (snapshot.hasData) {
      return snapshot.data.length != 0
          ? ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, itemIndex) {
                Customer customer = snapshot.data[itemIndex];
                return ListTile(
                    dense: true,
                    onTap: () {},
                    title: Text('${customer.name}'),
                    subtitle: Text('${customer.phone}'),
                    trailing: Column(
                      children: <Widget>[
                        Text('-2000'),
                        RaisedButton(
                          child: const Text('Delete'),
                          onPressed: () {
                            customerBloc.deleteCustomerById(customer.id);
                          },
                        )
                      ],
                    ));
              },
            )
          : Container();
    } else {
      return Container();
    }
  }
}
