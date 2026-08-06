import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/database_helper.dart';
import '../models/medicine.dart';

class MedicineService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> insertMedicine(Medicine medicine) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      'medicines',
      medicine.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Medicine>> getAllMedicines() async {
    final db = await _databaseHelper.database;
    final medicines = await db.query('medicines');
    return medicines.map((m) => Medicine.fromMap(m)).toList();
  }

  Future<int> updateMedicine(Medicine medicine) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'medicines',
      medicine.toMap(),
      where: 'id = ?',
      whereArgs: [medicine.id],
    );
  }

  Future<int> deleteMedicine(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete('medicines', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllMedicines() async {
    final db = await _databaseHelper.database;
    return await db.delete('medicines');
  }
}
