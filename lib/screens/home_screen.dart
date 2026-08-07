import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../routes/app_routes.dart';
import '../services/image_service.dart';
import '../viewmodels/home_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    _loadMedicines();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _loadMedicines() async {
    await _viewModel.fetchMedicines();
    await _viewModel.syncMedicineImages();
  }

  Future<bool> _confirmAndDelete(Medicine medicine) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red),
              SizedBox(width: 10),
              Text('Delete Medicine'),
            ],
          ),
          content: Text('Are you sure you want to delete "${medicine.name}"?'),
          actions: [
            TextButton(
              onPressed: () => AppRoutes.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => AppRoutes.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final success = await _viewModel.deleteMedicine(medicine.id!);
      if (mounted && success) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${medicine.name}"'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            action: SnackBarAction(
              label: 'UNDO',
              textColor: Colors.lightGreenAccent,
              onPressed: () async {
                final restored = await _viewModel.restoreMedicine(medicine);
                if (mounted && restored) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Restored "${medicine.name}"'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        );
        return true;
      }
    }
    return false;
  }

  Future<void> _deleteAllMedicines() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text('Delete All Medicines'),
            ],
          ),
          content: const Text(
            'Are you sure you want to delete ALL medicines from inventory? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => AppRoutes.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => AppRoutes.pop(context, true),
              child: const Text('Delete All', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final success = await _viewModel.deleteAllMedicines();
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('All medicines deleted successfully!'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _openSqlConsole() {
    final TextEditingController sqlController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.terminal, color: Colors.blue),
                      const SizedBox(width: 10),
                      const Text(
                        'SQL Developer Console',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: sqlController,
                    maxLines: 8,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Paste SQL here (e.g. INSERT INTO medicines...)',
                      fillColor: Colors.grey.shade100,
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (_viewModel.hasError)
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        _viewModel.errorMessage ?? 'Unknown error',
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ElevatedButton.icon(
                    onPressed: _viewModel.isBusy
                        ? null
                        : () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(context);
                            final success = await _viewModel.runSql(sqlController.text);
                            if (success && mounted) {
                              messenger.showSnackBar(
                                const SnackBar(content: Text('SQL executed successfully!')),
                              );
                              navigator.pop();
                            }
                          },
                    icon: _viewModel.isBusy
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.play_arrow),
                    label: const Text('Run Query'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pharmacy Inventory',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.lightGreen,
        centerTitle: true,
        elevation: 1,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            tooltip: 'Sort Options',
            onSelected: (option) {
              if (option == 'SQL Console') {
                _openSqlConsole();
              } else {
                _viewModel.setSortOption(option);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sorted by $option'),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            itemBuilder: (context) {
              return [
                ..._viewModel.sortOptions.map((option) {
                  return PopupMenuItem<String>(
                    value: option,
                    child: ListenableBuilder(
                      listenable: _viewModel,
                      builder: (context, _) {
                        final isSelected = option == _viewModel.selectedSortOption;
                        return Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: isSelected ? Colors.lightGreen : Colors.grey,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Text(option),
                          ],
                        );
                      },
                    ),
                  );
                }),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'SQL Console',
                  child: Row(
                    children: [
                      Icon(Icons.terminal, color: Colors.blue),
                      const SizedBox(width: 10),
                      Text('SQL Console'),
                    ],
                  ),
                ),
              ];
            },
          ),
          IconButton(
            onPressed: _deleteAllMedicines,
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            tooltip: 'Delete All Medicines',
          ),
        ],
      ),
      body: Column(
        children: [
          // ==========================================
          // Dashboard Summary Cards
          // ==========================================
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              final metrics = [
                {'title': 'Total Items', 'value': _viewModel.totalMedicines.toString(), 'icon': Icons.medication, 'color': Colors.blue},
                {'title': 'Total Stock', 'value': _viewModel.totalStock.toString(), 'icon': Icons.inventory_2, 'color': Colors.teal},
                {'title': 'Total Value', 'value': 'Rs. ${_viewModel.totalValue.toStringAsFixed(0)}', 'icon': Icons.account_balance_wallet, 'color': Colors.purple},
                {'title': 'Low Stock', 'value': _viewModel.lowStockCount.toString(), 'icon': Icons.warning_amber_rounded, 'color': Colors.orange},
                {'title': 'Expired', 'value': _viewModel.expiredCount.toString(), 'icon': Icons.event_busy, 'color': Colors.red},
              ];

              return SizedBox(
                height: 125,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  itemCount: metrics.length,
                  itemBuilder: (context, index) {
                    final item = metrics[index];
                    final color = item['color'] as Color;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 140,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.withValues(alpha: 0.25)),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(item['icon'] as IconData, color: color, size: 18),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['value'] as String,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['title'] as String,
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // ==========================================
          // Real-time Search Bar
          // ==========================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                return TextField(
                  controller: _searchController,
                  onChanged: (value) => _viewModel.setSearchQuery(value),
                  decoration: InputDecoration(
                    hintText: 'Search medicine name...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _viewModel.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              _viewModel.clearSearch();
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                );
              },
            ),
          ),

          // ==========================================
          // Category Filter Chips
          // ==========================================
          SizedBox(
            height: 48,
            child: ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  itemCount: _viewModel.categories.length,
                  itemBuilder: (context, index) {
                    final category = _viewModel.categories[index];
                    final isSelected = category == _viewModel.selectedCategoryFilter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        selectedColor: Colors.lightGreen,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            _viewModel.setCategoryFilter(category);
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const Divider(height: 1),

          // ==========================================
          // Medicine List
          // ==========================================
          Expanded(
            child: ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                final medicines = _viewModel.filteredMedicines;
                
                if (_viewModel.isBusy) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        height: 75,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    },
                  );
                }

                if (medicines.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.lightGreen.withValues(alpha: 0.15),
                            child: Icon(
                              _viewModel.isRawEmpty
                                  ? Icons.inventory_2_outlined
                                  : Icons.search_off,
                              size: 40,
                              color: Colors.lightGreen,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _viewModel.isRawEmpty
                                ? 'No Medicines in Inventory'
                                : 'No Matching Medicines',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _viewModel.isRawEmpty
                                ? 'Get started by adding your first medicine record.'
                                : 'Try clearing your search query or filter selection.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          if (_viewModel.isRawEmpty) ...[
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final result = await AppRoutes.toAddMedicineScreen(context);
                                if (result == true) {
                                  _viewModel.fetchMedicines();
                                }
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add First Medicine', style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: medicines.length,
                  itemBuilder: (context, index) {
                    final medicine = medicines[index];
                    final isExpired = HomeViewModel.isMedicineExpired(medicine.expiryDate);
                    final isLowStock = HomeViewModel.isLowStock(medicine.quantity);

                    // Inline Image logic
                    final rawUrl = medicine.imageUrl;
                    final urlToUse = (rawUrl != null && rawUrl.trim().isNotEmpty)
                        ? rawUrl
                        : ImageService.getCategoryImageUrl(medicine.category);

                    return Dismissible(
                      key: ValueKey('med_${medicine.id}_${medicine.name}'),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          return await _confirmAndDelete(medicine);
                        } else if (direction == DismissDirection.startToEnd) {
                          final result = await AppRoutes.toEditMedicineScreen(context, medicine);
                          if (result == true) _viewModel.fetchMedicines();
                          return false;
                        }
                        return false;
                      },
                      background: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerLeft,
                        child: const Row(
                          children: [
                            Icon(Icons.edit, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Edit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      secondaryBackground: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.delete, color: Colors.white),
                          ],
                        ),
                      ),
                      child: Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        clipBehavior: Clip.antiAlias,
                        child: ExpansionTile(
                          shape: const RoundedRectangleBorder(side: BorderSide.none),
                          collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
                          backgroundColor: Colors.lightGreen.withValues(alpha: 0.04),
                          iconColor: Colors.lightGreen,
                          collapsedIconColor: Colors.grey,
                          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          childrenPadding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                          leading: Hero(
                            tag: 'med_img_${medicine.id ?? medicine.name}',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                urlToUse,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 48,
                                    height: 48,
                                    color: Colors.lightGreen.withValues(alpha: 0.1),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.lightGreen),
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.network(
                                    ImageService.getCategoryImageUrl(medicine.category),
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Colors.lightGreen,
                                      child: Icon(Icons.medication, color: Colors.white),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  medicine.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isExpired)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  margin: const EdgeInsets.only(left: 4),
                                  decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(4)),
                                  child: const Text('EXPIRED', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                                )
                              else if (isLowStock)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  margin: const EdgeInsets.only(left: 4),
                                  decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(4)),
                                  child: const Text('LOW STOCK', style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                          subtitle: Text('Qty: ${medicine.quantity}  |  Price: Rs. ${medicine.price}', style: TextStyle(color: Colors.grey.shade700)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  final result = await AppRoutes.toEditMedicineScreen(context, medicine);
                                  if (result == true) _viewModel.fetchMedicines();
                                },
                                icon: const Icon(Icons.edit, color: Colors.green),
                                tooltip: 'Edit Medicine',
                              ),
                              IconButton(
                                onPressed: () => _confirmAndDelete(medicine),
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Delete Medicine',
                              ),
                            ],
                          ),
                          children: [
                            const Divider(height: 1, color: Colors.black12),
                            const SizedBox(height: 10),
                            Row(children: [const Icon(Icons.business, color: Colors.lightGreen, size: 20), const SizedBox(width: 10), Text('Company: ${medicine.company}')]),
                            const SizedBox(height: 8),
                            Row(children: [const Icon(Icons.category, color: Colors.lightGreen, size: 20), const SizedBox(width: 10), Text('Category: ${medicine.category}')]),
                            const SizedBox(height: 8),
                            Row(children: [const Icon(Icons.attach_money, color: Colors.lightGreen, size: 20), const SizedBox(width: 10), Text('Price: Rs. ${medicine.price}')]),
                            const SizedBox(height: 8),
                            Row(children: [const Icon(Icons.inventory, color: Colors.lightGreen, size: 20), const SizedBox(width: 10), Text('Quantity: ${medicine.quantity} units')]),
                            const SizedBox(height: 8),
                            Row(children: [const Icon(Icons.calendar_today, color: Colors.lightGreen, size: 20), const SizedBox(width: 10), Text('Expiry Date: ${medicine.expiryDate}')]),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
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
