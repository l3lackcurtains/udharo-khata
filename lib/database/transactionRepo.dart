import 'package:simple_khata/database/transactionDao.dart';
import 'package:simple_khata/models/transaction.dart';

class TransactionRepository {
  final transactionDao = TransactionDao();

  Future getAllTransactions({String query}) =>
      transactionDao.getTransactions(query: query);

  Future insertTransaction(Transaction transaction) =>
      transactionDao.createTransaction(transaction);

  Future updateTransaction(Transaction transaction) =>
      transactionDao.updateTransaction(transaction);

  Future deleteTransactionById(int id) => transactionDao.deleteTransaction(id);
}
