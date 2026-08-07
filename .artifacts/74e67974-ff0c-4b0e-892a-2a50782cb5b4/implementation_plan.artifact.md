# Implementation Plan — Pharmacy Inventory Optimization

Optimize the Pharmacy Inventory System by refactoring the UI to follow strict coding styles (no helper methods), improving performance, and cleaning up redundant logic while preserving all functionality.

## User Review Required

> [!IMPORTANT]
> **UI Flattening**: All `_buildX` helper methods in `HomeScreen` will be moved directly into the `build()` method. This will result in a large `build()` method, as per the user's explicit instructions in Phase 3.
>
> [!NOTE]
> **Interaction Redundancy**: I will keep both Swipe and Button interactions for now as per "do not remove functionality," but I will clean up the UI to make them feel more integrated.

## Proposed Changes

### [Component] UI Refactoring & Cleanup

#### [MODIFY] [home_screen.dart](file:///D:/FlutterProjects/pharmacy_Inventory_System/lib/screens/home_screen.dart)
- Remove `_buildDashboardCard`, `_buildMedicineImage`, and `_buildSkeletonLoader`.
- Move the logic for these widgets directly into the `build` method.
- Optimize `ListenableBuilder` placement to avoid rebuilding the dashboard when searching.
- Add `const` where possible.
- Clean up redundancy in the medicine list item (unify Edit/Delete buttons).

#### [MODIFY] [add_medicine_screen.dart](file:///D:/FlutterProjects/pharmacy_Inventory_System/lib/screens/add_medicine_screen.dart)
- Move UI logic into `build` (already mostly there).
- Improve `InputDecoration` by using `ThemeData` or shared constants (if appropriate, otherwise keep inline).
- Ensure consistent spacing and alignment.

#### [MODIFY] [edit_medicine_screen.dart](file:///D:/FlutterProjects/pharmacy_Inventory_System/lib/screens/edit_medicine_screen.dart)
- Consistent with `AddMedicineScreen` changes.

---

### [Component] ViewModel & Logic Improvements

#### [MODIFY] [home_viewmodel.dart](file:///D:/FlutterProjects/pharmacy_Inventory_System/lib/viewmodels/home_viewmodel.dart)
- Refactor `fetchMedicines` to remove the side-effect of updating the database during a fetch.
- Improve sorting logic for better readability.

#### [MODIFY] [main.dart](file:///D:/FlutterProjects/pharmacy_Inventory_System/lib/main.dart)
- Update `ThemeData` to centralize UI styles (like input decorations) to reduce code duplication in screens.

---

### [Component] Global Cleanup

#### [MODIFY] [medicine.dart](file:///D:/FlutterProjects/pharmacy_Inventory_System/lib/models/medicine.dart)
- Add equality (`==`) and `hashCode` for better list operations.

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure no linting errors or deprecated API usage.
- Run the app and verify:
    - Searching works in real-time.
    - Sorting updates the list correctly.
    - Adding/Editing/Deleting medicines works and updates the UI instantly.
    - Low stock/Expired tags appear correctly.

### Manual Verification
- Verify that no `_buildX` methods exist in the code.
- Verify that the dashboard cards do not flicker when typing in the search bar.
- Verify swipe actions (Left to delete, Right to edit) work as expected.
