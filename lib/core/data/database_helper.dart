// import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:salon_and_beauty/core/data/seeder.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;
  // Optional test DB path override (used by tests to use in-memory DB)
  static String? testDatabasePath;

  /// Set a test database path (e.g. ':memory:') to force DatabaseHelper
  /// to open that path instead of using getApplicationDocumentsDirectory().
  static void setTestDatabasePath(String? path) {
    testDatabasePath = path;
  }

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('salon_and_beauty.db');
    return _database!;
  }

  /// Set a test database instance (used by unit tests).
  /// This will replace the internal singleton database instance.
  static Future<void> setTestDatabase(Database db) async {
    _database = db;
  }

  Future<Database> _initDB(String fileName) async {
    final String path;
    if (testDatabasePath != null) {
      path = testDatabasePath!;
    } else {
      final directory = await getApplicationDocumentsDirectory();
      path = join(directory.path, fileName);
    }

    final db = await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );

    // Seed initial data if needed (runs once on first open when tables empty)
    await Seeder.seedIfNeeded(db);

    return db;
  }

  Future _createDB(Database db, int version) async {
    await _createUsersTable(db);
    await _createStylistsTable(db);
    await _createServicesTable(db);
    await _createDiscountsTable(db);
    await _createBookingsTable(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Simple migration dispatcher. For now we only have version 1.
    // Future migrations should be added here with incremental steps.
    for (var v = oldVersion + 1; v <= newVersion; v++) {
      await _migrate(db, v);
    }
  }

  Future _migrate(Database db, int version) async {
    switch (version) {
      case 1:
        // initial version already created in onCreate
        break;
      case 2:
        await _createDiscountsTable(db, ifNotExists: true);
        await _ensureColumn(db, 'stylists', 'rating', 'REAL DEFAULT 0');
        await _ensureColumn(db, 'stylists', 'reviewCount', 'INTEGER DEFAULT 0');
        await _ensureColumn(db, 'stylists', 'experienceYears', 'INTEGER DEFAULT 0');
        await _ensureColumn(db, 'stylists', 'reviews', "TEXT DEFAULT '[]'");
        await _ensureColumn(db, 'stylists', 'bio', "TEXT DEFAULT ''");
        await _ensureColumn(db, 'services', 'isPopular', 'INTEGER DEFAULT 0');
        break;
      // case 2:
      //   await db.execute('ALTER TABLE bookings ADD COLUMN createdAt INTEGER');
      //   break;
      default:
        // No-op for unknown versions to avoid crash, but log for debugging.
        // No-op for unknown versions to avoid crash, but log for debugging in debug builds.
        if (kDebugMode) {
          // ignore: avoid_print
          debugPrint('DB migrate: no migration for version $version');
        }
    }
  }

  Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT,
        email TEXT,
        phone TEXT,
        password TEXT
      )
    ''');
  }

  Future<void> _createStylistsTable(Database db) async {
    await db.execute('''
      CREATE TABLE stylists (
        id TEXT PRIMARY KEY,
        name TEXT,
        specialization TEXT,
        skills TEXT,
        avatar TEXT,
        rating REAL DEFAULT 0,
        reviewCount INTEGER DEFAULT 0,
        experienceYears INTEGER DEFAULT 0,
        reviews TEXT DEFAULT '[]',
        bio TEXT DEFAULT ''
      )
    ''');
  }

  Future<void> _createServicesTable(Database db) async {
    await db.execute('''
      CREATE TABLE services (
        id TEXT PRIMARY KEY,
        name TEXT,
        category TEXT,
        description TEXT,
        price INTEGER,
        durationMinutes INTEGER,
        isPopular INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> _createDiscountsTable(Database db, {bool ifNotExists = false}) async {
    final clause = ifNotExists ? 'IF NOT EXISTS ' : '';
    await db.execute('''
      CREATE TABLE ${clause}discounts (
        code TEXT PRIMARY KEY,
        title TEXT,
        percent INTEGER,
        maxAmount INTEGER,
        minSpend INTEGER,
        startDate TEXT,
        endDate TEXT
      )
    ''');
  }

  Future<void> _createBookingsTable(Database db) async {
    await db.execute('''
      CREATE TABLE bookings (
        id TEXT PRIMARY KEY,
        customerId TEXT,
        stylistId TEXT,
        bookingDate TEXT,
        bookingTime TEXT,
        serviceIds TEXT,
        status TEXT,
        subtotal INTEGER,
        discount INTEGER,
        total INTEGER,
        notes TEXT,
        createdAt INTEGER
      )
    ''');
  }

  Future<void> _ensureColumn(
    Database db,
    String table,
    String column,
    String definition,
  ) async {
    final List<Map<String, Object?>> columns = await db.rawQuery('PRAGMA table_info($table)');
    final bool exists = columns.any((row) => row['name']?.toString() == column);
    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $definition');
    }
  }

  Future close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}
