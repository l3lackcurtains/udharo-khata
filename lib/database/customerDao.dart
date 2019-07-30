import 'dart:async';

import 'package:simple_khata/database/customerDb.dart';
import 'package:simple_khata/models/customer.dart';

class CustomerDao {
  final dbProvider = CustomerDatabaseProvider.dbProvider;

  Future<int> createCustomer(Customer customer) async {
    final db = await dbProvider.database;
    var result = db.insert(customerTABLE, customer.toDatabaseJson());
    return result;
  }

  Future<List<Customer>> getCustomers(
      {List<String> columns, String query, int page}) async {
    final db = await dbProvider.database;

    List<Map<String, dynamic>> result;
    if (query != null) {
      if (query.isNotEmpty)
        result = await db.query(
          customerTABLE,
          columns: columns,
          where: 'name LIKE ?',
          whereArgs: ["%$query%"],
        );
    } else {
      result = await db.query(customerTABLE, columns: columns);
    }

    List<Customer> customers = result.isNotEmpty
        ? result.map((item) => Customer.fromDatabaseJson(item)).toList()
        : [];
    return customers;
  }

  Future<Customer> getCustomer(int id) async {
    final db = await dbProvider.database;
    List<Map> maps =
        await db.query(customerTABLE, where: 'id = ?', whereArgs: [id]);
    Customer customer =
        maps.length > 0 ? Customer.fromDatabaseJson(maps.first) : null;
    return customer;
  }

  Future<int> updateCustomer(Customer customer) async {
    final db = await dbProvider.database;

    var result = await db.update(customerTABLE, customer.toDatabaseJson(),
        where: "id = ?", whereArgs: [customer.id]);
    print(customer.name);

    return result;
  }

  Future<int> deleteCustomer(int id) async {
    final db = await dbProvider.database;
    var result =
        await db.delete(customerTABLE, where: 'id = ?', whereArgs: [id]);

    return result;
  }
}
