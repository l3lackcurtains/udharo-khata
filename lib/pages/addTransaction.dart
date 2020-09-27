import 'dart:convert';
import 'dart:io';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:udharokhata/blocs/customerBloc.dart';
import 'package:udharokhata/blocs/transactionBloc.dart';
import 'package:udharokhata/helpers/appLocalizations.dart';
import 'package:udharokhata/helpers/conversion.dart';
import 'package:udharokhata/helpers/stateNotifier.dart';
import 'package:udharokhata/models/customer.dart';
import 'package:udharokhata/models/transaction.dart';
import 'package:udharokhata/pages/singleCustomer.dart';

class AddTransaction extends StatefulWidget {
  final Customer customer;
  final String transType;
  AddTransaction(this.customer, this.transType, {Key key}) : super(key: key);
  @override
  _AddTransactionState createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  String _transType = "credit";
  AutoCompleteTextField searchTextField;

  final TransactionBloc transactionBloc = TransactionBloc();
  final CustomerBloc customerBloc = CustomerBloc();

  String _comment, _customerName;
  int _customerId;
  double _amount;
  DateTime _date = new DateTime.now();
  File _attachment;
  final picker = ImagePicker();

  Transaction transaction = Transaction();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<AutoCompleteTextFieldState> _customerSuggestionKey =
      GlobalKey();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    String dateNow = DateFormat("yMMMMd").format(_date);
    setState(() {
      _transType = widget.transType;
      _customerId = widget.customer.id;
      _customerName = widget.customer.name;

      if (_transType == "credit") {
        _comment = "Credit given on " + dateNow;
      } else if (_transType == "payment") {
        _comment = "Payment received on " + dateNow;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    String lang =
        Provider.of<AppStateNotifier>(context, listen: false).appLocale;

    if (lang == 'ne') {
      NepaliDateTime _nepaliDateTime = await showMaterialDatePicker(
        context: context,
        initialDate: _date.toNepaliDateTime(),
        firstDate: NepaliDateTime(2000),
        lastDate: NepaliDateTime(2090),
        initialDatePickerMode: DatePickerMode.day,
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: Theme.of(context).accentColor,
                onPrimary: Colors.white,
                surface: Colors.green.shade500,
                onSurface: Colors.white,
              ),
              dialogBackgroundColor: Theme.of(context).primaryColor,
            ),
            child: child,
          );
        },
      );

