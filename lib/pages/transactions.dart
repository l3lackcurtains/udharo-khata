import 'package:flutter/material.dart';
import 'package:simple_khata/blocs/customerBloc.dart';
import 'package:simple_khata/blocs/transactionBloc.dart';
import 'package:simple_khata/helpers/conversion.dart';
import 'package:simple_khata/models/customer.dart';
import 'package:simple_khata/models/transaction.dart';
import 'package:simple_khata/pages/addTransaction.dart';
import 'package:simple_khata/pages/singleTransaction.dart';

class SingleTransactionScreenArguments {
  final int transactionId;

  SingleTransactionScreenArguments(this.transactionId);
}

class Transactions extends StatefulWidget {
  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  final TransactionBloc transactionBloc = TransactionBloc();
  final CustomerBloc customerBloc = CustomerBloc();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: getTransactionsList()),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTransaction()),
          );
        },
        icon: Icon(Icons.add),
        label: Text('Add Transaction'),
      ),
    );
  }

  Widget getTransactionsList() {
    return FutureBuilder(
        future: transactionBloc.getTransactions(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return snapshot.data.length != 0
                ? ListView.builder(
                    padding: EdgeInsets.fromLTRB(0, 16, 0, 60),
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, itemIndex) {
                      Transaction transaction = snapshot.data[itemIndex];

                      return Column(
                        children: <Widget>[
                          FlatButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SingleTransaction(),
                                  settings: RouteSettings(
                                    arguments: SingleTransactionScreenArguments(
                                      transaction.id,
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: getTransactionWithCustomer(transaction),
                          ),
                          snapshot.data.length - 1 != itemIndex
                              ? Divider(
                                  color: Colors.grey.shade300,
                                  height: 2,
                                )
                              : Container(),
                        ],
                      );
                    },
                  )
                : Container();
          }
          return Container();
        });
  }

  Widget getTransactionWithCustomer(Transaction transaction) {
    return FutureBuilder(
        future: customerBloc.getCustomer(transaction.uid),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            Customer customer = snapshot.data;
            return Padding(
              padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
                    child: CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      radius: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "${transaction.date.day}",
                            style: TextStyle(
                              color: Colors.deepPurple.shade900,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "${convertNumberToMonth(transaction.date.month)}",
                            style:
                                TextStyle(color: Colors.black87, fontSize: 11),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
                              child: Text(customer.name,
                                  style: TextStyle(
                                      color: Colors.black87, fontSize: 16)),
                            ),
                          ],
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Text(
                            transaction.comment,
                            softWrap: true,
                            textAlign: TextAlign.left,
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Row(children: <Widget>[
                        Text(transaction.amount.abs().toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        transaction.ttype == 'payment'
                            ? Icon(
                                Icons.arrow_downward,
                                color: Colors.orange.shade900,
                                size: 16.0,
                              )
                            : Icon(
                                Icons.arrow_upward,
                                color: Colors.green.shade900,
                                size: 16.0,
                              ),
                      ]),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                        child: Text(
                          transaction.ttype.toUpperCase(),
                          style: TextStyle(
                              color: Colors.black38,
                              fontSize: 10,
                              letterSpacing: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
          return Container();
        });
  }
}
