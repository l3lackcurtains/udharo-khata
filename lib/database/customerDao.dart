import 'dart:async';

import 'package:simple_khata/database/customerDb.dart';
import 'package:simple_khata/models/customer.dart';

class CustomerDao {
  final dbProvider = CustomerDatabaseProvider.dbProvider;

  // Adds new Customer records
  Future<int> createCustomer(Customer customer) async {
    final db = await dbProvider.database;
    var result = db.insert(customerTABLE, customer.toDatabaseJson());
    return result;
  }

  // Get All Customer items & Searches if query string was passed
  Future<List<Customer>> getCustomers(
      {List<String> columns, String query}) async {
    final db = await dbProvider.database;

    List<Map<String, dynamic>> result;
    if (query != null) {
      if (query.isNotEmpty)
        result = await db.query(customerTABLE,
            columns: columns,
            where: 'description LIKE ?',
            whereArgs: ["%$query%"]);
    } else {
      result = await db.query(customerTABLE, columns: columns);
    }

    List<Customer> customers = result.isNotEmpty
        ? result.map((item) => Customer.fromDatabaseJson(item)).toList()
        : [];
    return customers;
  }

  // Update Customer record
  Future<int> updateCustomer(Customer customer) async {
    final db = await dbProvider.database;

    var result = await db.update(customerTABLE, customer.toDatabaseJson(),
        where: "id = ?", whereArgs: [customer.id]);

    return result;
  }

  // Delete Customer records
  Future<int> deleteCustomer(int id) async {
    final db = await dbProvider.database;
    var result =
        await db.delete(customerTABLE, where: 'id = ?', whereArgs: [id]);

    return result;
  }
}
