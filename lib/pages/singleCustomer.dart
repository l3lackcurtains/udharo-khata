import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:udharokhata/blocs/customerBloc.dart';
import 'package:udharokhata/blocs/transactionBloc.dart';
import 'package:udharokhata/helpers/conversion.dart';
import 'package:udharokhata/helpers/generateCustomerTransaction.dart';
import 'package:udharokhata/models/customer.dart';
import 'package:udharokhata/models/transaction.dart';
import 'package:udharokhata/pages/singleTransaction.dart';

import 'addTransaction.dart';
import 'editCustomer.dart';

class SingleCustomer extends StatefulWidget {
  final int customerId;

  SingleCustomer(this.customerId, {Key key}) : super(key: key);
  @override
  _SingleCustomerState createState() => _SingleCustomerState();
}

class _SingleCustomerState extends State<SingleCustomer> {
  final CustomerBloc customerBloc = CustomerBloc();
  final TransactionBloc transactionBloc = TransactionBloc();

  bool _absorbing = false;

  refresh() {
    setState(() {});
  }

  void _showDeleteDialog(customer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("Delete " + customer.name),
          content: Text(
              "Deleting action will remove all the transactions associated with the current customer."),
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
                customerBloc.deleteCustomerById(customer.id);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void generatePdf() async {
    setState(() {
      _absorbing = true;
    });
    Uint8List pdf = await generateCustomerTransactionPdf(widget.customerId);
    final dir = await getExternalStorageDirectory();
    final file = File(dir.path + "/report.pdf");
    await file.writeAsBytes(pdf);
    OpenFile.open(file.path);
    setState(() {
      _absorbing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: customerBloc.getCustomer(widget.customerId),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            Customer customer = snapshot.data;

            Uint8List customerImage;
            if (customer.image != null) {
              customerImage = Base64Decoder().convert(customer.image);
            }

            return Stack(
              children: [
                Scaffold(
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
                          icon: Icon(Icons.edit,
                              size: 20.0, color: Colors.purple),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditCustomer(
                                  customer,
                                  refresh,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon:
                              Icon(Icons.delete, size: 20.0, color: Colors.red),
                          onPressed: () {
                            _showDeleteDialog(customer);
                          },
                        ),
                        // action button
                      ]),
                  body: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Hero(
                                tag: widget.customerId,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                                  child: customerImage != null
                                      ? CircleAvatar(
                                          radius: 40.0,
                                          child: ClipOval(
                                              child: Image.memory(customerImage,
                                                  height: 80,
                                                  width: 80,
                                                  fit: BoxFit.cover)),
                                          backgroundColor: Colors.transparent,
                                        )
                                      : CircleAvatar(
                                          backgroundColor:
                                              Colors.purple.shade500,
                                          radius: 40,
                                          child: Icon(Icons.person,
                                              color: Colors.purple.shade100,
                                              size: 40.0),
                                        ),
                                )),
                            Padding(
                              padding: EdgeInsets.fromLTRB(8, 12, 8, 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
                                    child: Text(
                                      customer.name,
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 20),
                                    ),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.phone,
                                        color: Colors.brown.shade600,
                                        size: 16.0,
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(8, 4, 4, 4),
                                        child: Text(customer.phone),
                                      ),
                                    ],
                                  ),
                                  customer.address != null &&
                                          customer.address.length > 0
                                      ? Row(
                                          children: <Widget>[
                                            Icon(
                                              Icons.location_on,
                                              color: Colors.brown.shade600,
                                              size: 16.0,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  8, 4, 4, 4),
                                              child: Text(customer.address),
                                            ),
                                          ],
                                        )
                                      : Container()
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Chip(
                                  backgroundColor: Colors.green.shade100,
                                  label: getCustomerTransactionsTotalWidget(
                                      widget.customerId)),
                            ),
                            Row(
                              children: [
                                FlatButton.icon(
                                  onPressed: () {},
                                  icon: Icon(Icons.share,
                                      size: 20.0, color: Colors.green),
                                  label: Text("Share"),
                                ),
                                FlatButton.icon(
                                  onPressed: () {
                                    generatePdf();
                                  },
                                  icon: Icon(Icons.picture_as_pdf,
                                      size: 20.0, color: Colors.blue),
                                  label: Text("Export"),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      Expanded(
                          child: getCustomerTransactions(widget.customerId))
                    ],
                  ),
                  bottomNavigationBar: BottomAppBar(
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white10),
                      height: 50,
                      padding: EdgeInsets.all(0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              color: Colors.redAccent,
                              child: FlatButton.icon(
                                icon: Icon(
                                  Icons.arrow_upward,
                                ),
                                padding: EdgeInsets.all(16),
                                onPressed: () {
                                  String transType = "credit";
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddTransaction(
                                          customer, transType, refresh),
                                    ),
                                  );
                                },
                                label: Text(
                                  "Credit Given",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              color: Colors.greenAccent,
                              child: FlatButton.icon(
                                icon: Icon(
                                  Icons.arrow_downward,
                                ),
                                padding: EdgeInsets.all(16),
                                onPressed: () {
                                  String transType = "payment";
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddTransaction(
                                          customer, transType, refresh),
                                    ),
                                  );
                                },
                                label: Text("Payment Received",
                                    style: TextStyle(color: Colors.black)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _absorbing
                    ? AbsorbPointer(
                        absorbing: _absorbing,
                        child: Container(
                          child: Center(child: CircularProgressIndicator()),
                          constraints: BoxConstraints.expand(),
                          color: Colors.white,
                        ),
                      )
                    : Container(),
              ],
            );
          }
          return Container();
        });
  }

  Widget getCustomerTransactionsTotalWidget(int cid) {
    return FutureBuilder(
        future: transactionBloc.getCustomerTransactionsTotal(cid),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            double total = snapshot.data;
            bool neg = false;
            String ttype = "payment";
            if (total.isNegative) {
              neg = true;
              ttype = "credit";
            }
            return Row(children: <Widget>[
              Text(total.abs().toString(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              neg
                  ? Icon(
                      Icons.arrow_upward,
                      color: Colors.green.shade900,
                      size: 18.0,
                    )
                  : Icon(
                      Icons.arrow_downward,
                      color: Colors.orange.shade900,
                      size: 18.0,
                    ),
              Padding(
                padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
                child: Text(
                  ttype.toUpperCase(),
                  style: TextStyle(
                      color: Colors.black38,
                      fontSize: 12,
                      letterSpacing: 0.3,
                      fontWeight: FontWeight.w800),
                ),
              )
            ]);
          }

          return Container();
        });
  }

  Widget getCustomerTransactions(int cid) {
    return FutureBuilder(
        future: transactionBloc.getTransactionsByCustomerId(cid),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData && snapshot.data.length != 0) {
            return Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
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
                                    builder: (context) => SingleTransaction(
                                        transaction.id, refresh),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
                                      child: CircleAvatar(
                                        backgroundColor: Colors.grey.shade200,
                                        radius: 20,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              "${transaction.date.day}",
                                              style: TextStyle(
                                                color:
                                                    Colors.deepPurple.shade900,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              "${convertNumberToMonth(transaction.date.month).substring(0, 3)}",
                                              style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 10),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.9,
                                            padding:
                                                EdgeInsets.fromLTRB(0, 4, 8, 4),
                                            child: Text(
                                              transaction.comment,
                                              softWrap: true,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  color: Colors.black87),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Row(children: <Widget>[
                                          Text(
                                              transaction.amount
                                                  .abs()
                                                  .toString(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
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
                                          padding:
                                              EdgeInsets.fromLTRB(0, 4, 0, 0),
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
                              ),
                            ),
                            snapshot.data.length - 1 != itemIndex
                                ? Divider(
                                    color: Colors.grey.shade300,
                                    height: 2,
                                  )
                                : Container(),
                          ],
                        );
                      }),
                ),
              ],
            );
          }
          return Container();
        });
  }
}
