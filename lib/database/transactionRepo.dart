import 'package:udharokhata/database/transactionDao.dart';
import 'package:udharokhata/models/transaction.dart';

class TransactionRepository {
  final transactionDao = TransactionDao();

  Future getAllTransactions({String query}) =>
      transactionDao.getTransactions(query: query);

  Future getTransaction(int id) => transactionDao.getTransaction(id);

  Future getCustomerTransactionsTotal(int id) =>
      transactionDao.getCustomerTransactionsTotal(id);
  Future getBusinessTransactionsTotal(int id) =>
      transactionDao.getBusinessTransactionsTotal(id);

  Future getAllTransactionsByCustomerId(int cid) =>
      transactionDao.getTransactionsByCustomerId(cid);

  Future insertTransaction(Transaction transaction) =>
      transactionDao.createTransaction(transaction);

  Future updateTransaction(Transaction transaction) =>
      transactionDao.updateTransaction(transaction);

  Future deleteTransactionById(int id) => transactionDao.deleteTransaction(id);
}
