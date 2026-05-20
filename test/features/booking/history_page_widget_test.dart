import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:salon_and_beauty/features/booking/presentation/history_page.dart';

void main() {
  group('HistoryPage Widget Tests', () {
    testWidgets('displays filter chips for status filtering', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HistoryPage()));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify all filter chips are present
      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Dibatalkan'), findsOneWidget);

      // Verify chips are ChoiceChips
      expect(find.byType(ChoiceChip), findsAtLeastNWidgets(5));
    });

    testWidgets('tap filter chip updates selection', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HistoryPage()));
      await tester.pump(const Duration(milliseconds: 500));

      // Tap "Pending" chip
      await tester.tap(find.text('Pending'));
      await tester.pump(const Duration(milliseconds: 200));

      // Verify chip state changed (no assertion on UI filtering since data depends on repo)
      final ChoiceChip chip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('Pending'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(chip.selected, isTrue);
    });

    testWidgets('app has title Riwayat in appbar', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HistoryPage()));
      await tester.pump(const Duration(milliseconds: 300));

      final Finder appBar = find.byType(AppBar);
      expect(appBar, findsOneWidget);

      final Finder title = find.text('Riwayat');
      expect(title, findsWidgets);
    });

    testWidgets('displays booking list or empty state', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HistoryPage()));
      await tester.pump(const Duration(seconds: 1));

      // Either a booking list item exists or empty state message
      // final Finder bookingCards = find.byType(Material);
      final Finder emptyState = find.text('Belum ada riwayat booking');

      expect(
        find.byType(ListTile).evaluate().isNotEmpty ||
            emptyState.evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('refresh indicator present in page', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HistoryPage()));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('all filter chips can be selected in sequence', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HistoryPage()));
      await tester.pump(const Duration(milliseconds: 500));

      final List<String> filterLabels = ['Semua', 'Pending', 'Confirmed', 'Completed', 'Dibatalkan'];

      for (final String label in filterLabels) {
        await tester.tap(find.text(label));
        await tester.pump(const Duration(milliseconds: 200));

        final ChoiceChip chip = tester.widget<ChoiceChip>(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(ChoiceChip),
          ),
        );
        expect(chip.selected, isTrue);
      }
    });
  });
}
