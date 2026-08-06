import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../viewmodels/home_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    _viewModel.fetchMedicines();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _deleteMedicine(int id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Medicine'),
          content: const Text('Are you sure you want to delete this medicine?'),
          actions: [
            TextButton(
              onPressed: () => AppRoutes.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => AppRoutes.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final success = await _viewModel.deleteMedicine(id);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medicine deleted successfully!')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medicine Inventory System',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.lightGreen,
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isBusy) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.lightGreen),
            );
          }

          if (_viewModel.isEmpty) {
            return const Center(
              child: Text(
                'No medicines found.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final medicines = _viewModel.medicines;
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: medicines.length,
            itemBuilder: (context, index) {
              final medicine = medicines[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: ExpansionTile(
                  shape: const RoundedRectangleBorder(side: BorderSide.none),
                  collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
                  backgroundColor: Colors.lightGreen.withValues(alpha: 0.04),
                  iconColor: Colors.lightGreen,
                  collapsedIconColor: Colors.grey,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  childrenPadding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.lightGreen,
                    child: Icon(Icons.medication, color: Colors.white),
                  ),
                  title: Text(
                    medicine.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    'Qty: ${medicine.quantity}  |  Price: Rs. ${medicine.price}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () async {
                          final result = await AppRoutes.toEditMedicineScreen(
                            context,
                            medicine,
                          );
                          if (result == true) {
                            _viewModel.fetchMedicines();
                          }
                        },
                        icon: const Icon(Icons.edit, color: Colors.green),
                        tooltip: 'Edit Medicine',
                      ),
                      IconButton(
                        onPressed: () => _deleteMedicine(medicine.id!),
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete Medicine',
                      ),
                    ],
                  ),
                  children: [
                    const Divider(height: 1, color: Colors.black12),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.business, color: Colors.lightGreen, size: 20),
                        const SizedBox(width: 10),
                        Text('Company: ${medicine.company}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.category, color: Colors.lightGreen, size: 20),
                        const SizedBox(width: 10),
                        Text('Category: ${medicine.category}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.attach_money, color: Colors.lightGreen, size: 20),
                        const SizedBox(width: 10),
                        Text('Price: Rs. ${medicine.price}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.inventory, color: Colors.lightGreen, size: 20),
                        const SizedBox(width: 10),
                        Text('Quantity: ${medicine.quantity}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.lightGreen, size: 20),
                        const SizedBox(width: 10),
                        Text('Expiry Date: ${medicine.expiryDate}'),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightGreen,
        onPressed: () async {
          final result = await AppRoutes.toAddMedicineScreen(context);
          if (result == true) {
            _viewModel.fetchMedicines();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
