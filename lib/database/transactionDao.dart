import 'dart:async';

import 'package:simple_khata/database/transactionDb.dart';
import 'package:simple_khata/models/transaction.dart';

class TransactionDao {
  final dbProvider = TransactionDatabaseProvider.dbProvider;

  // Adds new Transaction records
  Future<int> createTransaction(Transaction transaction) async {
    final db = await dbProvider.database;
    var result = db.insert(transactionTABLE, transaction.toDatabaseJson());
    return result;
  }

  // Get All Transaction items & Searches if query string was passed
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

  // Get transaction by ID
  Future<Transaction> getTransaction(int id) async {
    final db = await dbProvider.database;
    List<Map> maps =
        await db.query(transactionTABLE, where: 'id = ?', whereArgs: [id]);
    if (maps.length > 0) {
      return Transaction.fromDatabaseJson(maps.first);
    }
    return null;
  }

  // Update Transaction record
  Future<int> updateTransaction(Transaction transaction) async {
    final db = await dbProvider.database;

    var result = await db.update(transactionTABLE, transaction.toDatabaseJson(),
        where: "id = ?", whereArgs: [transaction.id]);

    return result;
  }

  // Delete Transaction records
  Future<int> deleteTransaction(int id) async {
    final db = await dbProvider.database;
    var result =
        await db.delete(transactionTABLE, where: 'id = ?', whereArgs: [id]);

    return result;
  }
}
