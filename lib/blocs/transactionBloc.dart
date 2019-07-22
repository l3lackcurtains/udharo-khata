import 'dart:async';

import 'package:simple_khata/database/transactionRepo.dart';
import 'package:simple_khata/models/transaction.dart';

class TransactionBloc {
  final _transactionRepository = TransactionRepository();

  final _transactionController =
      StreamController<List<Transaction>>.broadcast();

  Stream<List<Transaction>> get transactions => _transactionController.stream;

  TransactionBloc() {
    getTransactions();
  }

  getTransactions({String query}) async {
    final List<Transaction> transactions =
        await _transactionRepository.getAllTransactions(query: query);
    _transactionController.sink.add(transactions);
    return transactions;
  }

  getTransaction(int id) async {
    final Transaction transaction =
        await _transactionRepository.getTransaction(id);
    return transaction;
  }

  getTransactionsByCustomerId(int cid) async {
    final List<Transaction> transactions =
        await _transactionRepository.getAllTransactionsByCustomerId(cid);
    return transactions;
  }

  addTransaction(Transaction transaction) async {
    await _transactionRepository.insertTransaction(transaction);
    getTransactions();
  }

  updateTransaction(Transaction transaction) async {
    await _transactionRepository.updateTransaction(transaction);
    getTransactions();
  }

  deleteTransactionById(int id) async {
    _transactionRepository.deleteTransactionById(id);
    getTransactions();
  }

  dispose() {
    _transactionController.close();
  }
}
