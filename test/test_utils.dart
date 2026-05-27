import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps the widget tree until [finder] is present or timeout elapses.
Future<void> waitForFinder(WidgetTester tester, Finder finder,
    {Duration timeout = const Duration(seconds: 5)}) async {
  final int maxIter = (timeout.inMilliseconds / 100).ceil();
  for (int i = 0; i < maxIter; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
}

/// Wait for the app to load master data by waiting for an ElevatedButton (checkout/navigation)
Future<void> waitForAppReady(WidgetTester tester) async {
  await waitForFinder(tester, find.byType(ElevatedButton));
  await tester.pumpAndSettle();
}
