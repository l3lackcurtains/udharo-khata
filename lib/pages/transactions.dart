import 'package:flutter/material.dart';
import 'package:simple_khata/blocs/customerBloc.dart';
import 'package:simple_khata/blocs/transactionBloc.dart';
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
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
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
                                  color: Colors.grey.shade500,
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
              padding: EdgeInsets.fromLTRB(0, 8, 4, 8),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 4, 12, 4),
                    child: transaction.ttype == 'payment'
                        ? CircleAvatar(
                            backgroundColor: Colors.orange.shade100,
                            child: Icon(
                              Icons.arrow_downward,
                              color: Colors.orange.shade900,
                              size: 20.0,
                            ),
                          )
                        : transaction.ttype == 'credit'
                            ? CircleAvatar(
                                backgroundColor: Colors.green.shade100,
                                child: Icon(
                                  Icons.arrow_upward,
                                  color: Colors.green.shade900,
                                  size: 20.0,
                                ),
                              )
                            : null,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Text(customer.name.toString(),
                                  style: TextStyle(
                                      color: Colors.black87, fontSize: 16)),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                              child: Text(
                                  "${transaction.date.day}/${transaction.date.month}/${transaction.date.year}",
                                  style: TextStyle(
                                      color: Colors.black45, fontSize: 14)),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
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
                  Padding(
                    padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: Text(transaction.amount.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ],
              ),
            );
          }
          return Container();
        });
  }
}
