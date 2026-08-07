import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  Database? _database;
  static Completer<Database>? _initCompleter;

  Future<Database?> get database async {
    if (_database != null) return _database;
    if (_initCompleter != null) return _initCompleter!.future;

    _initCompleter = Completer<Database>();
    try {
      print('SQL_LOG: Starting Web-Safe Initialization...');
      final db = await _initDatabase();
      _database = db;
      _initCompleter!.complete(db);
      return db;
    } catch (e) {
      print('SQL_LOG: Initialization CRITICAL FAILURE: $e');
      _initCompleter!.completeError(e);
      _initCompleter = null;
      rethrow;
    }
  }

  Future<Database> _initDatabase() async {
    String path = kIsWeb ? 'pharmacy_v1.db' : join(await getDatabasesPath(), 'pharmacy.db');
    
    // On Web, we open without version/onCreate to avoid the PRAGMA null-result bug.
    // We then handle table creation manually if it's a new database.
    final db = await openDatabase(path).timeout(const Duration(seconds: 10));
    print('SQL_LOG: Database handle acquired safely.');

    // Manual "onCreate" logic that is Web-Safe
    try {
      print('SQL_LOG: Verifying/Creating tables manually...');
      // Using rawQuery + catch null bug to ensure table exists
      await db.execute('''
        CREATE TABLE IF NOT EXISTS medicines(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          company TEXT NOT NULL,
          category TEXT NOT NULL,
          quantity INTEGER NOT NULL,
          price REAL NOT NULL,
          expiryDate TEXT NOT NULL,
          imageUrl TEXT
        )
      ''');
      print('SQL_LOG: Table verification successful.');
    } catch (e) {
      if (e.toString().contains('unsupported result null')) {
        print('SQL_LOG: Table verification success (ignored null result bug).');
      } else {
        rethrow;
      }
    }

    return db;
  }

  Future<void> executeRawSql(String sql) async {
    print('SQL_LOG: executeRawSql called.');
    final db = await database;
    if (db == null) return;

    final queries = sql.split(';').where((q) => q.trim().isNotEmpty).toList();
    
    for (var query in queries) {
      final trimmed = query.trim();
      try {
        // Use rawUpdate for inserts as it handles results better than execute
        await db.rawUpdate(trimmed);
      } catch (e) {
        if (e.toString().contains('unsupported result null')) {
          print('SQL_LOG: Statement success (ignored null result).');
        } else {
          print('SQL_LOG: SQL Error: $e');
          rethrow;
        }
      }
    }
    print('SQL_LOG: SQL Script Finished.');
  }
}
