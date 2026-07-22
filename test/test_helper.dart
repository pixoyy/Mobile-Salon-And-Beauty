import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:salon_and_beauty/Database/DatabaseHelper.dart';
import 'package:salon_and_beauty/Database/Seeder.dart';
import 'package:salon_and_beauty/Support/AuthSession.dart';

/// Initialize test environment: use sqflite ffi (in-memory), seed DB, bootstrap session.
Future<void> initTestEnv() async {
  // initialize ffi and set factory
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Use in-memory database
  DatabaseHelper.setTestDatabasePath(inMemoryDatabasePath);

  final db = await DatabaseHelper.instance.database;

  // Ensure seed data exists
  await Seeder.seedIfNeeded(db);

  // Bootstrap session from prefs/db
  await AuthSession.bootstrap();
}
