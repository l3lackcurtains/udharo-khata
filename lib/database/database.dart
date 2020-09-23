import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

final businessTABLE = 'KhataBusiness';
final transactionTABLE = 'KhataTransaction';
final customerTABLE = 'KhataCustomer';

class DatabaseProvider {
  static final DatabaseProvider dbProvider = DatabaseProvider();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await createDatabase();
    return _database;
  }

  static Future _onConfigure(Database database) async {
    await database.execute('PRAGMA foreign_keys = ON');
  }

  createDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'udharoKhata.db');
    var database = await openDatabase(path,
        version: 1, onCreate: initDB, onConfigure: _onConfigure);
    return database;
  }

  void initDB(Database database, int version) async {
    await database.execute(
        'CREATE TABLE $businessTABLE (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, phone TEXT, address TEXT, logo BLOB, email TEXT, website TEXT, role TEXT, companyName TEXT)');

    await database.execute(
        'CREATE TABLE $customerTABLE (id INTEGER PRIMARY KEY AUTOINCREMENT, businessId INTEGER, name TEXT, phone TEXT, address TEXT, image BLOB, FOREIGN KEY (businessId) REFERENCES $businessTABLE (id) ON DELETE CASCADE)');

    await database.execute(
        'CREATE TABLE $transactionTABLE (id INTEGER PRIMARY KEY AUTOINCREMENT, businessId INTEGER, uid INTEGER, ttype TEXT, amount DOUBLE, comment TEXT, date TEXT, attachment BLOB, FOREIGN KEY (businessId) REFERENCES $businessTABLE (id) ON DELETE CASCADE, FOREIGN KEY (uid) REFERENCES $customerTABLE (id) ON DELETE CASCADE)');
  }
}
