import 'dart:convert';
import 'dart:io';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_khata/blocs/customerBloc.dart';
import 'package:simple_khata/blocs/transactionBloc.dart';
import 'package:simple_khata/models/customer.dart';
import 'package:simple_khata/models/transaction.dart';

import 'singleCustomer.dart';

class AddTransaction extends StatefulWidget {
  @override
  _AddTransactionState createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  // Transaction type
  // 0: credit 1: received
  String _transType = "credit";
  static List<Customer> customers = new List<Customer>();
  AutoCompleteTextField searchTextField;

  final TransactionBloc transactionBloc = TransactionBloc();
  final CustomerBloc customerBloc = CustomerBloc();

  String _comment, _customerName;
  int _customerId, _amount;
  DateTime _date = new DateTime.now();
  File _attachment;

  Transaction transaction = Transaction();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<AutoCompleteTextFieldState> _customerSuggestionKey =
      GlobalKey();

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
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _attachment = image;
    });
  }

  Future getImageFromCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _attachment = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AddTransactionScreenArguments args =
        ModalRoute.of(context).settings.arguments;

    if (args != null) {
      _customerId = args.customer.id;
      _customerName = args.customer.name;
    }

    return FutureBuilder(
        future: customerBloc.getCustomers(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            dynamic customers = snapshot.data;

            return Scaffold(
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
              body: Container(
                  decoration: BoxDecoration(color: Colors.white),
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
                        args != null
                            ? Row(children: <Widget>[
                                Padding(
                                    padding: EdgeInsets.fromLTRB(4, 16, 4, 16),
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
                                    searchTextField.textField.controller.text =
                                        item.name;
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
                          validator: null,
                          keyboardType: TextInputType.number,
                          onSaved: (input) => _amount = int.parse(input),
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
                        Row(
                          children: <Widget>[
                            Spacer(),
                            Expanded(
                              child: RaisedButton(
                                textColor: Colors.white,
                                color: Colors.purple,
                                onPressed: () {
                                  addTransaction();
                                },
                                padding: EdgeInsets.all(16.0),
                                child: Text('Add'),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  )),
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
      Navigator.pop(context);
    }
  }
}
