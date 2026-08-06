import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/medicine.dart';
import '../services/medicine_service.dart';

class EditMedicineScreen extends StatefulWidget {
  final Medicine medicine;
  const EditMedicineScreen({super.key, required this.medicine});

  @override
  State<EditMedicineScreen> createState() => _EditMedicineScreenState();
}

class _EditMedicineScreenState extends State<EditMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final MedicineService _medicineService = MedicineService();
  late TextEditingController _nameController;
  late TextEditingController _companyController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _expiryDateController;
  String? _selectedCategory;
  final List<String> _categories = ['Tablet', 'Capsule', 'Syrup', 'Injection', 'Cream', 'Drops', 'Ointment', 'Powder'];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medicine.name);
    _companyController = TextEditingController(text: widget.medicine.company);
    _priceController = TextEditingController(text: widget.medicine.price.toString());
    _quantityController = TextEditingController(text: widget.medicine.quantity.toString());
    _expiryDateController = TextEditingController(text: widget.medicine.expiryDate);
    _selectedCategory = widget.medicine.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(widget.medicine.expiryDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Colors.lightGreen, onPrimary: Colors.white, onSurface: Colors.black)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _expiryDateController.text = picked.toString().split(' ')[0]);
  }

  Future<void> _updateMedicine() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        final updatedMedicine = Medicine(
          id: widget.medicine.id,
          name: _nameController.text.trim(),
          company: _companyController.text.trim(),
          category: _selectedCategory!,
          price: double.tryParse(_priceController.text) ?? 0.0,
          quantity: int.tryParse(_quantityController.text) ?? 0,
          expiryDate: _expiryDateController.text,
        );
        await _medicineService.updateMedicine(updatedMedicine);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Medicine updated successfully!'), backgroundColor: Colors.green));
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Medicine', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter medicine name' : null,
                decoration: InputDecoration(
                  labelText: 'Medicine Name',
                  prefixIcon: const Icon(Icons.badge, color: Colors.lightGreen),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.lightGreen, width: 2)),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _companyController,
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter company name' : null,
                decoration: InputDecoration(
                  labelText: 'Company',
                  prefixIcon: const Icon(Icons.business, color: Colors.lightGreen),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.lightGreen, width: 2)),
                ),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
                validator: (v) => v == null ? 'Please select a category' : null,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(Icons.category, color: Colors.lightGreen),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.lightGreen, width: 2)),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                validator: (v) {
                   if (v == null || v.trim().isEmpty) return 'Please enter price';
                   if (double.tryParse(v) == null) return 'Please enter a valid price';
                   return null;
                },
                decoration: InputDecoration(
                  labelText: 'Price',
                  prefixIcon: const Icon(Icons.attach_money, color: Colors.lightGreen),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.lightGreen, width: 2)),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                   if (v == null || v.trim().isEmpty) return 'Please enter quantity';
                   if (int.tryParse(v) == null) return 'Please enter a valid quantity';
                   return null;
                },
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  prefixIcon: const Icon(Icons.inventory, color: Colors.lightGreen),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.lightGreen, width: 2)),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _expiryDateController,
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (v) => v == null || v.trim().isEmpty ? 'Please select expiry date' : null,
                decoration: InputDecoration(
                  labelText: 'Expiry Date',
                  prefixIcon: const Icon(Icons.calendar_today, color: Colors.lightGreen),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.lightGreen, width: 2)),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _updateMedicine,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('Update Medicine', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