      if (_nepaliDateTime != null) {
        final DateTime picked = _nepaliDateTime.toDateTime();
        setState(() {
          _date = picked.subtract(new Duration(days: 1));
        });
      }
    } else {
      final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2030, 8),
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: Theme.of(context).accentColor,
                onPrimary: Colors.white,
                surface: Colors.green.shade500,
                onSurface: Colors.white,
              ),
              dialogBackgroundColor: Theme.of(context).primaryColor,
            ),
            child: child,
          );
        },
      );
      if (picked != null && picked != _date)
        setState(() {
          _date = picked;
        });
    }
  }

  Future getImageFrom(String from) async {
    var image;
    if (from == 'camera') {
      image = await picker.getImage(source: ImageSource.camera);
    } else {
      image = await picker.getImage(source: ImageSource.gallery);
    }
    if (image != null) {
      setState(() {
        _attachment = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: customerBloc.getCustomers(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            dynamic customers = snapshot.data;

            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: Colors.white,
              appBar: AppBar(
                elevation: 0.0,
                backgroundColor: Colors.transparent,
                title: Text(
                  AppLocalizations.of(context).translate('addTransaction'),
                  style: TextStyle(color: Colors.black),
                ),
                iconTheme: IconThemeData(
                  color: Colors.black,
                ),
              ),
              floatingActionButton: FloatingActionButton.extended(
                  onPressed: () {
                    addTransaction();
                  },
                  icon: Icon(Icons.check),
                  label: Text(
                      AppLocalizations.of(context).translate('addTransaction')),
                  heroTag: _transType),
              body: SingleChildScrollView(
                child: Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 48),
                    padding: EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  ActionChip(
                                      backgroundColor: _transType == "credit"
                                          ? Colors.green.shade500
                                          : Colors.grey.shade200,
                                      avatar: CircleAvatar(
                                        backgroundColor: Colors.grey.shade200,
                                        child: Icon(
                                          Icons.send,
                                          color: Colors.blueAccent,
                                          size: 16.0,
                                        ),
                                      ),
                                      label: Text(AppLocalizations.of(context)
                                          .translate('creditGiven')),
                                      onPressed: () {
                                        setState(() {
                                          _transType = "credit";
                                        });
                                      })
                                ],
                              ),
                              Padding(padding: EdgeInsets.all(8.0)),
                              Column(
                                children: <Widget>[
                                  ActionChip(
                                      backgroundColor: _transType == "payment"
                                          ? Colors.green.shade500
                                          : Colors.grey.shade200,
                                      avatar: CircleAvatar(
                                        backgroundColor: Colors.grey.shade200,
                                        child: Icon(
                                          Icons.receipt,
                                          color: Colors.redAccent,
                                          size: 16.0,
                                        ),
                                      ),
                                      label: Text(AppLocalizations.of(context)
                                          .translate('paymentReceived')),
                                      onPressed: () {
                                        setState(() {
                                          _transType = "payment";
                                        });
                                      })
                                ],
                              )
                            ],
                          ),
                          widget.customer != null
                              ? Row(children: <Widget>[
                                  Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(4, 16, 4, 16),
                                      child: Text(_customerName,
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 18)))
                                ])
                              : searchTextField = AutoCompleteTextField(
                                  key: _customerSuggestionKey,
                                  clearOnSubmit: false,
                                  suggestions: customers,
                                  decoration: InputDecoration(
                                    icon: Icon(Icons.person),
                                    hintText: AppLocalizations.of(context)
                                        .translate('customerNameLabelMeta'),
                                    labelText: AppLocalizations.of(context)
                                        .translate('customerNameLabel'),
                                  ),
                                  itemFilter: (item, query) {
                                    _customerName = query;
                                    _customerId = null;
                                    return item.name
                                        .toLowerCase()
                                        .startsWith(query.toLowerCase());
                                  },
                                  itemSorter: (a, b) {
                                    return a.name.compareTo(b.name);
                                  },
                                  itemSubmitted: (item) {
                                    setState(() {
                                      searchTextField.textField.controller
                                          .text = item.name;
                                      _customerId = item.id;
                                    });
                                  },
                                  itemBuilder: (context, item) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Text(
                                            item.name,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                          TextFormField(
                            autofocus: true,
                            decoration: InputDecoration(
                              icon: Icon(Icons.monetization_on),
                              hintText: AppLocalizations.of(context)
                                  .translate('transactionAmountLabelMeta'),
                              labelText: AppLocalizations.of(context)
                                  .translate('transactionAmountLabel'),
                            ),
                            autovalidate: false,
                            validator: (input) {
                              if (input.isEmpty) {
                                return AppLocalizations.of(context)
                                    .translate('transactionAmountLabelError');
                              }

                              final isDigitsOnly =
                                  double.tryParse(input) != null;
                              if (isDigitsOnly == null) {
                                return AppLocalizations.of(context)
                                    .translate('transactionAmountErrorNumber');
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            onSaved: (input) => _amount = double.parse(input),
                          ),
                          TextFormField(
                            initialValue: _comment,
                            decoration: InputDecoration(
                              icon: Icon(Icons.comment),
                              hintText: AppLocalizations.of(context)
                                  .translate('transactionCommentLabelMeta'),
                              labelText: AppLocalizations.of(context)
                                  .translate('transactionCommentLabel'),
                            ),
                            autovalidate: false,
                            maxLines: 3,
                            onSaved: (input) => _comment = input,
                          ),
                          Padding(
                              padding: EdgeInsets.fromLTRB(0, 24, 8, 24),
                              child: FlatButton.icon(
                                color: Colors.grey.shade200,
                                icon: Icon(
                                  Icons.calendar_today,
                                  color: Colors.grey.shade600,
                                ),
                                label: Text(formatDate(
                                    Provider.of<AppStateNotifier>(context,
                                            listen: false)
                                        .appLocale,
                                    _date)['full']),
                                onPressed: () {
                                  _selectDate(context);
                                },
                              )),
                          transactionAttachmentWidget(),
                        ],
                      ),
                    )),
              ),
            );
          }

          return Container();
        });
  }

  Widget transactionAttachmentWidget() {
    return Row(
      children: <Widget>[
        Expanded(
          child: _attachment == null
              ? Image(
                  image: AssetImage('assets/images/no_image.jpg'),
                )
              : Image.file(
                  _attachment,
                ),
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: FlatButton(
            onPressed: () {
              showUploadDialog();
            },
            child: Text(AppLocalizations.of(context)
                .translate('transactionImageLabel')),
          ),
        )
      ],
    );
  }

  void showUploadDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
              AppLocalizations.of(context).translate('transactionImageLabel')),
          children: <Widget>[
            SimpleDialogOption(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  AppLocalizations.of(context).translate('uploadFromCamera'),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                getImageFrom('camera');
              },
            ),
            SimpleDialogOption(
              child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(AppLocalizations.of(context)
                      .translate('uploadFromGallery'))),
              onPressed: () {
                Navigator.of(context).pop();
                getImageFrom('gallery');
              },
            ),
          ],
        );
      },
    );
  }

  void addTransaction() async {
    final formState = _formKey.currentState;

    if (formState.validate()) {
      formState.save();

      if (_customerId == null) {
        final snackBar = SnackBar(
            content: Row(children: <Widget>[
          Icon(
            Icons.warning,
            color: Colors.redAccent,
          ),
          Padding(
              padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
              child: Text(AppLocalizations.of(context)
                  .translate('customerSelectionLabel')))
        ]));
        _scaffoldKey.currentState.showSnackBar(snackBar);
        return;
      }

      // More Validation
      if (_attachment != null && _attachment.lengthSync() > 2000000) {
        final snackBar = SnackBar(
            content: Row(children: <Widget>[
          Icon(
            Icons.warning,
            color: Colors.redAccent,
          ),
          Padding(
              padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
              child: Text(
                  AppLocalizations.of(context).translate('imageSizeError')))
        ]));
        _scaffoldKey.currentState.showSnackBar(snackBar);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      int selectedBusinessId = prefs.getInt('selected_business');

      transaction.businessId = selectedBusinessId;

      transaction.ttype = _transType;
      transaction.amount = _amount;
      transaction.comment = _comment;
      transaction.date = _date;

      if (_attachment != null) {
        String base64Image = base64Encode(_attachment.readAsBytesSync());
        transaction.attachment = base64Image;
      }

      if (_customerId != null) {
        transaction.uid = _customerId;
        await transactionBloc.addTransaction(transaction);
      }
      Navigator.of(context).pop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SingleCustomer(_customerId),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
