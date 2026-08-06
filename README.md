# 💊 Pharmacy Inventory System

A production-ready, feature-rich Flutter application designed for modern pharmacy inventory management. Built using the **MVVM (Model-View-ViewModel)** architectural pattern, SQLite local database persistence, automatic image fetching, real-time search, category filtering, sorting, swipe actions, and undo delete capabilities.

---

## 🚀 Key Features

- **MVVM Architecture**: Clean separation of UI views, ViewModels (`ChangeNotifier`), services, and data models.
- **SQLite Local Database**: Persistent storage for all medicine records with cross-platform support (Android, iOS, Desktop).
- **Generic `AppRoutes` Navigation**: Type-safe, single-line navigation methods (`push`, `pop`, `present`, and direct screen dot-access like `AppRoutes.toAddMedicineScreen(context)`).
- **Interactive Dashboard**:
  - 📊 **Total Items**: Total count of registered medicines.
  - 📦 **Total Stock**: Sum of all medicine quantities.
  - 💰 **Total Value**: Total inventory value in currency (`price * quantity`).
  - ⚠️ **Low Stock**: Real-time count of items with quantity < 10.
  - ⏰ **Expired Medicines**: Real-time count of items past their expiry date.
- **Real-Time Search**: Instant filtering by medicine name with clear button and empty states.
- **Category Filter Chips**: Filter by `All`, `Tablet`, `Capsule`, `Syrup`, `Injection`, `Cream`, `Drops`, `Ointment`, `Powder`.
- **Sorting Options**: Sort inventory by Name (A-Z, Z-A), Price (Low → High, High → Low), Quantity, or Expiry Date.
- **Automatic Medicine Image Fetching**: Automatically searches and fetches relevant medical product images via Wikipedia REST API with curated fallbacks.
- **Swipe Actions (Gestures)**:
  - 👈 **Swipe Left**: Delete item with confirmation dialog & **Undo Delete SnackBar**.
  - 👉 **Swipe Right**: Edit item directly.
- **Low Stock & Expired Badges**: Visual badges (`LOW STOCK`, `EXPIRED`) auto-applied to list cards.
- **Shimmer Skeleton Loading & Hero Animations**: Smooth loading animations and continuous image transitions.
- **Complete CRUD Operations**: Add, view, edit, single delete, and **Delete All** with confirmation safety.

---

## 📱 Project Structure

```text
lib/
├── database/
│   └── database_helper.dart      # SQLite initialization & singleton
├── models/
│   └── medicine.dart             # Medicine data model with imageUrl
├── routes/
│   └── app_routes.dart           # Generic & dot-accessible navigation
├── services/
│   ├── medicine_service.dart     # SQLite CRUD service operations
│   └── image_service.dart        # Wikipedia REST API & image fallback service
├── viewmodels/
│   ├── base_viewmodel.dart       # Abstract ChangeNotifier base class
│   ├── home_viewmodel.dart       # Home search, filter, sort, & dashboard logic
│   ├── add_medicine_viewmodel.dart # Form validation & medicine insertion logic
│   └── edit_medicine_viewmodel.dart# Form validation & medicine update logic
├── screens/
│   ├── home_screen.dart          # Main dashboard, search, & swipeable list
│   ├── add_medicine_screen.dart  # Form screen for adding medicines
│   └── edit_medicine_screen.dart # Form screen for updating medicines
└── main.dart                     # App entry point & theme
```

---

## 🛠️ Tech Stack & Dependencies

- **Flutter & Dart**: Framework and language.
- **sqflite / sqflite_common_ffi**: SQLite database engine (mobile & desktop).
- **http**: REST API client for automatic image lookups.
- **path**: Cross-platform path management.
- **Material Design**: Custom light green theme and animated widgets.

---

## 📊 SQLite Database Schema

**Database Name:** `pharmacy.db`  
**Table Name:** `medicines`

| Column | Data Type | Description |
| :--- | :--- | :--- |
| `id` | `INTEGER` | Primary Key (Auto-increment) |
| `name` | `TEXT` | Medicine name |
| `company` | `TEXT` | Pharmaceutical manufacturer |
| `category` | `TEXT` | Category (Tablet, Syrup, etc.) |
| `quantity` | `INTEGER` | Stock count |
| `price` | `REAL` | Unit price |
| `expiryDate` | `TEXT` | Expiry date (`YYYY-MM-DD`) |
| `imageUrl` | `TEXT` | Automatic or custom image URL |

---

## 🏃 How to Run

1. **Clone Repository**:
   ```bash
   git clone <repository-url>
   cd pharmacy_Inventory_System
   ```
2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```
3. **Run Application**:
   ```bash
   flutter run
   ```

---

## 📜 License

This project is licensed under the MIT License.
