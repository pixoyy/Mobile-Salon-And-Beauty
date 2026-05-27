import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_helper.dart';
import 'test_utils.dart';

import 'package:salon_and_beauty/features/booking/bloc/booking_cubit.dart';
import 'package:salon_and_beauty/features/booking/data/booking_repository.dart';
import 'package:salon_and_beauty/features/service/data/service_repository.dart';
import 'package:salon_and_beauty/features/service/presentation/service_list_page.dart';
import 'package:salon_and_beauty/features/stylist/data/stylist_repository.dart';
import 'package:salon_and_beauty/features/booking/presentation/booking_schedule_page.dart';

Future<void> _pumpServiceListPage(WidgetTester tester) async {
  await tester.pumpWidget(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ServiceRepository>(create: (_) => ServiceRepository()),
        RepositoryProvider<BookingRepository>(create: (_) => BookingRepository()),
        RepositoryProvider<StylistRepository>(create: (_) => StylistRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<BookingCubit>(
            create: (context) => BookingCubit(
              context.read<BookingRepository>(),
              context.read<ServiceRepository>(),
            ),
          ),
        ],
        child: const MaterialApp(home: ServiceListPage()),
      ),
    ),
  );
  await waitForAppReady(tester);
}

void main() {
  setUpAll(() async {
    await initTestEnv();
  });
  testWidgets('defaults to Semua category selected', (WidgetTester tester) async {
    await _pumpServiceListPage(tester);

    final semuaChipFinder = find.widgetWithText(FilterChip, 'Semua');
    expect(semuaChipFinder, findsOneWidget);

    final semuaChip = tester.widget<FilterChip>(semuaChipFinder);
    expect(semuaChip.selected, isTrue);
  });

  testWidgets('category filter shows only that category services', (WidgetTester tester) async {
    await _pumpServiceListPage(tester);

    await tester.tap(find.widgetWithText(FilterChip, 'Coloring'));
    await tester.pumpAndSettle();

    expect(find.text('Hair Coloring Full'), findsOneWidget);
    expect(find.text('Balayage Package'), findsOneWidget);
    expect(find.text('Haircut Basic'), findsNothing);
  });

  testWidgets('search stays after switching to Semua and auto applies', (WidgetTester tester) async {
    await _pumpServiceListPage(tester);

    await tester.tap(find.widgetWithText(FilterChip, 'Coloring'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Balayage');
    await tester.pumpAndSettle();

    expect(find.text('Balayage Package'), findsOneWidget);
    expect(find.text('Hair Coloring Full'), findsNothing);

    await tester.tap(find.widgetWithText(FilterChip, 'Semua'));
    await tester.pumpAndSettle();

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.controller?.text, 'Balayage');

    expect(find.text('Balayage Package'), findsOneWidget);
    expect(find.text('Hair Coloring Full'), findsNothing);

    final semuaChip = tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'Semua'));
    expect(semuaChip.selected, isTrue);
  });

  testWidgets('add button builds cart summary and continues to booking', (WidgetTester tester) async {
    await _pumpServiceListPage(tester);

    final Finder addButtons = find.byIcon(Icons.add_rounded);
    expect(addButtons, findsWidgets);

    await tester.tap(addButtons.first);
    await tester.pumpAndSettle();

    expect(find.text('Cart layanan'), findsOneWidget);
    expect(find.text('Lanjut ke Booking'), findsOneWidget);
    expect(find.text('Haircut Basic'), findsWidgets);

    await tester.tap(find.text('Lanjut ke Booking'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Booking Schedule'), findsOneWidget);

    final bookingSchedulePage = find.byType(BookingSchedulePage);
    expect(bookingSchedulePage, findsOneWidget);

    final bookingCubit = tester.element(bookingSchedulePage).read<BookingCubit>();
    expect(bookingCubit.scheduleState.selectedServiceIds, contains('svc-001'));
  });
}
