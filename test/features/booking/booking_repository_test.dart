import 'package:flutter_test/flutter_test.dart';

import 'package:salon_and_beauty/core/session/auth_session.dart';
import 'package:salon_and_beauty/features/booking/data/booking_model.dart';
import 'package:salon_and_beauty/features/booking/data/booking_repository.dart';
import 'package:salon_and_beauty/features/user/data/user_model.dart';

void main() {
  UserModel? previousUser;

  setUp(() {
    previousUser = AuthSession.currentUser;
  });

  tearDown(() {
    AuthSession.currentUser = previousUser;
  });

  test('booking availability follows minute-accurate service duration', () async {
    final BookingRepository repository = BookingRepository();
    final DateTime date = DateTime(2026, 12, 12);

    await repository.createBooking(
      BookingModel(
        id: '',
        customerId: 'cus-duration-001',
        stylistId: 'sty-001',
        serviceIds: <String>['svc-001', 'svc-002'],
        bookingDate: date,
        bookingTime: '09:00',
        subtotal: 230000,
        discount: 0,
        totalPrice: 230000,
        status: BookingStatus.pending,
        createdAt: DateTime(2026, 12, 1),
      ),
    );

    final bool nineAmAvailable = await repository.checkAvailability(
      'sty-001',
      date,
      '09:00',
      durationMinutes: 105,
    );
    final bool tenAmAvailable = await repository.checkAvailability(
      'sty-001',
      date,
      '10:00',
      durationMinutes: 105,
    );
    final bool elevenAmAvailable = await repository.checkAvailability(
      'sty-001',
      date,
      '11:00',
      durationMinutes: 105,
    );

    final List<String> slots = await repository.getAvailableSlotsForStylist(
      'sty-001',
      date,
      durationMinutes: 105,
    );

    expect(nineAmAvailable, isFalse);
    expect(tenAmAvailable, isFalse);
    expect(elevenAmAvailable, isTrue);
    expect(slots, isNot(contains('09:00')));
    expect(slots, isNot(contains('10:00')));
    expect(slots, contains('11:00'));
  });

  test('booking availability allows a one-hour service starting at 08:00', () async {
    final BookingRepository repository = BookingRepository();
    final DateTime date = DateTime(2026, 12, 14);

    final bool eightAmAvailable = await repository.checkAvailability(
      'sty-003',
      date,
      '08:00',
      durationMinutes: 60,
    );

    final String? message = await repository.getAvailabilityMessage(
      'sty-003',
      date,
      '08:00',
      durationMinutes: 60,
    );

    expect(eightAmAvailable, isTrue);
    expect(message, isNull);
  });

  test('booking availability returns a clear message when time is insufficient', () async {
    final BookingRepository repository = BookingRepository();
    final DateTime date = DateTime(2026, 12, 15);

    final String? message = await repository.getAvailabilityMessage(
      'sty-004',
      date,
      '19:00',
      durationMinutes: 100,
    );

    expect(message, isNotNull);
    expect(
      message,
      contains('belum cukup untuk durasi layanan ini'),
    );
  });

  test('booking availability blocks only the exact occupied range', () async {
    final BookingRepository repository = BookingRepository();
    final DateTime date = DateTime(2026, 12, 13);

    await repository.createBooking(
      BookingModel(
        id: '',
        customerId: 'cus-duration-002',
        stylistId: 'sty-002',
        serviceIds: <String>['svc-004'],
        bookingDate: date,
        bookingTime: '12:00',
        subtotal: 650000,
        discount: 0,
        totalPrice: 650000,
        status: BookingStatus.pending,
        createdAt: DateTime(2026, 12, 1),
      ),
    );

    final bool threePmAvailable = await repository.checkAvailability(
      'sty-002',
      date,
      '15:00',
      durationMinutes: 60,
    );
    final bool fourPmAvailable = await repository.checkAvailability(
      'sty-002',
      date,
      '16:00',
      durationMinutes: 60,
    );

    expect(threePmAvailable, isFalse);
    expect(fourPmAvailable, isTrue);
  });

  test('booking repository scopes new bookings to the active session customer', () async {
    final BookingRepository repository = BookingRepository();
    final UserModel activeUser = const UserModel(
      id: 'cus-step9-001',
      name: 'Step Nine User',
      email: 'step9@example.com',
      phone: '081200000009',
      password: 'password123',
    );

    AuthSession.currentUser = activeUser;

    final BookingModel createdBooking = await repository.createBooking(
      BookingModel(
        id: '',
        customerId: AuthSession.activeCustomerId,
        stylistId: 'sty-step9-001',
        serviceIds: <String>['svc-002'],
        bookingDate: DateTime(2026, 12, 14),
        bookingTime: '10:00',
        subtotal: 135000,
        discount: 0,
        totalPrice: 135000,
        status: BookingStatus.pending,
        createdAt: DateTime(2026, 12, 1),
      ),
    );

    final List<BookingModel> bookings = await repository.getAllBookings();

    expect(bookings, contains(predicate<BookingModel>((booking) => booking.id == createdBooking.id)));
    expect(bookings, everyElement(predicate<BookingModel>((booking) => booking.customerId == activeUser.id)));
  });

  test('booking slot allows 20:00 for services up to 60 minutes', () async {
    final BookingRepository repository = BookingRepository();
    final DateTime date = DateTime(2026, 12, 13);

    final bool lateSlotAvailable = await repository.checkAvailability(
      'sty-002',
      date,
      '20:00',
      durationMinutes: 60,
    );

    final String? message = await repository.getAvailabilityMessage(
      'sty-002',
      date,
      '20:00',
      durationMinutes: 60,
    );

    expect(lateSlotAvailable, isTrue);
    expect(message, isNull);
  });

  test('booking slot rejects 20:00 for services longer than 60 minutes', () async {
    final BookingRepository repository = BookingRepository();
    final DateTime date = DateTime(2026, 12, 13);

    final bool lateSlotAvailable = await repository.checkAvailability(
      'sty-002',
      date,
      '20:00',
      durationMinutes: 100,
    );

    final String? message = await repository.getAvailabilityMessage(
      'sty-002',
      date,
      '20:00',
      durationMinutes: 100,
    );

    expect(lateSlotAvailable, isFalse);
    expect(message, isNotNull);
    expect(
      message,
      contains('Jam 20:00 hanya bisa dipakai untuk layanan berdurasi maksimal 60 menit'),
    );
  });
}
