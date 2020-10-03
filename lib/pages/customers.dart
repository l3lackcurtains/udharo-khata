import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:loading/indicator/ball_beat_indicator.dart';
import 'package:loading/loading.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:udharokhata/blocs/customerBloc.dart';
import 'package:udharokhata/blocs/transactionBloc.dart';
import 'package:udharokhata/helpers/appLocalizations.dart';
import 'package:udharokhata/helpers/constants.dart';
import 'package:udharokhata/helpers/conversion.dart';
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                                child: getBusinessTransactionsTotalWidget()),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 6,
                          semanticContainer: true,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Container(
                            padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                            child: TextField(
                                controller: _searchInputController,
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)
                                      .translate('searchCustomers'),
                                  suffixIcon: _searchText == ""
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
                  child: Container(
                    decoration:
                        BoxDecoration(color: Theme.of(context).primaryColor),
                    child: Transform.translate(
                      offset: Offset(0.0, 10.0),
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(25.0),
                                topLeft: Radius.circular(25.0)),
                            color: Colors.white,
                          ),
                          child: getCustomersList()),
                    ),
                  ),
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
            if (snapshot.hasData) {
              return getCustomerCard(snapshot);
            }
            if (snapshot.hasError) {
              return Container(
                child: Text("Unknown Error."),
              );
            }
            return Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                height: 280,
                child: Loading(
                    indicator: BallBeatIndicator(),
                    size: 60.0,
                    color: Theme.of(context).accentColor));
          });
    });
  }

  Widget getCustomerTransactionsTotalWidget(int cid) {
    String lang = Provider.of<AppStateNotifier>(context).appLocale;
    return FutureBuilder(
        future: transactionBloc.getCustomerTransactionsTotal(cid),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            double total = snapshot.data;
            if (total == 0) return Container();
            String ttype = "payment";
            if (total.isNegative) {
              ttype = "credit";
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Row(children: <Widget>[
                  Text(amountFormat(lang, total.abs()),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: ttype == 'payment'
                              ? xPlainTextGreen
                              : xPlainTextRed)),
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
                            Padding(
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
                                      backgroundColor: Colors.purple.shade500,
                                      radius: 24,
                                      child: Icon(Icons.person,
                                          color: Colors.purple.shade100,
                                          size: 24.0),
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
                                      size: 12.0,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(8, 4, 4, 4),
                                      child: Text(
                                        customer.phone,
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black54,
                                            fontSize: 12),
                                      ),
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

  Widget getBusinessTransactionsTotalWidget() {
    int bid = Provider.of<AppStateNotifier>(context).selectedBusiness;
    if (bid == null) return Container();
    String lang = Provider.of<AppStateNotifier>(context).appLocale;
    return FutureBuilder(
        future: transactionBloc.getBusinessTransactionsTotal(bid),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            double total = snapshot.data;

            String ttype = "payment";
            if (total.isNegative) {
              ttype = "credit";
            }

            return Row(children: <Widget>[
              Text(amountFormat(lang, total.abs()),
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: ttype == 'payment'
                          ? xDarkBlueTextGreen
                          : xDarkBlueTextRed)),
            ]);
          }

          return Container();
        });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
