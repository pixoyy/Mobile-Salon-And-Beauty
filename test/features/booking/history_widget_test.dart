import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:salon_and_beauty/features/booking/data/booking_model.dart';
import 'package:salon_and_beauty/features/booking/data/booking_repository.dart';
import 'package:salon_and_beauty/features/booking/presentation/history_page.dart';

Future<void> _pumpHistoryPage(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: HistoryPage()));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pump(const Duration(milliseconds: 350));
}

Future<BookingModel> _createBookingForTest({
  required BookingRepository repository,
  required String id,
  required BookingStatus status,
  required int dayOffset,
}) async {
  final DateTime date = DateTime(2035, 1, 1 + dayOffset);
  final List<String> availableSlots = await repository.getAvailableSlotsForStylist('sty-001', date);
  final String bookingTime = availableSlots.isNotEmpty ? availableSlots.first : '09:00';

  return repository.createBooking(
    BookingModel(
      id: id,
      customerId: 'cus-001',
      stylistId: 'sty-001',
      serviceIds: const <String>['svc-001'],
      bookingDate: date,
      bookingTime: bookingTime,
      subtotal: 95000,
      discount: 0,
      totalPrice: 95000,
      status: status,
      notes: 'Test booking $id',
      createdAt: DateTime(2034, 12, 31, 10, dayOffset),
    ),
  );
}

Future<void> _setAllBookingsToCompleted(BookingRepository repository) async {
  final List<BookingModel> all = await repository.getAllBookings();

  for (final BookingModel booking in all) {
    if (booking.status == BookingStatus.completed) {
      continue;
    }
    await repository.updateBooking(
      booking.id,
      booking.copyWith(status: BookingStatus.completed),
    );
  }
}

void main() {
  group('HistoryPage widget tests', () {
    testWidgets('filter status menampilkan hasil sesuai status', (WidgetTester tester) async {
      final BookingRepository repository = BookingRepository();
      final BookingModel pendingBooking = await _createBookingForTest(
        repository: repository,
        id: 'bk-901',
        status: BookingStatus.pending,
        dayOffset: 1,
      );
      final BookingModel completedBooking = await _createBookingForTest(
        repository: repository,
        id: 'bk-902',
        status: BookingStatus.completed,
        dayOffset: 2,
      );

      await _pumpHistoryPage(tester);

      await tester.tap(find.text('Pending'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text(pendingBooking.bookingCode), findsOneWidget);
      expect(find.text(completedBooking.bookingCode), findsNothing);

      await tester.tap(find.text('Completed'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text(completedBooking.bookingCode), findsOneWidget);
      expect(find.text(pendingBooking.bookingCode), findsNothing);
    });

    testWidgets('open detail dari list riwayat berhasil', (WidgetTester tester) async {
      final BookingRepository repository = BookingRepository();
      final BookingModel booking = await _createBookingForTest(
        repository: repository,
        id: 'bk-903',
        status: BookingStatus.pending,
        dayOffset: 3,
      );

      await _pumpHistoryPage(tester);

      await tester.tap(find.text(booking.bookingCode));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Detail Booking'), findsOneWidget);
      expect(find.text(booking.bookingCode), findsOneWidget);
    });

    testWidgets('cancel flow mengubah status booking menjadi dibatalkan', (WidgetTester tester) async {
      final BookingRepository repository = BookingRepository();
      final BookingModel booking = await _createBookingForTest(
        repository: repository,
        id: 'bk-904',
        status: BookingStatus.pending,
        dayOffset: 4,
      );

      await _pumpHistoryPage(tester);

      await tester.tap(find.text(booking.bookingCode));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Detail Booking'), findsOneWidget);

      await tester.tap(find.text('Cancel Booking'));
      await tester.pump();
      expect(find.text('Batalkan booking?'), findsOneWidget);

      await tester.tap(find.text('Ya, batalkan'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final BookingModel? updated = await repository.getBookingById(booking.id);
      expect(updated, isNotNull);
      expect(updated!.status, BookingStatus.cancelled);

      await tester.tap(find.text('Dibatalkan'));
      await tester.pumpAndSettle();
      expect(find.text(booking.bookingCode), findsOneWidget);
    });

    testWidgets('empty state tampil ketika hasil filter kosong', (WidgetTester tester) async {
      final BookingRepository repository = BookingRepository();
      await _setAllBookingsToCompleted(repository);

      await _pumpHistoryPage(tester);

      await tester.tap(find.text('Pending'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Belum ada riwayat booking'), findsOneWidget);
      expect(find.text('Muat Ulang'), findsOneWidget);
    });
  });
}
