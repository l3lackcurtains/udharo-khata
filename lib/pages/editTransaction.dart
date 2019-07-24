import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_khata/blocs/customerBloc.dart';
import 'package:simple_khata/blocs/transactionBloc.dart';
import 'package:simple_khata/models/customer.dart';
import 'package:simple_khata/models/transaction.dart';

import 'singleTransaction.dart';

class EditTransaction extends StatefulWidget {
  @override
  _EditTransactionState createState() => _EditTransactionState();
}

class _EditTransactionState extends State<EditTransaction> {
  // Transaction type
  // 0: credit 1: received
  String _transType = "credit";
  static List<Customer> customers = new List<Customer>();

  final _customersField = TextEditingController();

  final TransactionBloc transactionBloc = TransactionBloc();
  final CustomerBloc customerBloc = CustomerBloc();

  String _comment;
  int _customerId, _amount;
  DateTime _date;
  File _attachment;

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
  void didChangeDependencies() {
    final EditTransactionScreenArguments args =
        ModalRoute.of(context).settings.arguments;
    Transaction argTransaction = args.transaction;
    _customerId = argTransaction.uid;
    _transType = argTransaction.ttype;
    _date = argTransaction.date;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final EditTransactionScreenArguments args =
        ModalRoute.of(context).settings.arguments;
    Transaction argTransaction = args.transaction;

    return FutureBuilder(
        future: customerBloc.getCustomers(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            dynamic customers = snapshot.data;
            if (_customerId != null) {
              customers.forEach((item) {
                if (_customerId == item.id) {
                  _customersField.text = item.name;
                }
              });
            } else {
              customers.forEach((item) {
                if (argTransaction.uid == item.id) {
                  _customersField.text = item.name;
                }
              });
            }

            return Scaffold(
              key: _scaffoldKey,
              resizeToAvoidBottomPadding: false,
              appBar: AppBar(
                elevation: 0.0,
                backgroundColor: Colors.transparent,
                title: Text(
                  'Edit Transaction',
                  style: TextStyle(color: Colors.black),
                ),
                iconTheme: IconThemeData(
                  color: Colors.black,
                ),
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () {
                  updateTransaction(argTransaction.id);
                },
                icon: Icon(Icons.check),
                label: Text('Update Transaction'),
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
                        AutoCompleteTextField(
                          key: _customerSuggestionKey,
                          clearOnSubmit: false,
                          suggestions: customers,
                          controller: _customersField,
                          decoration: InputDecoration(
                            icon: Icon(Icons.person),
                            hintText: 'What is your customer name?',
                            labelText: 'Customer Name *',
                          ),
                          itemFilter: (item, query) {
                            _customerId = null;

                            return item.name
                                .toLowerCase()
                                .startsWith(query.toLowerCase());
                          },
                          itemSorter: (a, b) {
                            return a.name.compareTo(b.name);
                          },
                          itemSubmitted: (item) {
                            _customersField.text = item.name;
                            _customerId = item.id;
                          },
                          itemBuilder: (context, item) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          initialValue: argTransaction.amount.toString(),
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

                            final isDigitsOnly = int.tryParse(input);
                            if (isDigitsOnly == null) {
                              return 'Input needs to be valid number.';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          onSaved: (input) => _amount = int.parse(input),
                        ),
                        TextFormField(
                          initialValue: argTransaction.comment,
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
                        transactionAttachmentWidget(argTransaction.attachment),
                      ],
                    ),
                  )),
            );
          }
          return Container();
        });
  }

  Widget transactionAttachmentWidget(String image) {
    Uint8List transactionAttachment;
    if (image != null) {
      transactionAttachment = Base64Decoder().convert(image);
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: _attachment == null
              ? transactionAttachment == null
                  ? Image(
                      image: AssetImage('images/no_image.jpg'),
                    )
                  : Image.memory(
                      transactionAttachment,
                      width: 60,
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

  @override
  void dispose() {
    super.dispose();
    _customersField.dispose();
  }

  void updateTransaction(id) {
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

      Transaction transaction = Transaction();
      transaction.id = id;
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
        transactionBloc.updateTransaction(transaction);
      }

      Navigator.pop(context);
    }
  }
}
