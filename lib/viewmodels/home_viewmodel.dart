import 'package:flutter/foundation.dart';
import '../models/medicine.dart';
import '../services/medicine_service.dart';
import 'base_viewmodel.dart';

class HomeViewModel extends BaseViewModel {
  final MedicineService _medicineService = MedicineService();
  List<Medicine> _medicines = [];

  List<Medicine> get medicines => _medicines;
  bool get isEmpty => _medicines.isEmpty;

  Future<void> fetchMedicines() async {
    setBusy(true);
    clearError();
    try {
      _medicines = await _medicineService.getAllMedicines();
    } catch (e) {
      setError(e.toString());
      debugPrint('Error fetching medicines: $e');
    } finally {
      setBusy(false);
    }
  }

  Future<bool> deleteMedicine(int id) async {
    try {
      final rowsDeleted = await _medicineService.deleteMedicine(id);
      if (rowsDeleted > 0) {
        await fetchMedicines();
        return true;
      }
      return false;
    } catch (e) {
      setError(e.toString());
      debugPrint('Error deleting medicine: $e');
      return false;
    }
  }
}
