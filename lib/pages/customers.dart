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
import 'package:udharokhata/helpers/generateCustomersPdf.dart';
import 'package:udharokhata/helpers/stateNotifier.dart';
import 'package:udharokhata/models/customer.dart';
import 'package:udharokhata/pages/addCustomer.dart';
import 'package:udharokhata/pages/singleCustomer.dart';

class Customers extends StatefulWidget {
  Customers({Key key}) : super(key: key);
  @override
  _CustomersState createState() => _CustomersState();
}

class _CustomersState extends State<Customers> {
  final TransactionBloc transactionBloc = TransactionBloc();
  final _customerBloc = CustomerBloc();

  final TextEditingController _searchInputController =
      new TextEditingController();

  bool _absorbing = false;
  String _searchText = "";

  Future<List<Customer>> customersList;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: Container(
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  height: 140,
                  decoration:
                      BoxDecoration(color: Theme.of(context).primaryColor),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.picture_as_pdf),
                              color: Colors.red,
                              onPressed: () async {
                                generatePdf();
                              },
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: Card(
                          elevation: 6,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                            child: TextField(
                                controller: _searchInputController,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)
                                      .translate('searchCustomers'),
                                  suffixIcon: _searchText == null
                                      ? Icon(Icons.search)
                                      : IconButton(
                                          icon: Icon(Icons.close),
                                          onPressed: () {
                                            _searchInputController.clear();
                                          },
                                        ),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                                onChanged: (text) {
                                  setState(() {
                                    _searchText = text;
                                  });
                                }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: getCustomersList(),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddCustomer()),
              );
            },
            icon: Icon(Icons.add),
            label: Text(AppLocalizations.of(context).translate('addCustomer')),
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

  void generatePdf() async {
    setState(() {
      _absorbing = true;
    });
    Uint8List pdf = await generateCustomerPdf();
    final dir = await getExternalStorageDirectory();
    final file = File(dir.path + "/report.pdf");
    await file.writeAsBytes(pdf);
    OpenFile.open(file.path);

    setState(() {
      _absorbing = false;
    });
  }

  Widget getCustomersList() {
    return Consumer<AppStateNotifier>(builder: (context, provider, child) {
      return FutureBuilder(
          future: _customerBloc.getCustomers(query: _searchText),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return getCustomerCard(snapshot);
          });
    });
  }

  Widget getCustomerTransactionsTotalWidget(int cid) {
    return FutureBuilder(
        future: transactionBloc.getCustomerTransactionsTotal(cid),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            double total = snapshot.data;
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
                    ttype == "credit"
                        ? AppLocalizations.of(context).translate('given')
                        : AppLocalizations.of(context).translate('received'),
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
                            builder: (context) => SingleCustomer(customer.id),
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
                                  child: customerImage != null &&
                                          customerImage.length > 0
                                      ? CircleAvatar(
                                          radius: 24,
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

  @override
  void dispose() {
    super.dispose();
  }
}
