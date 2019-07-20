import 'package:flutter/material.dart';
import 'package:simple_khata/blocs/customerBloc.dart';
import 'package:simple_khata/blocs/transactionBloc.dart';
import 'package:simple_khata/models/transaction.dart';
import 'package:simple_khata/pages/addTransaction.dart';

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
    return StreamBuilder(
        stream: transactionBloc.transactions,
        builder:
            (BuildContext context, AsyncSnapshot<List<Transaction>> snapshot) {
          if (snapshot.hasData) {
            return snapshot.data.length != 0
                ? ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, itemIndex) {
                      Transaction transaction = snapshot.data[itemIndex];

                      return Padding(
                        padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.fromLTRB(4, 2, 16, 2),
                                  child: transaction.ttype == 'credit'
                                      ? CircleAvatar(
                                          backgroundColor:
                                              Colors.orange.shade600,
                                          child: Icon(
                                            Icons.arrow_downward,
                                            color: Colors.orange.shade100,
                                            size: 20.0,
                                          ),
                                        )
                                      : transaction.ttype == 'payment'
                                          ? CircleAvatar(
                                              backgroundColor:
                                                  Colors.green.shade600,
                                              child: Icon(
                                                Icons.arrow_upward,
                                                color: Colors.green.shade100,
                                                size: 20.0,
                                              ),
                                            )
                                          : null,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        transaction.comment,
                                        softWrap: true,
                                        textAlign: TextAlign.left,
                                      ),
                                      getTransactionCustomer(transaction.uid),
                                    ],
                                  ),
                                ),
                                Text("\$ " + transaction.amount.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
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
                                : Container(),
                          ],
                        ),
                      );
                    },
                  )
                : Container();
          }
          return Container();
        });
  }

  Widget getTransactionCustomer(int id) {
    return FutureBuilder<dynamic>(
        future: customerBloc.getCustomer(id),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
              child: Text(snapshot.data.name.toString(),
                  style: TextStyle(
                    color: Colors.black54,
                  )),
            );
          }
          return Container(
            child: Text(""),
          );
        });
  }
}
