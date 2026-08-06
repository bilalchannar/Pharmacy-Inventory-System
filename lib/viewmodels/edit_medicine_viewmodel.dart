import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../services/image_service.dart';
import '../services/medicine_service.dart';
import 'base_viewmodel.dart';

class EditMedicineViewModel extends BaseViewModel {
  final Medicine medicine;
  final MedicineService _medicineService = MedicineService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController companyController;
  late TextEditingController priceController;
  late TextEditingController quantityController;
  late TextEditingController expiryDateController;

  String? _selectedCategory;
  String? imageUrl;

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

  EditMedicineViewModel({required this.medicine}) {
    nameController = TextEditingController(text: medicine.name);
    companyController = TextEditingController(text: medicine.company);
    priceController = TextEditingController(text: medicine.price.toString());
    quantityController = TextEditingController(text: medicine.quantity.toString());
    expiryDateController = TextEditingController(text: medicine.expiryDate);
    _selectedCategory = medicine.category;
    imageUrl = medicine.imageUrl;
  }

  String? get selectedCategory => _selectedCategory;

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> selectExpiryDate(BuildContext context) async {
    final DateTime initialDate =
        DateTime.tryParse(medicine.expiryDate) ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
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

  Future<bool> updateMedicine() async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    final price = double.tryParse(priceController.text);
    if (price == null || price <= 0) {
      setError('Price must be greater than 0');
      return false;
    }

    final quantity = int.tryParse(quantityController.text);
    if (quantity == null || quantity < 0) {
      setError('Quantity cannot be negative');
      return false;
    }

    setBusy(true);
    clearError();

    try {
      final updatedName = nameController.text.trim();
      final updatedCategory = _selectedCategory!;

      // Fetch new image URL if missing
      String currentImageUrl = imageUrl ?? '';
      if (currentImageUrl.isEmpty ||
          updatedName != medicine.name ||
          updatedCategory != medicine.category) {
        currentImageUrl = await ImageService.fetchMedicineImageUrl(
          updatedName,
          updatedCategory,
        );
      }

      final updatedMedicine = Medicine(
        id: medicine.id,
        name: updatedName,
        company: companyController.text.trim(),
        category: updatedCategory,
        price: price,
        quantity: quantity,
        expiryDate: expiryDateController.text,
        imageUrl: currentImageUrl,
      );

      await _medicineService.updateMedicine(updatedMedicine);
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
