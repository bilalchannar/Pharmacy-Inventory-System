import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../screens/add_medicine_screen.dart';
import '../screens/edit_medicine_screen.dart';
import '../screens/home_screen.dart';

/// Navigation helper class supporting generic navigation and screen-specific dot-notation methods.
class AppRoutes {
  AppRoutes._(); // Private constructor to prevent instantiation

  // ==========================================
  // Generic Navigation Methods
  // ==========================================

  /// Navigates to a new page (Push) and optionally returns typed result data.
  /// Example: `final result = await AppRoutes.push<bool>(context, const AddMedicineScreen());`
  static Future<T?> push<T>(BuildContext context, Widget page) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  /// Replaces current route with a new page (Push Replacement).
  /// Example: `AppRoutes.pushReplacement(context, const HomeScreen());`
  static Future<T?> pushReplacement<T, TO>(
    BuildContext context,
    Widget page, {
    TO? result,
  }) {
    return Navigator.pushReplacement<T, TO>(
      context,
      MaterialPageRoute(builder: (context) => page),
      result: result,
    );
  }

  /// Navigates to a page as a Modal / Fullscreen presentation (Present).
  /// Example: `AppRoutes.present(context, DetailsModal(item: item));`
  static Future<T?> present<T>(
    BuildContext context,
    Widget page, {
    bool fullscreenDialog = true,
  }) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(
        builder: (context) => page,
        fullscreenDialog: fullscreenDialog,
      ),
    );
  }

  /// Pops current route off navigator stack with optional result data.
  /// Example: `AppRoutes.pop(context);` or `AppRoutes.pop(context, true);`
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }

  // ==========================================
  // Direct Screen Navigation Methods (.Dot Access)
  // ==========================================

  /// Navigate to HomeScreen: `AppRoutes.toHomeScreen(context)` or `AppRoutes.homeScreen(context)`
  static Future<T?> homeScreen<T>(BuildContext context) =>
      pushReplacement<T, void>(context, const HomeScreen());

  static Future<T?> toHomeScreen<T>(BuildContext context) =>
      homeScreen<T>(context);

  /// Navigate to AddMedicineScreen: `AppRoutes.toAddMedicineScreen(context)` or `AppRoutes.addMedicineScreen(context)`
  static Future<bool?> addMedicineScreen(BuildContext context) =>
      push<bool>(context, const AddMedicineScreen());

  static Future<bool?> toAddMedicineScreen(BuildContext context) =>
      addMedicineScreen(context);

  /// Navigate to EditMedicineScreen with data: `AppRoutes.toEditMedicineScreen(context, medicine)` or `AppRoutes.editMedicineScreen(context, medicine)`
  static Future<bool?> editMedicineScreen(
    BuildContext context,
    Medicine medicine,
  ) =>
      push<bool>(context, EditMedicineScreen(medicine: medicine));

  static Future<bool?> toEditMedicineScreen(
    BuildContext context,
    Medicine medicine,
  ) =>
      editMedicineScreen(context, medicine);
}
