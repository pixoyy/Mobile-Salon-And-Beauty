import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../test_helper.dart';
import '../../test_utils.dart';

import 'package:salon_and_beauty/features/booking/presentation/history_page.dart';
import 'package:salon_and_beauty/features/booking/presentation/booking_preview_card.dart';

void main() {
  group('HistoryPage Widget Tests', () {
    setUpAll(() async {
      await initTestEnv();
    });
    testWidgets('displays filter chips for status filtering', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HistoryPage()));
      await waitForFinder(tester, find.text('Riwayat'));

      // Verify all filter chips are present (as ChoiceChip ancestors)
      expect(find.ancestor(of: find.text('Semua'), matching: find.byType(ChoiceChip)), findsWidgets);
      expect(find.ancestor(of: find.text('Upcoming'), matching: find.byType(ChoiceChip)), findsWidgets);
      expect(find.ancestor(of: find.text('On Going'), matching: find.byType(ChoiceChip)), findsWidgets);
      expect(find.ancestor(of: find.text('Completed'), matching: find.byType(ChoiceChip)), findsWidgets);
      expect(find.ancestor(of: find.text('Dibatalkan'), matching: find.byType(ChoiceChip)), findsWidgets);

      // Verify chips are ChoiceChips
      expect(find.byType(ChoiceChip), findsAtLeastNWidgets(5));
    });

    testWidgets('tap filter chip updates selection', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HistoryPage()));
      await waitForFinder(tester, find.text('Riwayat'));

      // Tap the first ChoiceChip instance that contains the 'Pending' label
      final Finder upcomingChip = find.ancestor(of: find.text('Upcoming'), matching: find.byType(ChoiceChip)).at(0);
      await tester.tap(upcomingChip);
      await tester.pumpAndSettle();

      // Verify chip state changed
      final ChoiceChip chip = tester.widget<ChoiceChip>(upcomingChip);
      expect(chip.selected, isTrue);
    });

    testWidgets('app has title Riwayat in appbar', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HistoryPage()));
      await waitForFinder(tester, find.text('Riwayat'));

      final Finder appBar = find.byType(AppBar);
      expect(appBar, findsOneWidget);

      final Finder title = find.text('Riwayat');
      expect(title, findsWidgets);
    });

    testWidgets('displays booking list or empty state', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HistoryPage()));
      await waitForFinder(tester, find.text('Riwayat'));

      // Either a booking preview card exists or empty state message
      final Finder bookingCards = find.byType(BookingPreviewCard);
      final Finder emptyState = find.text('Belum ada riwayat booking');

      // Wait up to ~2 seconds for async load to finish, then assert
      for (int i = 0; i < 4; i++) {
        if (bookingCards.evaluate().isNotEmpty || emptyState.evaluate().isNotEmpty) {
          break;
        }
        await tester.pump(const Duration(milliseconds: 500));
      }

      expect(
        bookingCards.evaluate().isNotEmpty || emptyState.evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('refresh indicator present in page', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HistoryPage()));
      await waitForFinder(tester, find.text('Riwayat'));

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('all filter chips can be selected in sequence', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HistoryPage()));
      await tester.pumpAndSettle();

      final List<String> filterLabels = ['Semua', 'Upcoming', 'On Going', 'Completed', 'Dibatalkan'];

      for (final String label in filterLabels) {
        final Finder chipFinder = find.ancestor(of: find.text(label), matching: find.byType(ChoiceChip)).at(0);
        await tester.tap(chipFinder);
        await tester.pumpAndSettle();

        final ChoiceChip chip = tester.widget<ChoiceChip>(chipFinder);
        expect(chip.selected, isTrue);
      }
    });
  });
}
