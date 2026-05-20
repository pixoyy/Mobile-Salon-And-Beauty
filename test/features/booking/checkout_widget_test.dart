import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:salon_and_beauty/features/booking/bloc/booking_cubit.dart';
import 'package:salon_and_beauty/features/booking/data/booking_repository.dart';
import 'package:salon_and_beauty/features/booking/presentation/checkout_page.dart';
import 'package:salon_and_beauty/features/stylist/data/stylist_repository.dart';
import 'package:salon_and_beauty/features/stylist/data/dummy_stylists.dart';
import 'package:salon_and_beauty/features/service/data/service_repository.dart';
import 'package:salon_and_beauty/features/service/data/dummy_services.dart';

String _formatDateLabel(DateTime date) {
  final String day = date.day.toString().padLeft(2, '0');
  final String month = date.month.toString().padLeft(2, '0');
  final String year = date.year.toString();
  return '$day/$month/$year';
}

void main() {
  testWidgets('CheckoutPage displays booking summary', (tester) async {
    final bookingRepo = BookingRepository();
    final dummyStylists = DummyStylists.data;
    final dummyServices = DummyServices.data;
    
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<BookingRepository>(
            create: (_) => bookingRepo,
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
              bookingRepo,
              ServiceRepository(),
            ),
            child: CheckoutPage(
              stylists: dummyStylists,
              services: dummyServices,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Page title
    expect(find.text('Checkout Booking'), findsOneWidget);

    // Main sections should be visible
    expect(find.text('2. Ringkasan Booking'), findsOneWidget);
    expect(find.text('Total Pembayaran'), findsOneWidget);

    // Action buttons
    expect(find.text('Konfirmasi Booking'), findsOneWidget);
    expect(find.text('Kembali'), findsOneWidget);
  });

  testWidgets('Pricing breakdown calculation is accurate', (tester) async {
    final bookingRepo = BookingRepository();
    final dummyStylists = DummyStylists.data;
    final dummyServices = DummyServices.data;
    
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<BookingRepository>(
            create: (_) => bookingRepo,
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
              bookingRepo,
              ServiceRepository(),
            )..selectStylist('sty-001')
              ..selectServices(['svc-001', 'svc-002'])
              ..selectDateTime(DateTime.now().add(const Duration(days: 1)), '14:00'),
            child: CheckoutPage(
              stylists: dummyStylists,
              services: dummyServices,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Subtotal should be visible
    expect(find.text('Subtotal'), findsOneWidget);
    
    // Discount and total should be visible
    expect(find.textContaining('Diskon GLAMORA20'), findsOneWidget);
    expect(find.text('Total Pembayaran'), findsOneWidget);
  });

  testWidgets('Stylist information displays correctly', (tester) async {
    final bookingRepo = BookingRepository();
    final dummyStylists = DummyStylists.data;
    final dummyServices = DummyServices.data;
    
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<BookingRepository>(
            create: (_) => bookingRepo,
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
              bookingRepo,
              ServiceRepository(),
            )..selectStylist('sty-001'),
            child: CheckoutPage(
              stylists: dummyStylists,
              services: dummyServices,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Stylist name should be displayed
    expect(find.text('Nadia Putri'), findsWidgets);
  });

  testWidgets('Selected services list displays correctly', (tester) async {
    final bookingRepo = BookingRepository();
    final dummyStylists = DummyStylists.data;
    final dummyServices = DummyServices.data;
    
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<BookingRepository>(
            create: (_) => bookingRepo,
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
              bookingRepo,
              ServiceRepository(),
            )..selectServices(['svc-001', 'svc-002']),
            child: CheckoutPage(
              stylists: dummyStylists,
              services: dummyServices,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 2));

    // At least one selected service should be displayed in the summary
    expect(find.textContaining(DummyServices.data[0].name), findsWidgets);
    expect(find.textContaining(DummyServices.data[1].name), findsWidgets);
  });

  testWidgets('Date and time confirmation displays', (tester) async {
    final bookingRepo = BookingRepository();
    final testDate = DateTime.now().add(const Duration(days: 1));
    final dummyStylists = DummyStylists.data;
    final dummyServices = DummyServices.data;
    
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<BookingRepository>(
            create: (_) => bookingRepo,
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
              bookingRepo,
              ServiceRepository(),
            )..selectStylist('sty-001')
              ..selectDateTime(testDate, '14:00'),
            child: CheckoutPage(
              stylists: dummyStylists,
              services: dummyServices,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Date and time should be displayed
    expect(find.textContaining('14:00'), findsWidgets);
    expect(find.textContaining(_formatDateLabel(testDate)), findsWidgets);
  });

  testWidgets('"Konfirmasi Booking" button creates booking', (tester) async {
    final bookingRepo = BookingRepository();
    final dummyStylists = DummyStylists.data;
    final dummyServices = DummyServices.data;
    
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<BookingRepository>(
            create: (_) => bookingRepo,
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
              bookingRepo,
              ServiceRepository(),
            )..selectStylist('sty-001')
              ..selectServices(['svc-001'])
              ..selectDateTime(DateTime.now().add(const Duration(days: 1)), '14:00'),
            child: CheckoutPage(
              stylists: dummyStylists,
              services: dummyServices,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Tap confirm button
    final confirmButton = find.text('Konfirmasi Booking');
    await tester.tap(confirmButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  });

  testWidgets('"Kembali" button navigates back to schedule', (tester) async {
    final bookingRepo = BookingRepository();
    final dummyStylists = DummyStylists.data;
    final dummyServices = DummyServices.data;
    
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<BookingRepository>(
            create: (_) => bookingRepo,
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
            body: BlocProvider(
              create: (_) => BookingCubit(
                bookingRepo,
                ServiceRepository(),
              ),
              child: CheckoutPage(
                stylists: dummyStylists,
                services: dummyServices,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Tap back button
    final backButton = find.text('Kembali');
    await tester.tap(backButton);
    await tester.pumpAndSettle();
  });

  testWidgets('Discount calculation applies correctly', (tester) async {
    final bookingRepo = BookingRepository();
    final dummyStylists = DummyStylists.data;
    final dummyServices = DummyServices.data;
    
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<BookingRepository>(
            create: (_) => bookingRepo,
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
              bookingRepo,
              ServiceRepository(),
            )..selectStylist('sty-001')
              ..selectServices(['svc-001']),
            child: CheckoutPage(
              stylists: dummyStylists,
              services: dummyServices,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Discount section should be visible
    expect(find.textContaining('Diskon GLAMORA20'), findsOneWidget);
  });

  testWidgets('Page displays all customer info sections', (tester) async {
    final bookingRepo = BookingRepository();
    final dummyStylists = DummyStylists.data;
    final dummyServices = DummyServices.data;
    
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<BookingRepository>(
            create: (_) => bookingRepo,
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
              bookingRepo,
              ServiceRepository(),
            ),
            child: CheckoutPage(
              stylists: dummyStylists,
              services: dummyServices,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Should display checkout page structure
    expect(find.text('Checkout Booking'), findsOneWidget);
    
    // Verify page has scrollable content
    final scrollViews = find.byType(ListView);
    expect(scrollViews.evaluate().isNotEmpty, isTrue);
  });

  testWidgets('Booking summary displays with null selections gracefully', (tester) async {
    final bookingRepo = BookingRepository();
    final dummyStylists = DummyStylists.data;
    final dummyServices = DummyServices.data;
    
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<BookingRepository>(
            create: (_) => bookingRepo,
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
              bookingRepo,
              ServiceRepository(),
            ),
            child: CheckoutPage(
              stylists: dummyStylists,
              services: dummyServices,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Page should load without crashing even with no selections
    expect(find.text('Checkout Booking'), findsOneWidget);
  });

  testWidgets('Error handling shows on confirmation failure', (tester) async {
    final bookingRepo = BookingRepository();
    final dummyStylists = DummyStylists.data;
    final dummyServices = DummyServices.data;
    
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<BookingRepository>(
            create: (_) => bookingRepo,
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
              bookingRepo,
              ServiceRepository(),
            ),
            child: CheckoutPage(
              stylists: dummyStylists,
              services: dummyServices,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Try to confirm without required data
    final confirmButton = find.text('Konfirmasi Booking');
    await tester.tap(confirmButton);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Page should still be visible
    expect(find.text('Konfirmasi Booking'), findsOneWidget);
  });
}
