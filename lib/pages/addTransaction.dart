import 'package:flutter/material.dart';
import 'package:simple_khata/blocs/transactionBloc.dart';
import 'package:simple_khata/models/transaction.dart';

class AddTransaction extends StatefulWidget {
  @override
  _AddTransactionState createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  final TransactionBloc transactionBloc = TransactionBloc();
  String _ttype, _amount;
  Transaction transaction = Transaction();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
                TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    hintText: 'What is your customer name?',
                    labelText: 'Customer Name *',
                  ),
                  autovalidate: false,
                  validator: (input) {
                    if (input.isEmpty) {
                      return 'Please type customer name';
                    }
                  },
                  onSaved: (input) => _ttype = input,
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
                  onSaved: (input) => _amount = input,
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
      transaction.ttype = _ttype;
      transaction.amount = _amount;
      transactionBloc.addTransaction(transaction);
      Navigator.pop(context);
    }
  }
}
