import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:salon_and_beauty/core/data/database_helper.dart';
import 'package:salon_and_beauty/features/auth/data/auth_repository.dart';

void main() {
  late Database db;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    db = await openDatabase(
      ':memory:',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            name TEXT,
            email TEXT,
            phone TEXT,
            password TEXT
          )
        ''');
      },
    );

    await DatabaseHelper.setTestDatabase(db);
  });

  tearDownAll(() async {
    await db.close();
  });

  test('register and login via DB', () async {
    final repo = AuthRepository();

    final result = await repo.register(
      name: 'Test User',
      email: 'test@example.com',
      password: 'password123',
      phone: '08123456789',
    );

    expect(result.isSuccess, true);

    final user = await repo.validateLogin(identifier: 'test@example.com', password: 'password123');
    expect(user, isNotNull);
    expect(user!.email, 'test@example.com');
  });
}
