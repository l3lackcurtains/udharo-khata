import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:simple_khata/blocs/transactionBloc.dart';
import 'package:simple_khata/database/customerRepo.dart';
import 'package:simple_khata/models/customer.dart';
import 'package:simple_khata/models/transaction.dart';

class AddTransaction extends StatefulWidget {
  @override
  _AddTransactionState createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  // Transaction type
  // 0: credit 1: received
  int _transType = 0;
  static List<Customer> customers = new List<Customer>();
  AutoCompleteTextField searchTextField;

  final _customerRepository = CustomerRepository();

  final TransactionBloc transactionBloc = TransactionBloc();
  String _amount, _comment, _customerName;
  int _customer;
  Transaction transaction = Transaction();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<AutoCompleteTextFieldState> _customerSuggestionKey =
      GlobalKey();

  void getCustomers() async {
    try {
      customers = await _customerRepository.getAllCustomers(query: null);
    } catch (e) {
      print("Error getting customers");
      getCustomers();
    }
  }

  @override
  void initState() {
    super.initState();
    getCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Add Transaction',
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
                Padding(padding: EdgeInsets.all(8.0)),
                searchTextField = AutoCompleteTextField(
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
                    _customer = null;
                    return item.name
                        .toLowerCase()
                        .startsWith(query.toLowerCase());
                  },
                  itemSorter: (a, b) {
                    return a.name.compareTo(b.name);
                  },
                  itemSubmitted: (item) {
                    setState(() {
                      searchTextField.textField.controller.text = item.name;
                      _customer = item.id;
                    });
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
                  decoration: const InputDecoration(
                    icon: Icon(Icons.monetization_on),
                    hintText: 'How much is the amount?',
                    labelText: 'Amount',
                  ),
                  autovalidate: false,
                  validator: null,
                ),
                TextFormField(
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
                          addTransaction();
                        },
                        padding: const EdgeInsets.all(16.0),
                        child: const Text('Add'),
                      ),
                    )
                  ],
                )
              ],
            ),
          )),
    );
  }

  void addTransaction() {
    final formState = _formKey.currentState;

    if (formState.validate()) {
      formState.save();
      print(_customer);
      transaction.ttype = _transType == 0 ? 'credit' : 'payment';
      transaction.amount = _amount;
      transaction.comment = _comment;

      transactionBloc.addTransaction(transaction);
      Navigator.pop(context);
    }
  }
}
