import '../models/medicine.dart';
import '../services/image_service.dart';
import '../services/medicine_service.dart';
import 'base_viewmodel.dart';

class HomeViewModel extends BaseViewModel {
  final MedicineService _medicineService = MedicineService();
  List<Medicine> _medicines = [];

  String _searchQuery = '';
  String _selectedCategoryFilter = 'All';
  String _selectedSortOption = 'Name A-Z';

  final List<String> categories = [
    'All',
    'Tablet',
    'Capsule',
    'Syrup',
    'Injection',
    'Cream',
    'Drops',
    'Ointment',
    'Powder',
  ];

  final List<String> sortOptions = [
    'Name A-Z',
    'Name Z-A',
    'Price Low → High',
    'Price High → Low',
    'Quantity',
    'Expiry Date',
  ];

  List<Medicine> get rawMedicines => _medicines;
  String get searchQuery => _searchQuery;
  String get selectedCategoryFilter => _selectedCategoryFilter;
  String get selectedSortOption => _selectedSortOption;

  // ==========================================
  // Dashboard Metrics
  // ==========================================

  int get totalMedicines => _medicines.length;

  int get totalStock => _medicines.fold(0, (sum, item) => sum + item.quantity);

  double get totalValue =>
      _medicines.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  int get lowStockCount =>
      _medicines.where((item) => item.quantity < 10).length;

  int get expiredCount =>
      _medicines.where((item) => isMedicineExpired(item.expiryDate)).length;

  // ==========================================
  // Filtering & Sorting
  // ==========================================

  List<Medicine> get filteredMedicines {
    List<Medicine> list = List.from(_medicines);

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      list = list.where((item) => item.name.toLowerCase().contains(query)).toList();
    }

    if (_selectedCategoryFilter != 'All') {
      list = list
          .where((item) => item.category.toLowerCase() == _selectedCategoryFilter.toLowerCase())
          .toList();
    }

    switch (_selectedSortOption) {
      case 'Name A-Z':
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case 'Name Z-A':
        list.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case 'Price Low → High':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price High → Low':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Quantity':
        list.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case 'Expiry Date':
        list.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
        break;
    }

    return list;
  }

  bool get isEmpty => filteredMedicines.isEmpty;
  bool get isRawEmpty => _medicines.isEmpty;

  static bool isMedicineExpired(String expiryDateStr) {
    try {
      final parsedDate = DateTime.parse(expiryDateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return parsedDate.isBefore(today);
    } catch (_) {
      return false;
    }
  }

  static bool isLowStock(int quantity) => quantity < 10;

  // ==========================================
  // Business Logic Functions
  // ==========================================

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void setCategoryFilter(String category) {
    _selectedCategoryFilter = category;
    notifyListeners();
  }

  void setSortOption(String sortOption) {
    _selectedSortOption = sortOption;
    notifyListeners();
  }

  Future<void> fetchMedicines() async {
    setBusy(true);
    clearError();
    try {
      _medicines = await _medicineService.getAllMedicines();
      // Side-effect moved to a separate function or handled during creation/update
    } catch (e) {
      setError(e.toString());
    } finally {
      setBusy(false);
    }
  }

  Future<void> syncMedicineImages() async {
    for (var medicine in _medicines) {
      final freshUrl = ImageService.getCategoryImageUrl(medicine.category);
      if (medicine.imageUrl == null ||
          medicine.imageUrl!.trim().isEmpty ||
          medicine.imageUrl!.contains('1550572017') ||
          medicine.imageUrl!.contains('1579165466') ||
          (medicine.category == 'Ointment' && medicine.imageUrl!.contains('1556228720'))) {
        medicine.imageUrl = freshUrl;
        await _medicineService.updateMedicine(medicine);
      }
    }
    notifyListeners();
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
      return false;
    }
  }

  Future<bool> restoreMedicine(Medicine medicine) async {
    try {
      await _medicineService.insertMedicine(medicine);
      await fetchMedicines();
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    }
  }

  Future<bool> deleteAllMedicines() async {
    try {
      await _medicineService.deleteAllMedicines();
      await fetchMedicines();
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    }
  }

  Future<bool> runSql(String sql) async {
    setBusy(true);
    clearError();
    try {
      await _medicineService.runRawSql(sql);
      await fetchMedicines();
      return true;
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setBusy(false);
    }
  }
}
