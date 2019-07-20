import 'package:flutter/material.dart';
import 'package:simple_khata/blocs/customerBloc.dart';
import 'package:simple_khata/blocs/transactionBloc.dart';
import 'package:simple_khata/models/customer.dart';
import 'package:simple_khata/models/transaction.dart';
import 'package:simple_khata/pages/addTransaction.dart';

class Transactions extends StatefulWidget {
  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  final TransactionBloc transactionBloc = TransactionBloc();
  final CustomerBloc customerBloc = CustomerBloc();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: getTransactionsList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTransaction()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),
    );
  }

  Widget getTransactionsList() {
    return StreamBuilder(
        stream: transactionBloc.transactions,
        builder:
            (BuildContext context, AsyncSnapshot<List<Transaction>> snapshot) {
          return getTransactionCard(snapshot);
        });
  }

  Widget getTransactionCard(AsyncSnapshot<List<Transaction>> snapshot) {
    if (snapshot.hasData) {
      return snapshot.data.length != 0
          ? ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, itemIndex) {
                Transaction transaction = snapshot.data[itemIndex];
                return ListTile(
                    dense: true,
                    onTap: () {},
                    title: Text('${transaction.comment}'),
                    subtitle: Text(transaction.ttype),
                    trailing: Column(
                      children: <Widget>[
                        RaisedButton(
                          child: const Text('Delete'),
                          onPressed: () {
                            transactionBloc
                                .deleteTransactionById(transaction.id);
                          },
                        )
                      ],
                    ));
              },
            )
          : Container();
    } else {
      return Container();
    }
  }

  Widget getTransactionCustomer(int id) {
    Customer customer = customerBloc.getCustomer(id);
    return Text(customer.name);
  }
}
