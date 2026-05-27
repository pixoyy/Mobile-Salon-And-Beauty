import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:salon_and_beauty/core/data/database_helper.dart';
import 'package:salon_and_beauty/core/data/seeder.dart';
import 'package:salon_and_beauty/core/session/auth_session.dart';

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
