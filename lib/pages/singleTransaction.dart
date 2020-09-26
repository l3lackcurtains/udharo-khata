import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:udharokhata/blocs/customerBloc.dart';
import 'package:udharokhata/blocs/transactionBloc.dart';
import 'package:udharokhata/helpers/appLocalizations.dart';
import 'package:udharokhata/helpers/conversion.dart';
import 'package:udharokhata/models/customer.dart';
import 'package:udharokhata/models/transaction.dart';
import 'package:udharokhata/pages/singleCustomer.dart';

import 'editTransaction.dart';

class SingleTransaction extends StatefulWidget {
  final int transactionId;
  SingleTransaction(this.transactionId, {Key key}) : super(key: key);
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
        return AlertDialog(
          title:
              Text(AppLocalizations.of(context).translate('deleteTransaction')),
          content: Text(
              AppLocalizations.of(context).translate('deleteTransactionLabel')),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text(AppLocalizations.of(context).translate('closeText')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            RaisedButton(
              color: Colors.red,
              child: Text(
                AppLocalizations.of(context).translate('deleteText'),
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                transactionBloc.deleteTransactionById(transaction.id);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SingleCustomer(transaction.uid),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: transactionBloc.getTransaction(widget.transactionId),
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
                            builder: (context) => EditTransaction(transaction),
                          ),
                        );
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
              body: SingleChildScrollView(
                child: Column(
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
                                          label: Text(
                                              AppLocalizations.of(context)
                                                  .translate('creditGiven')),
                                          backgroundColor:
                                              Colors.orange.shade100,
                                          avatar: Icon(
                                            Icons.arrow_upward,
                                            color: Colors.orange.shade900,
                                            size: 20.0,
                                          ))
                                      : Chip(
                                          label: Text(AppLocalizations.of(
                                                  context)
                                              .translate('paymentReceived')),
                                          backgroundColor:
                                              Colors.orange.shade100,
                                          avatar: Icon(
                                            Icons.arrow_downward,
                                            color: Colors.orange.shade900,
                                            size: 20.0,
                                          )),
                                  Padding(
                                      padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                                      child: Text(
                                          amountFormat(
                                              transaction.amount.abs()),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14)))
                                ],
                              ),
                              Divider(
                                color: Colors.grey.shade300,
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

  @override
  void dispose() {
    super.dispose();
  }
}
