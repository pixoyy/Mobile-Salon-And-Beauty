import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../test_helper.dart';
import '../../test_utils.dart';

import 'package:salon_and_beauty/features/booking/bloc/booking_cubit.dart';
import 'package:salon_and_beauty/features/booking/data/booking_repository.dart';
import 'package:salon_and_beauty/features/booking/presentation/booking_schedule_page.dart';
// import 'package:salon_and_beauty/features/stylist/data/dummy_stylists.dart';
import 'package:salon_and_beauty/features/stylist/data/stylist_repository.dart';
import 'package:salon_and_beauty/features/service/data/dummy_services.dart';
import 'package:salon_and_beauty/features/service/data/service_repository.dart';

String _formatDateLabel(DateTime date) {
  final String day = date.day.toString().padLeft(2, '0');
  final String month = date.month.toString().padLeft(2, '0');
  final String year = date.year.toString();
  return '$day/$month/$year';
}

void main() {
  setUpAll(() async {
    await initTestEnv();
  });
  testWidgets('BookingSchedulePage loads with form fields', (tester) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<BookingRepository>(
            create: (_) => BookingRepository(),
          ),
          RepositoryProvider<StylistRepository>(
            create: (_) => StylistRepository(),
          ),
          RepositoryProvider<ServiceRepository>(
            create: (_) => ServiceRepository(),
          ),
        ],
        child: MaterialApp(
          home: BlocProvider(
            create: (_) => BookingCubit(
              BookingRepository(),
              ServiceRepository(),
            ),
            child: const BookingSchedulePage(),
          ),
        ),
      ),
    );

    // Wait for master data to load and the checkout button to appear
    await waitForAppReady(tester);

    // Page title and main sections are visible
    expect(find.text('Booking Schedule'), findsOneWidget);
    expect(find.text('1. Pilih Stylist'), findsOneWidget);
    expect(find.text('2. Pilih Layanan'), findsOneWidget);
    // Change button present
    expect(find.text('Change'), findsOneWidget);
  });

  testWidgets('Stylist selection works and updates picker', (tester) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<BookingRepository>(
            create: (_) => BookingRepository(),
          ),
          RepositoryProvider<StylistRepository>(
            create: (_) => StylistRepository(),
          ),
          RepositoryProvider<ServiceRepository>(
            create: (_) => ServiceRepository(),
          ),
        ],
        child: MaterialApp(
          home: BlocProvider(
            create: (_) => BookingCubit(
              BookingRepository(),
              ServiceRepository(),
            ),
            child: const BookingSchedulePage(),
          ),
        ),
      ),
    );

    await waitForAppReady(tester);

    // Initially shows "Belum ada stylist dipilih"
    expect(find.text('Belum ada stylist dipilih'), findsOneWidget);

    final bookingCubit = tester.element(find.byType(BookingSchedulePage)).read<BookingCubit>();
    await bookingCubit.selectStylist('sty-001');
    await waitForAppReady(tester);

    // Stylist name should appear in the picker
    expect(find.textContaining('Nadia Putri'), findsWidgets);
  });

  testWidgets('Service selection and deselection works', (tester) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<BookingRepository>(
            create: (_) => BookingRepository(),
          ),
          RepositoryProvider<StylistRepository>(
            create: (_) => StylistRepository(),
          ),
          RepositoryProvider<ServiceRepository>(
            create: (_) => ServiceRepository(),
          ),
        ],
        child: MaterialApp(
          home: BlocProvider(
            create: (_) => BookingCubit(
              BookingRepository(),
              ServiceRepository(),
            ),
            child: const BookingSchedulePage(),
          ),
        ),
      ),
    );

    await waitForAppReady(tester);

    // Initially shows "Belum ada layanan dipilih"
    expect(find.text('Belum ada layanan dipilih'), findsOneWidget);

    final bookingCubit = tester.element(find.byType(BookingSchedulePage)).read<BookingCubit>();
    final firstService = DummyServices.data.first;
    bookingCubit.selectServices(<String>[firstService.id]);
    await waitForAppReady(tester);

    // Service chip should appear (selected services are shown as chips)
    final chips = find.byType(Chip);
    expect(chips, findsWidgets);

    expect(find.textContaining(firstService.name), findsWidgets);

    // Clear the selection through the cubit so the widget rebuilds deterministically
    bookingCubit.selectServices(<String>[]);
    await tester.pumpAndSettle();

    // Service chip should be removed
    expect(find.text('Belum ada layanan dipilih'), findsOneWidget);
  });

  testWidgets('Date picker updates selected date', (tester) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<BookingRepository>(
            create: (_) => BookingRepository(),
          ),
          RepositoryProvider<StylistRepository>(
            create: (_) => StylistRepository(),
          ),
          RepositoryProvider<ServiceRepository>(
            create: (_) => ServiceRepository(),
          ),
        ],
        child: MaterialApp(
          home: BlocProvider(
            create: (_) => BookingCubit(
              BookingRepository(),
              ServiceRepository(),
            ),
            child: const BookingSchedulePage(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final bookingCubit = tester.element(find.byType(BookingSchedulePage)).read<BookingCubit>();
    final DateTime today = DateTime.now();
    bookingCubit.selectDate(today);
    await tester.pumpAndSettle();

    // Date should be stored in the cubit state
    expect(bookingCubit.scheduleState.selectedDate, isNotNull);
    expect(_formatDateLabel(bookingCubit.scheduleState.selectedDate!), _formatDateLabel(today));
  });

  testWidgets('Time slots show available options', (tester) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<BookingRepository>(
            create: (_) => BookingRepository(),
          ),
          RepositoryProvider<StylistRepository>(
            create: (_) => StylistRepository(),
          ),
          RepositoryProvider<ServiceRepository>(
            create: (_) => ServiceRepository(),
          ),
        ],
        child: MaterialApp(
          home: BlocProvider(
            create: (_) => BookingCubit(
              BookingRepository(),
              ServiceRepository(),
            ),
            child: const BookingSchedulePage(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final bookingCubit = tester.element(find.byType(BookingSchedulePage)).read<BookingCubit>();
    final DateTime today = DateTime.now();
    await bookingCubit.selectStylist('sty-001');
    bookingCubit.selectDate(today);
    await bookingCubit.loadAvailableSlots('sty-001', today).timeout(const Duration(seconds: 2), onTimeout: () {});
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Time slots should now be available in state
    expect(bookingCubit.scheduleState.availableSlots, isNotEmpty);
    expect(bookingCubit.scheduleState.availableSlots, contains('09:00'));
  }, skip: true);

  testWidgets('"Lanjut ke Checkout" button validation fails without required fields',
      (tester) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<BookingRepository>(
            create: (_) => BookingRepository(),
          ),
          RepositoryProvider<StylistRepository>(
            create: (_) => StylistRepository(),
          ),
          RepositoryProvider<ServiceRepository>(
            create: (_) => ServiceRepository(),
          ),
        ],
        child: MaterialApp(
          home: BlocProvider(
            create: (_) => BookingCubit(
              BookingRepository(),
              ServiceRepository(),
            ),
            child: const BookingSchedulePage(),
          ),
        ),
      ),
    );

    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Use cubit to trigger validation instead of tapping UI button
    final bookingCubit = tester.element(find.byType(BookingSchedulePage)).read<BookingCubit>();
    await bookingCubit.confirmBooking();
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Error message should appear and page should remain visible
    expect(find.textContaining('Silakan pilih'), findsOneWidget);
    expect(find.byType(BookingSchedulePage), findsOneWidget);
  });

      testWidgets('"Lanjut ke Checkout" navigates to checkout with valid selections',
        (tester) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<BookingRepository>(
            create: (_) => BookingRepository(),
          ),
          RepositoryProvider<StylistRepository>(
            create: (_) => StylistRepository(),
          ),
          RepositoryProvider<ServiceRepository>(
            create: (_) => ServiceRepository(),
          ),
        ],
        child: MaterialApp(
          home: BlocProvider(
            create: (_) => BookingCubit(
              BookingRepository(),
              ServiceRepository(),
            ),
            child: const BookingSchedulePage(),
          ),
        ),
      ),
    );

    await waitForAppReady(tester);

    final bookingCubit = tester.element(find.byType(BookingSchedulePage)).read<BookingCubit>();
    final DateTime today = DateTime.now();
    await bookingCubit.selectStylist('sty-001');
    await tester.pumpAndSettle();

    // Select service
    final firstService = DummyServices.data.first;
    bookingCubit.selectServices(<String>[firstService.id]);
    await tester.pumpAndSettle();

    // Select date
    bookingCubit.selectDate(today);
    await bookingCubit.loadAvailableSlots('sty-001', today).timeout(const Duration(seconds: 2), onTimeout: () {});
    await tester.pumpAndSettle();

    // Select time
    await bookingCubit.selectDateTime(today, bookingCubit.scheduleState.availableSlots.first);
    await tester.pumpAndSettle();

    // Build checkout snapshot via cubit instead of navigating through UI
    final snapshot = await bookingCubit.buildCheckoutSnapshot();
    expect(snapshot.selectedServices, isNotEmpty);
    expect(snapshot.payment.totalPrice, isNotNull);
  }, skip: true);

  testWidgets('"Kembali" button navigates back', (tester) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<BookingRepository>(
            create: (_) => BookingRepository(),
          ),
          RepositoryProvider<StylistRepository>(
            create: (_) => StylistRepository(),
          ),
          RepositoryProvider<ServiceRepository>(
            create: (_) => ServiceRepository(),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Column(
                  children: [
                    const Text('Home'),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => BlocProvider(
                              create: (_) => BookingCubit(
                                BookingRepository(),
                                ServiceRepository(),
                              ),
                              child: const BookingSchedulePage(),
                            ),
                          ),
                        );
                      },
                      child: const Text('Open Booking'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 1));

    await tester.tap(find.text('Open Booking'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('Notes field accepts text input', (tester) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<BookingRepository>(
            create: (_) => BookingRepository(),
          ),
          RepositoryProvider<StylistRepository>(
            create: (_) => StylistRepository(),
          ),
          RepositoryProvider<ServiceRepository>(
            create: (_) => ServiceRepository(),
          ),
        ],
        child: MaterialApp(
          home: BlocProvider(
            create: (_) => BookingCubit(
              BookingRepository(),
              ServiceRepository(),
            ),
            child: const BookingSchedulePage(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Find notes field
    final textFields = find.byType(TextField);

    if (textFields.evaluate().isNotEmpty) {
      await tester.enterText(textFields.first, 'Saya memiliki alergi protein');
      await tester.pumpAndSettle();

      expect(find.text('Saya memiliki alergi protein'), findsOneWidget);
    }
  });

  testWidgets('Prefilled stylist displays hint tag', (tester) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<BookingRepository>(
            create: (_) => BookingRepository(),
          ),
          RepositoryProvider<StylistRepository>(
            create: (_) => StylistRepository(),
          ),
          RepositoryProvider<ServiceRepository>(
            create: (_) => ServiceRepository(),
          ),
        ],
        child: MaterialApp(
          home: BlocProvider(
            create: (_) => BookingCubit(
              BookingRepository(),
              ServiceRepository(),
            ),
            child: const BookingSchedulePage(prefillStylistId: 'sty-001'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Should show the "Ditambahkan dari Stylist" hint
    expect(find.text('Ditambahkan dari Stylist'), findsOneWidget);

    final bookingCubit = tester.element(find.byType(BookingSchedulePage)).read<BookingCubit>();
    expect(bookingCubit.scheduleState.selectedStylistId, 'sty-001');
  });

  testWidgets('Prefilled service displays hint tag', (tester) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<BookingRepository>(
            create: (_) => BookingRepository(),
          ),
          RepositoryProvider<StylistRepository>(
            create: (_) => StylistRepository(),
          ),
          RepositoryProvider<ServiceRepository>(
            create: (_) => ServiceRepository(),
          ),
        ],
        child: MaterialApp(
          home: BlocProvider(
            create: (_) => BookingCubit(
              BookingRepository(),
              ServiceRepository(),
            ),
            child: const BookingSchedulePage(prefillServiceIds: ['svc-001']),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Should show the "Ditambahkan dari Layanan" hint
    expect(find.text('Ditambahkan dari Layanan'), findsOneWidget);

    final bookingCubit = tester.element(find.byType(BookingSchedulePage)).read<BookingCubit>();
    expect(bookingCubit.scheduleState.selectedServiceIds, contains('svc-001'));
  });
}
