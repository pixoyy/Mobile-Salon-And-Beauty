import 'dart:convert';

import 'booking_model.dart';
import 'dummy_bookings.dart';
import '../../service/data/service_repository.dart';
import '../../stylist/data/dummy_stylists.dart';
import '../../../core/session/auth_session.dart';
import '../domain/booking_availability_service.dart';
import 'package:salon_and_beauty/core/data/database_helper.dart';
import 'package:flutter/foundation.dart';

class BookingRepository {
  static final BookingRepository _instance = BookingRepository._internal();

  factory BookingRepository() {
    return _instance;
  }

  BookingRepository._internal() {
    _initializeDummyBookings();
  }

  static String get _activeCustomerId => AuthSession.activeCustomerId;
  // availability config moved to BookingAvailabilityService

  final List<BookingModel> _bookings = <BookingModel>[];

  void _initializeDummyBookings() {
    if (_bookings.isNotEmpty) {
      return;
    }

    _bookings
      ..addAll(DummyBookings.upcoming)
      ..addAll(DummyBookings.history);
  }

  Future<List<BookingModel>> getAllBookings({String? customerId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));

    final String targetCustomerId = customerId ?? _activeCustomerId;

    try {
      final db = await DatabaseHelper.instance.database;
      final rows = await db.query('bookings', where: 'customerId = ?', whereArgs: [targetCustomerId]);
      final List<BookingModel> result = rows.map((r) => _rowToBooking(r)).toList(growable: false);
      result.sort((a, b) => b.bookingDateTime.compareTo(a.bookingDateTime));
      return result;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('BookingRepository.getAllBookings DB error: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
      final List<BookingModel> filtered = _bookings
          .where((booking) => booking.customerId == targetCustomerId)
          .toList(growable: false);

      filtered.sort((a, b) => b.bookingDateTime.compareTo(a.bookingDateTime));
      return filtered;
    }
  }

