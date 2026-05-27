import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:salon_and_beauty/core/data/dummy_discounts.dart';
import 'package:salon_and_beauty/features/stylist/data/dummy_stylists.dart';
import 'package:salon_and_beauty/features/service/data/dummy_services.dart';
import 'package:salon_and_beauty/features/user/data/dummy_user.dart';
import 'package:salon_and_beauty/features/booking/data/dummy_bookings.dart';

class Seeder {
  /// Insert dummy data into DB tables if they are empty. Safe to call multiple times.
  static Future<void> seedIfNeeded(Database db) async {
    // Check users
    final userCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM users')) ?? 0;
    if (userCount == 0) {
      final batch = db.batch();
      for (final user in DummyUser.data) {
        batch.insert('users', {
          'id': user.id,
          'name': user.name,
          'email': user.email,
          'phone': user.phone,
          'password': user.password,
        });
      }
      await batch.commit(noResult: true);
    }

    // Check stylists
    final stylistCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM stylists')) ?? 0;
    if (stylistCount == 0) {
      final batch = db.batch();
      for (final s in DummyStylists.data) {
        batch.insert('stylists', {
          ...s.toMap(),
        });
      }
      await batch.commit(noResult: true);
    }

    // Check services
    final serviceCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM services')) ?? 0;
    if (serviceCount == 0) {
      final batch = db.batch();
      for (final svc in DummyServices.data) {
        batch.insert('services', {
          ...svc.toMap(),
        });
      }
      await batch.commit(noResult: true);
    }

    // Check discounts
    final discountCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM discounts')) ?? 0;
    if (discountCount == 0) {
      final batch = db.batch();
      for (final discount in DummyDiscounts.data) {
        batch.insert('discounts', discount.toMap());
      }
      await batch.commit(noResult: true);
    }

    // Check bookings
    final bookingCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM bookings')) ?? 0;
    if (bookingCount == 0) {
      final batch = db.batch();
        for (final b in DummyBookings.upcoming) {
        batch.insert('bookings', {
          'id': b.id,
          'customerId': b.customerId,
          'stylistId': b.stylistId,
          'bookingDate': b.bookingDate.toIso8601String(),
          'bookingTime': b.bookingTime,
          'serviceIds': jsonEncode(b.serviceIds),
          'status': b.status.toString().split('.').last,
          'subtotal': b.subtotal,
          'discount': b.discount,
          'total': b.totalPrice,
          'notes': b.notes ?? '',
            'createdAt': b.createdAt.millisecondsSinceEpoch,
        });
      }
      for (final b in DummyBookings.history) {
        batch.insert('bookings', {
          'id': b.id,
          'customerId': b.customerId,
          'stylistId': b.stylistId,
          'bookingDate': b.bookingDate.toIso8601String(),
          'bookingTime': b.bookingTime,
          'serviceIds': jsonEncode(b.serviceIds),
          'status': b.status.toString().split('.').last,
          'subtotal': b.subtotal,
          'discount': b.discount,
          'total': b.totalPrice,
          'notes': b.notes ?? '',
            'createdAt': b.createdAt.millisecondsSinceEpoch,
        });
      }
      await batch.commit(noResult: true);
    }
  }
}
