import 'package:flutter/material.dart';
import 'package:simple_khata/blocs/customerBloc.dart';
import 'package:simple_khata/models/customer.dart';
import 'package:simple_khata/pages/addCustomer.dart';

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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCustomer()),
          );
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

                return Padding(
                  padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(4, 4, 16, 4),
                            child: CircleAvatar(
                              backgroundColor: Colors.purple.shade500,
                              child: Icon(Icons.person,
                                  color: Colors.purple.shade100, size: 20.0),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
                                child: Text(customer.name),
                              ),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.phone,
                                    color: Colors.brown.shade600,
                                    size: 16.0,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(8, 4, 4, 4),
                                    child: Text(customer.phone),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Spacer(),
                          Text("\$ 2000",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      snapshot.data.length - 1 != itemIndex
                          ? Padding(
                              padding: EdgeInsets.fromLTRB(0, 16, 0, 8),
                              child: Divider(
                                color: Colors.grey.shade500,
                                height: 2,
                              ),
                            )
                          : Container()
                    ],
                  ),
                );
              },
            )
          : Container();
    } else {
      return Container();
    }
  }
}
