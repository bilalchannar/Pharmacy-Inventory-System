import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future<void> configureDatabase() async {
  // Trying an alternative name that is sometimes used in different package versions
  databaseFactory = databaseFactoryFfiWeb;
}
