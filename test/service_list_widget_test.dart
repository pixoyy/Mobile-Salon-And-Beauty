import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:salon_and_beauty/features/service/data/service_repository.dart';
import 'package:salon_and_beauty/features/service/presentation/service_list_page.dart';

Future<void> _pumpServiceListPage(WidgetTester tester) async {
  await tester.pumpWidget(
    RepositoryProvider<ServiceRepository>(
      create: (_) => ServiceRepository(),
      child: const MaterialApp(home: ServiceListPage()),
    ),
  );
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

void main() {
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
}
