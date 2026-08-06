import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../services/medicine_service.dart';
import 'base_viewmodel.dart';

class AddMedicineViewModel extends BaseViewModel {
  final MedicineService _medicineService = MedicineService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();

  String? _selectedCategory;
  final List<String> categories = [
    'Tablet',
    'Capsule',
    'Syrup',
    'Injection',
    'Cream',
    'Drops',
    'Ointment',
    'Powder',
  ];

  String? get selectedCategory => _selectedCategory;

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.lightGreen,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      expiryDateController.text = picked.toString().split(' ')[0];
      notifyListeners();
    }
  }

  Future<bool> saveMedicine() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    setBusy(true);
    clearError();

    try {
      final newMedicine = Medicine(
        name: nameController.text.trim(),
        company: companyController.text.trim(),
        category: _selectedCategory!,
        price: double.tryParse(priceController.text) ?? 0.0,
        quantity: int.tryParse(quantityController.text) ?? 0,
        expiryDate: expiryDateController.text,
      );

      await _medicineService.insertMedicine(newMedicine);
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setBusy(false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    companyController.dispose();
    priceController.dispose();
    quantityController.dispose();
    expiryDateController.dispose();
    super.dispose();
  }
}
