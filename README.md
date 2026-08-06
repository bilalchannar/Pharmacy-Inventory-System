# 💊 Pharmacy Inventory System

A professional, beginner-friendly Flutter application designed to manage pharmacy stock efficiently. This project demonstrates a clean implementation of local data persistence using SQLite, following a structured Service-oriented architecture.

---

## 🚀 Features

- **SQLite Local Database**: Persistent storage for all medicine records.
- **Complete CRUD Operations**: Create, Read, Update, and Delete medicines seamlessly.
- **Service Layer Architecture**: Logic is separated from the UI for better maintainability.
- **Medicine Model**: Robust data modeling with serialization (toMap/fromMap).
- **Category Dropdown**: Simplified entry with predefined categories (Tablets, Syrups, etc.).
- **Smart Date Picker**: Interactive calendar for selecting expiry dates.
- **Input Validation**: Ensures data integrity for price, quantity, and required fields.
- **Details Dialog**: Quick view of all medicine information without leaving the home screen.
- **Cross-Platform Support**: Optimized for both **Android** and **Windows Desktop** (using SQLite FFI).
- **Consistent UI**: Clean and professional interface using a **Light Green** theme.

---

## 📱 Screens

### **Home Screen**
Displays a scrollable list of all medicines in the inventory. Includes a loading state, an empty state, and quick actions for viewing details, editing, or deleting a record.

### **Add Medicine Screen**
A form-based screen for adding new stock. Features rounded inputs, icons, and a dropdown for category selection.

### **Edit Medicine Screen**
Allows users to modify existing records. All fields are pre-filled with the current data for easy updates.

---

## 📂 Project Structure

```text
lib/
├── database/
│   └── database_helper.dart    # SQLite initialization & singleton
├── models/
│   └── medicine.dart           # Medicine data model
├── services/
│   └── medicine_service.dart   # Logic for CRUD operations
├── screens/
│   ├── home_screen.dart        # Main dashboard list
│   ├── add_medicine_screen.dart # Entry form
│   └── edit_medicine_screen.dart # Update form
└── main.dart                   # App entry point & theme
```

---

## 🛠️ Technologies & Packages

- **Flutter & Dart**: UI framework and language.
- **sqflite**: SQLite plugin for mobile.
- **sqflite_common_ffi**: Enables SQLite support for Windows/Desktop.
- **path**: Cross-platform path manipulation.
- **Material Design**: Modern UI components.

---

## 📊 SQLite Database Structure

**Database Name:** `pharmacy.db`  
**Table Name:** `medicines`

| Column | Data Type | Description |
| :--- | :--- | :--- |
| `id` | `INTEGER` | Primary Key (Auto-increment) |
| `name` | `TEXT` | Name of the medicine |
| `company` | `TEXT` | Pharmaceutical company name |
| `category` | `TEXT` | Category (Tablet, Syrup, etc.) |
| `quantity` | `INTEGER` | Stock count |
| `price` | `REAL` | Cost per unit |
| `expiryDate` | `TEXT` | Expiry date string |
| `imageUrl` | `TEXT` | Optional image path |

---

## 🏗️ Architecture & Flow

The app follows a simple but powerful flow:

**UI (Screens)**  
⬇️  
**Service Layer (`MedicineService`)**  
⬇️  
**Database Helper (`DatabaseHelper`)**  
⬇️  
**SQLite Engine**

### **CRUD Implementation**
- **Create**: Uses `db.insert` with `ConflictAlgorithm.replace`.
- **Read**: Uses `db.query` to fetch records and converts them to `Medicine` objects.
- **Update**: Uses `db.update` targeted by the unique `id`.
- **Delete**: Uses `db.delete` with a confirmation dialog to prevent data loss.

---

## 🏃 How to Run

1. **Clone the project**
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Run the app**:
   ```bash
   flutter run
   ```

---

## 🎓 Learning Concepts

This project covers several core Flutter and Mobile development concepts:
- Singleton Pattern (Database Access).
- Data Persistence with SQLite.
- Asynchronous Programming (`Future`, `async`, `await`).
- Form Handling & Validation.
- Modal Dialogs and Bottom Snacks.
- Managing State with `setState`.

---

## 🔮 Future Improvements

- [ ] **Search & Filtering**: Search medicines by name or filter by category.
- [ ] **Dashboard**: Statistics for total stock value and low-stock alerts.
- [ ] **Image Picker**: Attach photos of medicine packaging.
- [ ] **Export Data**: Generate PDF or CSV reports of the inventory.

---

## ✍️ Author

[Your Name]

---

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.