  Future<BookingModel?> getBookingById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 160));

    try {
      final db = await DatabaseHelper.instance.database;
      final rows = await db.query('bookings', where: 'id = ?', whereArgs: [id]);
      if (rows.isEmpty) {
        for (final booking in _bookings) {
          if (booking.id == id) return booking;
        }
        return null;
      }
      return _rowToBooking(rows.first);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('BookingRepository.getBookingById DB error: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
      for (final booking in _bookings) {
        if (booking.id == id) return booking;
      }
      return null;
    }
  }

  Future<BookingModel> createBooking(BookingModel booking) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));

    final int bookingDurationMinutes = await BookingAvailabilityService.resolveBookingDurationMinutes(
      booking.serviceIds,
      ServiceRepository(),
    );

    final bool isAvailable = await BookingAvailabilityService.checkAvailability(
      _bookings,
      booking.stylistId,
      booking.bookingDate,
      booking.bookingTime,
      durationMinutes: bookingDurationMinutes,
    );

    if (!isAvailable) {
      throw StateError('Slot tidak tersedia untuk stylist terpilih.');
    }

    final String bookingId = booking.id.trim().isEmpty
        ? _generateBookingId()
        : booking.id;

    final BookingModel savedBooking = booking.copyWith(
      id: bookingId,
      createdAt: booking.createdAt,
    );

    try {
      final db = await DatabaseHelper.instance.database;
      final rows = await db.query('bookings');
      final bookings = rows.map((r) => _rowToBooking(r)).toList(growable: false);

      final bool isAvailableDb = await BookingAvailabilityService.checkAvailability(
        bookings,
        savedBooking.stylistId,
        savedBooking.bookingDate,
        savedBooking.bookingTime,
        durationMinutes: bookingDurationMinutes,
      );

      if (!isAvailableDb) {
        throw StateError('Slot tidak tersedia untuk stylist terpilih.');
      }

      final Map<String, dynamic> row = {
        'id': savedBooking.id,
        'customerId': savedBooking.customerId,
        'stylistId': savedBooking.stylistId,
        'serviceIds': jsonEncode(savedBooking.serviceIds),
        'bookingDate': savedBooking.bookingDate.toIso8601String(),
        'bookingTime': savedBooking.bookingTime,
        'subtotal': savedBooking.subtotal,
        'discount': savedBooking.discount,
        'total': savedBooking.totalPrice,
        'status': savedBooking.status.value,
        'notes': savedBooking.notes,
        'createdAt': savedBooking.createdAt.millisecondsSinceEpoch,
      };

      await db.insert('bookings', row);
      return savedBooking;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('BookingRepository.createBooking DB error: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
      // fallback to memory-based storage
      _bookings.add(savedBooking);
      return savedBooking;
    }
  }

  Future<BookingModel?> updateBooking(String id, BookingModel booking) async {
    await Future<void>.delayed(const Duration(milliseconds: 240));
    final BookingModel nextBooking = booking.copyWith(id: id);

    try {
      final db = await DatabaseHelper.instance.database;
      final rows = await db.query('bookings');
      final bookings = rows.map((r) => _rowToBooking(r)).toList(growable: false);

      final bool isAvailableDb = await BookingAvailabilityService.checkAvailability(
        bookings,
        nextBooking.stylistId,
        nextBooking.bookingDate,
        nextBooking.bookingTime,
        durationMinutes: await BookingAvailabilityService.resolveBookingDurationMinutes(
          nextBooking.serviceIds,
          ServiceRepository(),
        ),
        excludedBookingId: id,
      );

      if (!isAvailableDb) {
        throw StateError('Slot tidak tersedia untuk stylist terpilih.');
      }

      final Map<String, dynamic> row = {
        'customerId': nextBooking.customerId,
        'stylistId': nextBooking.stylistId,
        'serviceIds': jsonEncode(nextBooking.serviceIds),
        'bookingDate': nextBooking.bookingDate.toIso8601String(),
        'bookingTime': nextBooking.bookingTime,
        'subtotal': nextBooking.subtotal,
        'discount': nextBooking.discount,
        'total': nextBooking.totalPrice,
        'status': nextBooking.status.value,
        'notes': nextBooking.notes,
      };

      final updated = await db.update('bookings', row, where: 'id = ?', whereArgs: [id]);
      if (updated > 0) {
        return nextBooking;
      }
      // fallback to memory
      final int index = _bookings.indexWhere((item) => item.id == id);
      if (index < 0) return null;
      _bookings[index] = nextBooking;
      return nextBooking;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('BookingRepository.updateBooking DB error: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
      final int index = _bookings.indexWhere((item) => item.id == id);
      if (index < 0) {
        return null;
      }

      final bool isAvailable = await BookingAvailabilityService.checkAvailability(
        _bookings,
        nextBooking.stylistId,
        nextBooking.bookingDate,
        nextBooking.bookingTime,
        durationMinutes: await BookingAvailabilityService.resolveBookingDurationMinutes(
          nextBooking.serviceIds,
          ServiceRepository(),
        ),
        excludedBookingId: id,
      );

      if (!isAvailable) {
        throw StateError('Slot tidak tersedia untuk stylist terpilih.');
      }

      _bookings[index] = nextBooking;
      return nextBooking;
    }
  }

  Future<bool> deleteBooking(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    try {
      final db = await DatabaseHelper.instance.database;
      final deleted = await db.delete('bookings', where: 'id = ?', whereArgs: [id]);
      if (deleted > 0) return true;
      // fallback to memory
      final int index = _bookings.indexWhere((booking) => booking.id == id);
      if (index < 0) return false;
      _bookings.removeAt(index);
      return true;
    } catch (_) {
      final int index = _bookings.indexWhere((booking) => booking.id == id);
      if (index < 0) {
        return false;
      }

      _bookings.removeAt(index);
      return true;
    }
  }

  Future<List<String>> getAvailableSlotsForStylist(
    String stylistId,
    DateTime date,
    {int durationMinutes = 0}
  ) async {
    if (kDebugMode) {
      // ignore: avoid_print
      debugPrint('DBG: BookingRepository.getAvailableSlotsForStylist start: $stylistId ${date.toIso8601String()} duration=$durationMinutes');
    }
    try {
      final db = await DatabaseHelper.instance.database;
      final rows = await db.query('bookings');
      final bookings = rows.map((r) => _rowToBooking(r)).toList(growable: false);
      final List<String> result = await BookingAvailabilityService.getAvailableSlotsForStylist(
        bookings,
        stylistId,
        date,
        durationMinutes: durationMinutes,
      );
      if (kDebugMode) {
        // ignore: avoid_print
        debugPrint('DBG: BookingRepository.getAvailableSlotsForStylist result: ${result.length} slots');
      }
      return result;
    } catch (_) {
      final List<String> result = await BookingAvailabilityService.getAvailableSlotsForStylist(
        _bookings,
        stylistId,
        date,
        durationMinutes: durationMinutes,
      );
      if (kDebugMode) {
        // ignore: avoid_print
        debugPrint('DBG: BookingRepository.getAvailableSlotsForStylist result (fallback): ${result.length} slots');
      }
      return result;
    }
  }

  Future<bool> checkAvailability(
    String stylistId,
    DateTime date,
    String time, {
    int durationMinutes = 0,
    String? excludedBookingId,
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final rows = await db.query('bookings');
      final bookings = rows.map((r) => _rowToBooking(r)).toList(growable: false);
      return BookingAvailabilityService.checkAvailability(
        bookings,
        stylistId,
        date,
        time,
        durationMinutes: durationMinutes,
        excludedBookingId: excludedBookingId,
      );
    } catch (_) {
      return BookingAvailabilityService.checkAvailability(
        _bookings,
        stylistId,
        date,
        time,
        durationMinutes: durationMinutes,
        excludedBookingId: excludedBookingId,
      );
    }
  }

  Future<String?> getAvailabilityMessage(
    String stylistId,
    DateTime date,
    String time, {
    int durationMinutes = 0,
    String? excludedBookingId,
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final rows = await db.query('bookings');
      final bookings = rows.map((r) => _rowToBooking(r)).toList(growable: false);
      return BookingAvailabilityService.getAvailabilityMessage(
        bookings,
        stylistId,
        date,
        time,
        durationMinutes: durationMinutes,
        excludedBookingId: excludedBookingId,
      );
    } catch (_) {
      return BookingAvailabilityService.getAvailabilityMessage(
        _bookings,
        stylistId,
        date,
        time,
        durationMinutes: durationMinutes,
        excludedBookingId: excludedBookingId,
      );
    }
  }

  Future<List<BookingModel>> searchBookings(
    String query, {
    String? customerId,
  }) async {
    final String normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return getAllBookings(customerId: customerId);
    }

    await Future<void>.delayed(const Duration(milliseconds: 200));

    final String targetCustomerId = customerId ?? _activeCustomerId;

    final Map<String, String> stylistNamesById = {
      for (final stylist in DummyStylists.data)
        stylist.id: stylist.name.toLowerCase(),
    };

    final List<BookingModel> results = _bookings
        .where((booking) {
          if (booking.customerId != targetCustomerId) {
            return false;
          }

          final String stylistName = stylistNamesById[booking.stylistId] ?? '';
          final String dateText = _formatDate(booking.bookingDate);

          return stylistName.contains(normalizedQuery) ||
              dateText.contains(normalizedQuery);
        })
        .toList(growable: false);

    results.sort((a, b) => b.bookingDateTime.compareTo(a.bookingDateTime));

    return results;
  }

  BookingModel _rowToBooking(Map<String, dynamic> r) {
    final rawServiceIds = r['serviceIds']?.toString() ?? '[]';
    final List<dynamic> serviceJson = jsonDecode(rawServiceIds);
    final createdAtMillis = r['createdAt'];
    DateTime createdAt = DateTime(1970);
    if (createdAtMillis is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(createdAtMillis);
    } else if (createdAtMillis is String) {
      final parsed = int.tryParse(createdAtMillis);
      if (parsed != null) createdAt = DateTime.fromMillisecondsSinceEpoch(parsed);
    }

    return BookingModel(
      id: r['id']?.toString() ?? '',
      customerId: r['customerId']?.toString() ?? '',
      stylistId: r['stylistId']?.toString() ?? '',
      serviceIds: serviceJson.map((s) => s.toString()).toList(),
      bookingDate: DateTime.tryParse(r['bookingDate']?.toString() ?? '') ?? DateTime(1970),
      bookingTime: r['bookingTime']?.toString() ?? '00:00',
      subtotal: (r['subtotal'] is int) ? r['subtotal'] as int : int.tryParse(r['subtotal']?.toString() ?? '0') ?? 0,
      discount: (r['discount'] is int) ? r['discount'] as int : int.tryParse(r['discount']?.toString() ?? '0') ?? 0,
      totalPrice: (r['total'] is int) ? r['total'] as int : int.tryParse(r['total']?.toString() ?? '0') ?? 0,
      status: BookingStatusX.fromValue(r['status']?.toString() ?? BookingStatus.upcoming.value),
      notes: r['notes']?.toString(),
      createdAt: createdAt,
    );
  }

  String _generateBookingId() {
    // Use timestamp-based id to avoid collision between memory and DB seeds
    final int ts = DateTime.now().millisecondsSinceEpoch;
    return 'bk-$ts';
  }

  String _formatDate(DateTime date) {
    final String year = date.year.toString().padLeft(4, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

}
