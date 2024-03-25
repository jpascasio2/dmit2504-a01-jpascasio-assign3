// ignore_for_file: todo, avoid_print, library_prefixes, avoid_function_literals_in_foreach_calls, file_names, unused_import

import 'package:path/path.dart' as pathPackage;
import 'package:sqflite/sqflite.dart' as sqflitePackage;

class SQFliteDbService {
  late sqflitePackage.Database db;
  late String path;

  Future<void> getOrCreateDatabaseHandle() async {
    try {
      var databasesPath = await sqflitePackage.getDatabasesPath();
      path = pathPackage.join(databasesPath, 'stocks_database.db');
      db = await sqflitePackage.openDatabase(
        path,
        onCreate: (sqflitePackage.Database db, int version) async {
          await db.execute(
            "CREATE TABLE stocks(symbol TEXT PRIMARY KEY, companyName TEXT, price REAL)",
          );
        },
        version: 1,
      );
    } catch (e) {
      print('SQFliteDbService getOrCreateDatabaseHandle: $e');
    }
  }

  Future<void> printAllStocksInDbToConsole() async {
    try {
      final List<Map<String, dynamic>> stocks = await db.query('stocks');
      print(stocks);
    } catch (e) {
      print('SQFliteDbService printAllStocksInDbToConsole: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllStocksFromDb() async {
    try {
      final List<Map<String, dynamic>> stocks = await db.query('stocks');
      return stocks;
    } catch (e) {
      print('SQFliteDbService getAllStocksFromDb: $e');
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> deleteDb() async {
    try {
      await sqflitePackage.deleteDatabase(path);
    } catch (e) {
      print('SQFliteDbService deleteDb: $e');
    }
  }

  Future<void> insertStock(Map<String, dynamic> stock) async {
    try {
      await db.insert(
        'stocks',
        stock,
        conflictAlgorithm: sqflitePackage.ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('SQFliteDbService insertStock: $e');
    }
  }

  Future<void> updateStock(Map<String, dynamic> stock) async {
    try {
      await db.update(
        'stocks',
        stock,
        whereArgs: [stock['id']],
      );
    } catch (e) {
      print('SQFliteDbService updateStock: $e');
    }
  }

  Future<void> deleteStock(Map<String, dynamic> stock) async {
    try {
      await db.delete(
        'stocks',
        whereArgs: [stock['id']],
      );
    } catch (e) {
      print('SQFliteDbService deleteStock: $e');
    }
  }
}
