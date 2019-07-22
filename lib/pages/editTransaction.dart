import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
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
  int _transType = 0;
  static List<Customer> customers = new List<Customer>();

  final _customersField = TextEditingController();

  final TransactionBloc transactionBloc = TransactionBloc();
  final CustomerBloc customerBloc = CustomerBloc();

  String _comment, _customerName;
  int _customer, _amount;

  Transaction transaction = Transaction();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<AutoCompleteTextFieldState> _customerSuggestionKey =
      GlobalKey();

  @override
  Widget build(BuildContext context) {
    final EditTransactionScreenArguments args =
        ModalRoute.of(context).settings.arguments;
    Transaction argTransaction = args.transaction;

    if (!this.mounted) {
      setState(() {
        _transType = argTransaction.ttype == 'credit' ? 0 : 1;
        _customer = argTransaction.uid;
      });
    }

    return FutureBuilder(
        future: customerBloc.getCustomers(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            dynamic customers = snapshot.data;
            if (_customer != null) {
              customers.forEach((item) {
                if (_customer == item.id) {
                  _customerName = item.name;
                  _customersField.text = item.name;
                }
              });
            } else {
              customers.forEach((item) {
                if (argTransaction.uid == item.id) {
                  _customerName = item.name;
                  _customersField.text = item.name;
                }
              });
            }

            return Scaffold(
              resizeToAvoidBottomPadding: false,
              appBar: AppBar(
                elevation: 0.0,
                backgroundColor: Colors.transparent,
                title: const Text(
                  'Edit Transaction',
                  style: TextStyle(color: Colors.black),
                ),
                iconTheme: const IconThemeData(
                  color: Colors.black,
                ),
              ),
              body: Container(
                  decoration: BoxDecoration(color: Colors.white),
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                ActionChip(
                                    backgroundColor: _transType == 0
                                        ? Colors.green.shade600
                                        : Colors.grey.shade300,
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
                                        _transType = 0;
                                      });
                                    })
                              ],
                            ),
                            Padding(padding: EdgeInsets.all(8.0)),
                            Column(
                              children: <Widget>[
                                ActionChip(
                                    backgroundColor: _transType == 1
                                        ? Colors.green.shade600
                                        : Colors.grey.shade300,
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
                                        _transType = 1;
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
                            _customerName = query;
                            _customer = null;

                            return item.name
                                .toLowerCase()
                                .startsWith(query.toLowerCase());
                          },
                          itemSorter: (a, b) {
                            return a.name.compareTo(b.name);
                          },
                          itemSubmitted: (item) {
                            _customersField.text = item.name;
                            _customer = item.id;
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
                          decoration: const InputDecoration(
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
                          initialValue: argTransaction.comment,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.comment),
                            hintText: 'Write comment about the transaction.',
                            labelText: 'Comment *',
                          ),
                          autovalidate: false,
                          maxLines: 3,
                          onSaved: (input) => _comment = input,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(36),
                        ),
                        Row(
                          children: <Widget>[
                            Spacer(),
                            Expanded(
                              child: RaisedButton(
                                textColor: Colors.white,
                                color: Colors.purple,
                                onPressed: () {
                                  editTransaction(argTransaction.id);
                                },
                                padding: const EdgeInsets.all(16.0),
                                child: const Text('Update'),
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

  @override
  void dispose() {
    super.dispose();
    _customersField.dispose();
  }

  void editTransaction(id) {
    final formState = _formKey.currentState;

    if (formState.validate()) {
      formState.save();
      transaction.id = id;
      transaction.ttype = _transType == 0 ? 'credit' : 'payment';
      transaction.amount = _amount;
      transaction.comment = _comment;
      if (_customer != null) {
        transactionBloc.updateTransaction(transaction);
      }

      Navigator.pop(context);
    }
  }
}
