import 'package:flutter/material.dart';
import 'package:simple_khata/blocs/transactionBloc.dart';
import 'package:simple_khata/models/transaction.dart';

class Transactions extends StatefulWidget {
  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  final TransactionBloc transactionBloc = TransactionBloc();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: getTransactionsList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/addtransaction');
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
                    title: Text('${transaction.ttype}'),
                    subtitle: Text('${transaction.comment}'),
                    trailing: Column(
                      children: <Widget>[
                        Text('-2000'),
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
}
