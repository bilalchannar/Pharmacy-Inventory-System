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
    String path = kIsWeb ? 'pharmacy_v2.db' : join(await getDatabasesPath(), 'pharmacy.db');
    
    Database? db;
    try {
      print('SQL_LOG: Opening database ($path)...');
      db = await openDatabase(path).timeout(const Duration(seconds: 5));
      print('SQL_LOG: Database handle acquired safely.');
    } catch (e) {
      print('SQL_LOG: Primary open failed ($e). Attempting in-memory web database fallback...');
      try {
        db = await openDatabase(inMemoryDatabasePath);
        print('SQL_LOG: In-memory fallback database handle acquired.');
      } catch (err) {
        print('SQL_LOG: Fallback failed: $err');
        rethrow;
      }
    }

    // Ensure table exists safely
    try {
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
      print('SQL_LOG: Table verification complete.');
    } catch (e) {
      if (e.toString().contains('unsupported result null')) {
        print('SQL_LOG: Table verification complete (ignored null result).');
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

    final rawQueryString = sql.trim();
    if (rawQueryString.isEmpty) return;

    // Split multiple queries by semicolon, preserving single queries
    List<String> queries = rawQueryString
        .split(';')
        .map((q) => q.trim())
        .where((q) => q.isNotEmpty)
        .toList();

    if (queries.isEmpty && rawQueryString.isNotEmpty) {
      queries = [rawQueryString];
    }

    for (var query in queries) {
      var trimmed = query.trim();
      if (trimmed.isEmpty) continue;

      // Smart check: If user pasted values directly like ('Name', 'Company', ...), prepend INSERT statement
      if (trimmed.startsWith('(') && !trimmed.toLowerCase().startsWith('insert')) {
        trimmed = 'INSERT INTO medicines (name, company, category, quantity, price, expiryDate, imageUrl) VALUES $trimmed';
      }

      try {
        final lower = trimmed.toLowerCase();
        if (lower.startsWith('select')) {
          await db.rawQuery(trimmed);
        } else if (lower.startsWith('insert')) {
          await db.rawInsert(trimmed);
        } else if (lower.startsWith('update') || lower.startsWith('delete')) {
          await db.rawUpdate(trimmed);
        } else {
          await db.execute(trimmed);
        }
        print('SQL_LOG: Executed successfully: $trimmed');
      } catch (e) {
        if (e.toString().contains('unsupported result null')) {
          print('SQL_LOG: Statement executed with null result (ignored web bug).');
        } else {
          print('SQL_LOG: SQL Error: $e');
          rethrow;
        }
      }
    }
    print('SQL_LOG: SQL Script Finished.');
  }
}

