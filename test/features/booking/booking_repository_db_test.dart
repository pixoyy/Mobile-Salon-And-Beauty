import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:salon_and_beauty/core/data/database_helper.dart';
import 'package:salon_and_beauty/features/booking/data/booking_repository.dart';
import 'package:salon_and_beauty/features/booking/data/booking_model.dart';

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

        await db.execute('''
          CREATE TABLE stylists (
            id TEXT PRIMARY KEY,
            name TEXT,
            specialization TEXT,
            skills TEXT,
            avatar TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE services (
            id TEXT PRIMARY KEY,
            name TEXT,
            category TEXT,
            description TEXT,
            price INTEGER,
            durationMinutes INTEGER
          )
        ''');

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
      },
    );

    await DatabaseHelper.setTestDatabase(db);
  });

  tearDownAll(() async {
    await db.close();
  });

  test('create -> read -> update -> delete booking (db)', () async {
    final repo = BookingRepository();

    final booking = BookingModel(
      id: '',
      customerId: 'u-test',
      stylistId: 's-test',
      serviceIds: ['svc1'],
      bookingDate: DateTime.now().add(const Duration(days: 1)),
      bookingTime: '10:00',
      status: BookingStatus.upcoming,
    );

    final saved = await repo.createBooking(booking);
    expect(saved.id.isNotEmpty, true);

    final all = await repo.getAllBookings(customerId: 'u-test');
    expect(all.length, 1);

    final updated = saved.copyWith(notes: 'please be on time');
    final u = await repo.updateBooking(saved.id, updated);
    expect(u?.notes, 'please be on time');

    final deleted = await repo.deleteBooking(saved.id);
    expect(deleted, true);

    final after = await repo.getAllBookings(customerId: 'u-test');
    expect(after.isEmpty, true);
  });
}
