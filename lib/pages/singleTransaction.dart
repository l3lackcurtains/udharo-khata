import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:simple_khata/blocs/customerBloc.dart';
import 'package:simple_khata/blocs/transactionBloc.dart';
import 'package:simple_khata/models/customer.dart';
import 'package:simple_khata/models/transaction.dart';

import 'editTransaction.dart';
import 'transactions.dart';

class EditTransactionScreenArguments {
  final Transaction transaction;

  EditTransactionScreenArguments(this.transaction);
}

class AddTransactionScreenArguments {
  final Transaction transaction;

  AddTransactionScreenArguments(this.transaction);
}

class SingleTransaction extends StatefulWidget {
  @override
  _SingleTransactionState createState() => _SingleTransactionState();
}

class _SingleTransactionState extends State<SingleTransaction> {
  final TransactionBloc transactionBloc = TransactionBloc();
  final CustomerBloc customerBloc = CustomerBloc();

  void _showDeleteDialog(transaction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("Delete transaction"),
          content: Text(
              "Deleting action will remove all the transactions associated with the current transaction."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            RaisedButton(
              color: Colors.red,
              child: Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                transactionBloc.deleteTransactionById(transaction.id);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final SingleTransactionScreenArguments args =
        ModalRoute.of(context).settings.arguments;

    return FutureBuilder<dynamic>(
        future: transactionBloc.getTransaction(args.transactionId),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            Transaction transaction = snapshot.data;

            Uint8List transactionAttachment;
            if (transaction.attachment != null) {
              transactionAttachment =
                  Base64Decoder().convert(transaction.attachment);
            }

            return Scaffold(
              resizeToAvoidBottomPadding: false,
              appBar: AppBar(
                  elevation: 0.0,
                  backgroundColor: Colors.transparent,
                  title: null,
                  iconTheme: IconThemeData(
                    color: Colors.black, //change your color here
                  ),
                  actions: <Widget>[
                    // action button
                    IconButton(
                      icon: Icon(Icons.edit, size: 20.0, color: Colors.purple),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditTransaction(),
                                settings: RouteSettings(
                                  arguments: EditTransactionScreenArguments(
                                    transaction,
                                  ),
                                )));
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, size: 20.0, color: Colors.red),
                      onPressed: () {
                        _showDeleteDialog(transaction);
                      },
                    ),
                    // action button
                  ]),
              body: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            getTransactionCustomer(transaction),
                            Row(
                              children: <Widget>[
                                transaction.ttype == 'credit'
                                    ? Chip(
                                        label: Text('Credit Given'),
                                        backgroundColor: Colors.orange.shade100,
                                        avatar: Icon(
                                          Icons.arrow_upward,
                                          color: Colors.orange.shade900,
                                          size: 20.0,
                                        ))
                                    : Chip(
                                        label: Text('Payment Received'),
                                        backgroundColor: Colors.orange.shade100,
                                        avatar: Icon(
                                          Icons.arrow_downward,
                                          color: Colors.orange.shade900,
                                          size: 20.0,
                                        )),
                                Padding(
                                    padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                                    child: Text(transaction.amount.toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)))
                              ],
                            ),
                            Divider(
                              color: Colors.grey.shade500,
                              height: 36,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: Text(
                                transaction.comment,
                                softWrap: true,
                                textAlign: TextAlign.left,
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 36, 0, 36),
                                  child: transactionAttachment != null
                                      ? Image.memory(transactionAttachment,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          fit: BoxFit.cover)
                                      : Container(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return Container();
        });
  }

  Widget getTransactionCustomer(Transaction transaction) {
    return FutureBuilder<dynamic>(
        future: customerBloc.getCustomer(transaction.uid),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            Customer customer = snapshot.data;
            return Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 4, 12, 4),
                  child: CircleAvatar(
                    backgroundColor: Colors.purple.shade500,
                    child: Icon(Icons.person,
                        color: Colors.purple.shade100, size: 20.0),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Text(customer.name,
                          style:
                              TextStyle(color: Colors.black87, fontSize: 16)),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                      child: Text(
                          "${transaction.date.day}/${transaction.date.month}/${transaction.date.year}",
                          style:
                              TextStyle(color: Colors.black45, fontSize: 14)),
                    ),
                  ],
                )
              ],
            );
          }
          return Container(
            child: Text(""),
          );
        });
  }
}
