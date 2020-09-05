import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

final businessTABLE = 'Business';

class BusinessDatabaseProvider {
  static final BusinessDatabaseProvider dbProvider = BusinessDatabaseProvider();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await createDatabase();
    return _database;
  }

  createDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'business.db');
    var database = await openDatabase(path, version: 1, onCreate: initDB);
    return database;
  }

  void initDB(Database database, int version) async {
    await database.execute(
        'CREATE TABLE $businessTABLE (id INTEGER PRIMARY KEY, name TEXT, phone TEXT, address TEXT, logo BLOB, email TEXT, website TEXT, role TEXT, companyName TEXT)');
  }
}
