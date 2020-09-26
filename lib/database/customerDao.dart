import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:udharokhata/database/database.dart';
import 'package:udharokhata/models/customer.dart';

class CustomerDao {
  final dbProvider = DatabaseProvider.dbProvider;

  Future<int> createCustomer(Customer customer) async {
    final db = await dbProvider.database;
    var result = db.insert(customerTABLE, customer.toDatabaseJson());
    return result;
  }

  Future<List<Customer>> getCustomers(
      {List<String> columns, String query, int page}) async {
    final db = await dbProvider.database;

    List<Map<String, dynamic>> result;

    // get Business ID
    final prefs = await SharedPreferences.getInstance();
    int selectedBusinessId = prefs.getInt('selected_business') != null
        ? prefs.getInt('selected_business')
        : 0;

    if (query == null || query == "") {
      result = await db.query(customerTABLE,
          columns: columns,
          where: 'businessId = ?',
          whereArgs: [selectedBusinessId],
          orderBy: 'id DESC');
    } else {
      result = await db.query(
        customerTABLE,
        columns: columns,
        where: 'businessId = ? AND name LIKE ?',
        whereArgs: [selectedBusinessId, "%$query%"],
      );
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
    return result;
  }

  Future<int> deleteCustomer(int id) async {
    final db = await dbProvider.database;
    var result =
        await db.delete(customerTABLE, where: 'id = ?', whereArgs: [id]);
    return result;
  }
}
