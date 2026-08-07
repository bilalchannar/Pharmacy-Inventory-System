# Project Audit Report — Pharmacy Inventory System

## 1. Categorized Issues

### 🏗️ Architecture & Organization
- **State Management**: Using `ChangeNotifier` and `ListenableBuilder` is appropriate, but the implementation is too broad. Root-level `ListenableBuilder` in `HomeScreen` and `Add/EditMedicineScreen` causes unnecessary rebuilds of static components (like app bars or dashboard headers).
- **Service Layer**: `MedicineService` is well-implemented, but `HomeViewModel` performs database updates inside its `fetchMedicines` method. Fetch methods should ideally be side-effect free.
- **Model Logic**: `Medicine` model is basic; consider adding equality checks (`==` and `hashCode`) for better list comparisons if needed.

### 💻 Code Quality (Phase 3 Violations)
- **Widget Helper Methods**: `HomeScreen` violates strict coding rules by using:
    - `_buildDashboardCard`
    - `_buildMedicineImage`
    - `_buildSkeletonLoader`
- **UI in build()**: While most UI is in `build()`, the extraction of these methods makes the code harder to follow according to the provided requirements.
- **Redundant Logic**: Similar validation and saving logic exists in both `AddMedicineViewModel` and `EditMedicineViewModel`.

### 🎨 UI/UX & Design
- **Redundant Interactions**: The medicine list items support both **Swipe-to-Edit/Delete** and **Buttons-to-Edit/Delete** (inside `ExpansionTile` trailing and `Dismissible`). This redundancy can lead to user confusion.
- **Form Consistency**: The `InputDecoration` for text fields is repeated many times across screens. While custom widgets are limited, using a shared `ThemeData` or simple constants would improve maintainability.
- **Loading/Empty States**: Present but could be more visually engaging and optimized.

### ⚡ Performance
- **Rebuilds**: Granularity of `ListenableBuilder` needs improvement. For example, typing in the search bar shouldn't rebuild the dashboard summary cards.
- **Memory Management**: `TextEditingController`s are properly disposed, which is good.
- **Const Constructors**: Many widgets that are static are not marked `const`, leading to unnecessary object allocations during build cycles.

### 🐛 Logical Issues & Bugs
- **Fragile URL Logic**: `HomeViewModel.fetchMedicines` checks for specific hardcoded substrings in `imageUrl` to "fix" them. This is prone to breaking if image URLs change.
- **Validation**: Basic validation is present, but could be more robust (e.g., checking for future dates in expiry, although not strictly required by the prompt, it's good practice).

## 2. Suggested Improvements
1.  **Flatten UI**: Move all `_build...` methods into the `build()` method of `HomeScreen`.
2.  **Optimize Rebuilds**: Split `ListenableBuilder` into smaller parts or use `Selector`-like patterns (though sticking to `ListenableBuilder` is fine if used carefully).
3.  **UI Cleanup**: Decide on one primary interaction for Edit/Delete (Buttons vs Swipe). I recommend keeping Swipe for power users but keeping Buttons visible for discoverability, or unifying them.
4.  **Theming**: Move common decorations to `ThemeData`.
5.  **Refactor Services**: Move the "URL fixing" logic into a separate initialization or sync function rather than `fetchMedicines`.

## 3. Production Readiness
The project is functional and follows a good basic structure, but requires significant "flattening" to meet the user's specific coding style requirements and optimization for performance.
