import 'package:flutter/material.dart';
import '../services/medicine_service.dart';
import '../models/medicine.dart';
import 'add_medicine_screen.dart';
import 'edit_medicine_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MedicineService _medicineService = MedicineService();
  List<Medicine> _medicines = [];
  bool _isLoading = false;

  Future<void> _loadMedicines() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final medicines = await _medicineService.getAllMedicines();
      setState(() {
        _medicines = medicines;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error: $e');
    }
  }

  Future<void> _deleteMedicine(int id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Medicine'),
          content: const Text('Are you sure you want to delete this medicine?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
          ],
        );
      },
    );

    if (confirm == true) {
      await _medicineService.deleteMedicine(id);
      _loadMedicines();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Medicine deleted successfully!')));
      }
    }
  }

  void _showMedicineDetails(Medicine medicine) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Medicine Details', style: TextStyle(color: Colors.lightGreen, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.medication, color: Colors.lightGreen),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Name: ${medicine.name}')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.business, color: Colors.lightGreen),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Company: ${medicine.company}')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.category, color: Colors.lightGreen),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Category: ${medicine.category}')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.attach_money, color: Colors.lightGreen),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Price: Rs. ${medicine.price}')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.inventory, color: Colors.lightGreen),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Quantity: ${medicine.quantity}')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.lightGreen),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Expiry Date: ${medicine.expiryDate}')),
                ],
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen, foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Inventory System', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.lightGreen,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.lightGreen))
          : _medicines.isEmpty
              ? const Center(child: Text('No medicines found.', style: TextStyle(fontSize: 18, color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _medicines.length,
                  itemBuilder: (context, index) {
                    final medicine = _medicines[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: IconButton(
                          onPressed: () {
                            _showMedicineDetails(medicine);
                          },
                          icon: const CircleAvatar(
                            backgroundColor: Colors.lightGreen,
                            child: Icon(Icons.medication, color: Colors.white),
                          ),
                        ),
                        title: Text(medicine.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Qty: ${medicine.quantity} | Price: Rs. ${medicine.price}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => EditMedicineScreen(medicine: medicine)),
                                );
                                if (result == true) {
                                  _loadMedicines();
                                }
                              },
                              icon: const Icon(Icons.edit, color: Colors.green),
                            ),
                            IconButton(
                              onPressed: () => _deleteMedicine(medicine.id!),
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightGreen,
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddMedicineScreen()));
          if (result == true) {
            _loadMedicines();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
