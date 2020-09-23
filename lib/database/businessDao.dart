import 'dart:async';

import 'package:udharokhata/database/database.dart';
import 'package:udharokhata/models/business.dart';

class BusinessDao {
  final dbProvider = DatabaseProvider.dbProvider;

  Future<int> createBusiness(Business business) async {
    final db = await dbProvider.database;
    var result = db.insert(businessTABLE, business.toDatabaseJson());
    return result;
  }

  Future<List<Business>> getBusinesss(
      {List<String> columns, String query, int page}) async {
    final db = await dbProvider.database;

    List<Map<String, dynamic>> result;
    if (query != null) {
      if (query.isNotEmpty)
        result = await db.query(
          businessTABLE,
          columns: columns,
          where: 'name LIKE ?',
          whereArgs: ["%$query%"],
        );
    } else {
      result = await db.query(businessTABLE, columns: columns);
    }

    List<Business> businesss = result.isNotEmpty
        ? result.map((item) => Business.fromDatabaseJson(item)).toList()
        : [];
    return businesss;
  }

  Future<Business> getBusiness(int id) async {
    final db = await dbProvider.database;
    List<Map> maps =
        await db.query(businessTABLE, where: 'id = ?', whereArgs: [id]);
    Business business =
        maps.length > 0 ? Business.fromDatabaseJson(maps.first) : null;
    return business;
  }

  Future<int> updateBusiness(Business business) async {
    final db = await dbProvider.database;

    var result = await db.update(businessTABLE, business.toDatabaseJson(),
        where: "id = ?", whereArgs: [business.id]);
    return result;
  }

  Future<int> deleteBusiness(int id) async {
    final db = await dbProvider.database;
    var result =
        await db.delete(businessTABLE, where: 'id = ?', whereArgs: [id]);

    return result;
  }
}
