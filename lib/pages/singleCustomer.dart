import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:udharokhata/blocs/customerBloc.dart';
import 'package:udharokhata/blocs/transactionBloc.dart';
import 'package:udharokhata/helpers/appLocalizations.dart';
import 'package:udharokhata/helpers/conversion.dart';
import 'package:udharokhata/helpers/generateCustomerTransaction.dart';
import 'package:udharokhata/helpers/stateNotifier.dart';
import 'package:udharokhata/main.dart';
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

  void _showDeleteDialog(customer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('deleteCustomer')),
          content: Text(
              AppLocalizations.of(context).translate('deleteCustomerLabel')),
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
                customerBloc.deleteCustomerById(customer.id);
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(),
                  ),
                );
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
            if (customer.image != null && customer.image != "") {
              customerImage = Base64Decoder().convert(customer.image);
            }

            return Stack(
              children: [
                Scaffold(
                  resizeToAvoidBottomPadding: true,
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
                        padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
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
                                      backgroundColor: Colors.purple.shade500,
                                      radius: 40,
                                      child: Icon(Icons.person,
                                          color: Colors.purple.shade100,
                                          size: 40.0),
                                    ),
                            ),
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
                        padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              child: getCustomerTransactionsTotalWidget(
                                  widget.customerId),
                            ),
                            Row(
                              children: [
                                FlatButton.icon(
                                  onPressed: () {},
                                  icon: Icon(Icons.share,
                                      size: 20.0, color: Colors.green),
                                  label: Text(AppLocalizations.of(context)
                                      .translate('shareText')),
                                ),
                                FlatButton.icon(
                                  onPressed: () {
                                    generatePdf();
                                  },
                                  icon: Icon(Icons.picture_as_pdf,
                                      size: 20.0, color: Colors.blue),
                                  label: Text(AppLocalizations.of(context)
                                      .translate('exportText')),
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
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerDocked,
                  floatingActionButton: Container(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        FloatingActionButton.extended(
                            icon: Icon(
                              Icons.arrow_upward,
                              size: 18,
                            ),
                            backgroundColor: Colors.red.shade800,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddTransaction(customer, "credit"),
                                ),
                              );
                            },
                            label: Text(
                              AppLocalizations.of(context)
                                  .translate('creditGiven'),
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            heroTag: "credit"),
                        FloatingActionButton.extended(
                            icon: Icon(
                              Icons.arrow_downward,
                              size: 18,
                            ),
                            backgroundColor: Colors.green.shade800,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddTransaction(customer, "payment"),
                                ),
                              );
                            },
                            label: Text(
                                AppLocalizations.of(context)
                                    .translate('paymentReceived'),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14)),
                            heroTag: "payment"),
                      ],
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
            String ttype = "payment";
            if (total.isNegative) {
              ttype = "credit";
            }
            if (total == 0) return Container();
            return Chip(
              backgroundColor: Colors.teal.shade100,
              label: Row(mainAxisAlignment: MainAxisAlignment.end, children: <
                  Widget>[
                Text(amountFormat(total.abs()),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ttype == 'payment' ? Colors.black : Colors.red)),
                Padding(
                  padding: EdgeInsets.fromLTRB(4, 6, 4, 2),
                  child: Text(
                    ttype == "credit"
                        ? AppLocalizations.of(context).translate('given')
                        : AppLocalizations.of(context).translate('received'),
                    style: TextStyle(
                        color: Colors.black38,
                        fontSize: 12,
                        letterSpacing: 0.3,
                        fontWeight: FontWeight.w800),
                  ),
                )
              ]),
            );
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
                        String lang =
                            Provider.of<AppStateNotifier>(context).appLocale;
                        Map<String, String> dateFromatted =
                            formatDate(lang, transaction.date);
                        return Column(
                          children: <Widget>[
                            FlatButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SingleTransaction(transaction.id),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
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
                                              dateFromatted["day"],
                                              style: TextStyle(
                                                color:
                                                    Colors.deepPurple.shade900,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              dateFromatted['month'],
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
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ConstrainedBox(
                                      constraints: new BoxConstraints(
                                        minWidth: 80,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Row(children: <Widget>[
                                                Text(
                                                    amountFormat(transaction
                                                        .amount
                                                        .abs()),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                        color:
                                                            transaction.ttype ==
                                                                    'payment'
                                                                ? Colors.black
                                                                : Colors.red)),
                                              ]),
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 4, 0, 0),
                                                child: Text(
                                                  transaction.ttype == "credit"
                                                      ? AppLocalizations.of(
                                                              context)
                                                          .translate('given')
                                                      : AppLocalizations.of(
                                                              context)
                                                          .translate(
                                                              'received'),
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

  @override
  void dispose() {
    super.dispose();
  }
}
