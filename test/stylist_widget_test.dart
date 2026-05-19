import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:salon_and_beauty/features/stylist/data/stylist_repository.dart';
import 'package:salon_and_beauty/features/stylist/presentation/stylist_list_page.dart';
import 'package:salon_and_beauty/features/stylist/presentation/stylist_detail_page.dart';

void main() {
  testWidgets('Stylist list shows items and navigates to detail', (tester) async {
    await tester.pumpWidget(
      RepositoryProvider<StylistRepository>(
        create: (_) => StylistRepository(),
        child: const MaterialApp(home: StylistListPage()),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Page title
    expect(find.text('Pilih Stylist'), findsOneWidget);

    // At least one known stylist from dummy data appears
    expect(find.text('Nadia Putri'), findsOneWidget);

    // Tap lihat detail of first stylist
    final detailButton = find.text('Lihat Detail').first;
    expect(detailButton, findsWidgets);
    await tester.tap(detailButton);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Detail page shows
    expect(find.text('Detail Stylist'), findsOneWidget);
    expect(find.text('Tentang Stylist'), findsOneWidget);
  });

  testWidgets('Search filters stylist list', (tester) async {
    await tester.pumpWidget(
      RepositoryProvider<StylistRepository>(
        create: (_) => StylistRepository(),
        child: const MaterialApp(home: StylistListPage()),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Enter a search query
    await tester.enterText(find.byType(TextField).first, 'Nadia');
    await tester.pumpAndSettle();

    expect(find.text('Nadia Putri'), findsOneWidget);
    expect(find.text('Rizky Ananda'), findsNothing);
  });

  testWidgets('Stylist detail page shows info for id', (tester) async {
    await tester.pumpWidget(
      RepositoryProvider<StylistRepository>(
        create: (_) => StylistRepository(),
        child: const MaterialApp(home: StylistDetailPage(stylistId: 'sty-001')),
      ),
    );

    await tester.pumpAndSettle();

    // Stylist name and reviews present
    expect(find.text('Nadia Putri'), findsOneWidget);
    expect(find.text('Ulasan Terbaru'), findsOneWidget);
  });
}
