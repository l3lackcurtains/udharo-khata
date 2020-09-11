import 'dart:convert';
import 'dart:io';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:udharokhata/blocs/customerBloc.dart';
import 'package:udharokhata/blocs/transactionBloc.dart';
import 'package:udharokhata/models/customer.dart';
import 'package:udharokhata/models/transaction.dart';

class AddTransaction extends StatefulWidget {
  final Function() notifyParent;
  final Customer customer;
  AddTransaction(this.customer, this.notifyParent, {Key key}) : super(key: key);
  @override
  _AddTransactionState createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  // Transaction type
  // 0: credit 1: received
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _date)
      setState(() {
        _date = picked;
      });
  }

  Future getImageFromGallery() async {
    var attachment = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _attachment = File(attachment.path);
    });
  }

  Future getImageFromCamera() async {
    var attachment = await picker.getImage(source: ImageSource.camera);

    setState(() {
      _attachment = File(attachment.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    _customerId = widget.customer.id;
    _customerName = widget.customer.name;

    return FutureBuilder(
        future: customerBloc.getCustomers(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            dynamic customers = snapshot.data;

            return Scaffold(
              key: _scaffoldKey,
              resizeToAvoidBottomPadding: false,
              appBar: AppBar(
                elevation: 0.0,
                backgroundColor: Colors.transparent,
                title: Text(
                  'Add Transaction',
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
                icon: Icon(Icons.add),
                label: Text('Add Transaction'),
              ),
              body: SingleChildScrollView(
                child: Container(
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
                                      label: Text('Credit Given'),
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
                                      label: Text('Payment Received'),
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
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20)))
                                ])
                              : searchTextField = AutoCompleteTextField(
                                  key: _customerSuggestionKey,
                                  clearOnSubmit: false,
                                  suggestions: customers,
                                  decoration: InputDecoration(
                                    icon: Icon(Icons.person),
                                    hintText: 'What is your customer name?',
                                    labelText: 'Customer Name *',
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
                            decoration: InputDecoration(
                              icon: Icon(Icons.monetization_on),
                              hintText: 'How much is the amount?',
                              labelText: 'Amount',
                            ),
                            autovalidate: false,
                            validator: (input) {
                              if (input.isEmpty) {
                                return 'Please insert amount.';
                              }

                              final isDigitsOnly =
                                  double.tryParse(input) != null;
                              if (isDigitsOnly == null) {
                                return 'Input needs to be valid number.';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            onSaved: (input) => _amount = double.parse(input),
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              icon: Icon(Icons.comment),
                              hintText: 'Write comment about the transaction.',
                              labelText: 'Comment *',
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
                                label: Text(
                                    "${_date.day}/${_date.month}/${_date.year}"),
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
                  image: AssetImage('images/no_image.jpg'),
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
            child: Text('Upload Attachment Image'),
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
          title: Text('Upload Attachment Image'),
          children: <Widget>[
            SimpleDialogOption(
              child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Upload from Camera')),
              onPressed: () {
                Navigator.of(context).pop();
                getImageFromCamera();
              },
            ),
            SimpleDialogOption(
              child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Upload from Gallery')),
              onPressed: () {
                Navigator.of(context).pop();
                getImageFromGallery();
              },
            ),
          ],
        );
      },
    );
  }

  void addTransaction() {
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
              child: Text('Select a valid customer.'))
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
              child: Text('Image size is too big. (Max size 2MB)'))
        ]));
        _scaffoldKey.currentState.showSnackBar(snackBar);
        return;
      }

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
        transactionBloc.addTransaction(transaction);
      }
      widget.notifyParent();
      Navigator.pop(context);
    }
  }
}
