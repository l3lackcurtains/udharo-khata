import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:simple_khata/blocs/customerBloc.dart';
import 'package:simple_khata/blocs/transactionBloc.dart';
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

  final TransactionBloc transactionBloc = TransactionBloc();

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
        icon: Icon(Icons.add),
        label: Text('Add Customer'),
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

  Widget getCustomerTransactionsTotalWidget(int cid) {
    return FutureBuilder(
        future: transactionBloc.getCustomerTransactionsTotal(cid),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            int total = snapshot.data;
            if (total == 0) return Container();
            bool neg = false;
            String ttype = "payment";
            if (total.isNegative) {
              neg = true;
              ttype = "credit";
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Row(children: <Widget>[
                  Text(total.abs().toString(),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  neg
                      ? Icon(
                          Icons.arrow_upward,
                          color: Colors.green.shade900,
                          size: 16.0,
                        )
                      : Icon(
                          Icons.arrow_downward,
                          color: Colors.orange.shade900,
                          size: 16.0,
                        ),
                ]),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                  child: Text(
                    ttype.toUpperCase(),
                    style: TextStyle(
                        color: Colors.black38,
                        fontSize: 10,
                        letterSpacing: 0.6),
                  ),
                )
              ],
            );
          }

          return Container();
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
                Uint8List customerImage;
                if (customer.image != null) {
                  customerImage = Base64Decoder().convert(customer.image);
                }

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
                            Hero(
                                tag: customer.id,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 4, 12, 4),
                                  child: customerImage != null
                                      ? CircleAvatar(
                                          radius: 24.0,
                                          child: ClipOval(
                                              child: Image.memory(customerImage,
                                                  height: 48,
                                                  width: 48,
                                                  fit: BoxFit.cover)),
                                          backgroundColor: Colors.transparent,
                                        )
                                      : CircleAvatar(
                                          backgroundColor:
                                              Colors.purple.shade500,
                                          radius: 24,
                                          child: Icon(Icons.person,
                                              color: Colors.purple.shade100,
                                              size: 24.0),
                                        ),
                                )),
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
                            getCustomerTransactionsTotalWidget(customer.id),
                          ],
                        ),
                      ),
                    ),
                    snapshot.data.length - 1 != itemIndex
                        ? Divider(
                            color: Colors.grey.shade300,
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
