import 'package:flutter/material.dart';
import 'package:simple_khata/blocs/customerBloc.dart';
import 'package:simple_khata/models/customer.dart';
import 'package:simple_khata/pages/addCustomer.dart';
import 'package:simple_khata/pages/singleCustomer.dart';

class SingleCustomerScreenArguments {
  final int customerId;

  SingleCustomerScreenArguments(this.customerId);
}

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
    return FutureBuilder(
        future: customerBloc.getCustomers(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return getCustomerCard(snapshot);
        });
  }

  Widget getCustomerCard(AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      return snapshot.data.length != 0
          ? ListView.builder(
              padding: EdgeInsets.fromLTRB(0, 16, 0, 60),
              itemCount: snapshot.data.length,
              itemBuilder: (context, itemIndex) {
                Customer customer = snapshot.data[itemIndex];

                return Column(
                  children: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SingleCustomer(),
                            settings: RouteSettings(
                              arguments: SingleCustomerScreenArguments(
                                customer.id,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 8, 4, 8),
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 4, 12, 4),
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
                      ),
                    ),
                    snapshot.data.length - 1 != itemIndex
                        ? Divider(
                            color: Colors.grey.shade500,
                            height: 2,
                          )
                        : Container()
                  ],
                );
              },
            )
          : Container();
    } else {
      return Container();
    }
  }
}
