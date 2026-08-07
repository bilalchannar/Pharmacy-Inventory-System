import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/medicine.dart';
import '../routes/app_routes.dart';
import '../viewmodels/edit_medicine_viewmodel.dart';

class EditMedicineScreen extends StatefulWidget {
  final Medicine medicine;
  const EditMedicineScreen({super.key, required this.medicine});

  @override
  State<EditMedicineScreen> createState() => _EditMedicineScreenState();
}

class _EditMedicineScreenState extends State<EditMedicineScreen> {
  late final EditMedicineViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = EditMedicineViewModel(medicine: widget.medicine);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    final success = await _viewModel.updateMedicine();
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Medicine updated successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      AppRoutes.pop(context, true);
    } else if (_viewModel.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${_viewModel.errorMessage}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Medicine', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.lightGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _viewModel.formKey,
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              return Column(
                children: [
                  TextFormField(
                    controller: _viewModel.nameController,
                    textInputAction: TextInputAction.next,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Please enter medicine name' : null,
                    decoration: const InputDecoration(
                      labelText: 'Medicine Name',
                      prefixIcon: Icon(Icons.badge),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _viewModel.companyController,
                    textInputAction: TextInputAction.next,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Please enter company name' : null,
                    decoration: const InputDecoration(
                      labelText: 'Company',
                      prefixIcon: Icon(Icons.business),
                    ),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    initialValue: _viewModel.selectedCategory,
                    items: _viewModel.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => _viewModel.setSelectedCategory(v),
                    validator: (v) => v == null ? 'Please select a category' : null,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _viewModel.priceController,
                    textInputAction: TextInputAction.next,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Please enter price';
                      final parsed = double.tryParse(v);
                      if (parsed == null) return 'Please enter a valid price';
                      if (parsed <= 0) return 'Price must be greater than 0';
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Price (Rs.)',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _viewModel.quantityController,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Please enter quantity';
                      if (int.tryParse(v) == null) return 'Please enter a valid quantity';
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      prefixIcon: Icon(Icons.inventory),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _viewModel.expiryDateController,
                    readOnly: true,
                    onTap: () => _viewModel.selectExpiryDate(context),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Please select expiry date' : null,
                    decoration: const InputDecoration(
                      labelText: 'Expiry Date',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _viewModel.isBusy ? null : _handleUpdate,
                      child: _viewModel.isBusy
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Update Medicine', style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
