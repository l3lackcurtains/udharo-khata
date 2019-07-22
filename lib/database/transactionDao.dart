import 'dart:async';

import 'package:simple_khata/database/transactionDb.dart';
import 'package:simple_khata/models/transaction.dart';

class TransactionDao {
  final dbProvider = TransactionDatabaseProvider.dbProvider;

  Future<int> createTransaction(Transaction transaction) async {
    final db = await dbProvider.database;
    var result = db.insert(transactionTABLE, transaction.toDatabaseJson());
    return result;
  }

  Future<List<Transaction>> getTransactions(
      {List<String> columns, String query}) async {
    final db = await dbProvider.database;

    List<Map<String, dynamic>> result;
    if (query != null) {
      if (query.isNotEmpty)
        result = await db.query(transactionTABLE, columns: columns);
    } else {
      result = await db.query(transactionTABLE, columns: columns);
    }

    List<Transaction> transactions = result.isNotEmpty
        ? result.map((item) => Transaction.fromDatabaseJson(item)).toList()
        : [];

    return transactions;
  }

  Future<List<Transaction>> getTransactionsByCustomerId(int cid) async {
    final db = await dbProvider.database;

    List<Map> result =
        await db.query(transactionTABLE, where: 'uid = ?', whereArgs: [cid]);

    List<Transaction> transactions = result.isNotEmpty
        ? result.map((item) => Transaction.fromDatabaseJson(item)).toList()
        : [];

    return transactions;
  }

  Future<Transaction> getTransaction(int id) async {
    final db = await dbProvider.database;
    List<Map> maps =
        await db.query(transactionTABLE, where: 'id = ?', whereArgs: [id]);
    if (maps.length > 0) {
      return Transaction.fromDatabaseJson(maps.first);
    }
    return null;
  }

  Future<int> updateTransaction(Transaction transaction) async {
    final db = await dbProvider.database;
    var result = await db.update(transactionTABLE, transaction.toDatabaseJson(),
        where: "id = ?", whereArgs: [transaction.id]);

    return result;
  }

  Future<int> deleteTransaction(int id) async {
    final db = await dbProvider.database;
    var result =
        await db.delete(transactionTABLE, where: 'id = ?', whereArgs: [id]);

    return result;
  }
}
