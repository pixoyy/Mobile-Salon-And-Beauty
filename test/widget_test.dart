// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:salon_and_beauty/app.dart';

void main() {
  testWidgets('shows Glamora login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const GlamoraApp());

    expect(find.text('Glamora'), findsWidgets);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Selamat datang kembali!'), findsOneWidget);
  });

  testWidgets('opens registration page from login link', (WidgetTester tester) async {
    await tester.pumpWidget(const GlamoraApp());

    await tester.scrollUntilVisible(
      find.text('Belum punya akun? Daftar di sini'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Belum punya akun? Daftar di sini'));
    await tester.pumpAndSettle();

    expect(find.text('Daftar Akun'), findsWidgets);
    expect(find.text('Buat akun baru'), findsOneWidget);
  });

  testWidgets('login flow opens app shell and navigation tabs work', (WidgetTester tester) async {
    await tester.pumpWidget(const GlamoraApp());

    await tester.enterText(find.byType(TextFormField).at(0), 'siska.amanda@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.scrollUntilVisible(
      find.widgetWithText(ElevatedButton, 'Login'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Beranda'), findsWidgets);

    await tester.tap(find.text('Stylist').last);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Pilih Stylist'), findsOneWidget);

    await tester.tap(find.text('Layanan').last);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Layanan'), findsWidgets);
    expect(find.text('Phase berikutnya akan memuat daftar layanan salon.'), findsOneWidget);

    await tester.tap(find.text('Booking').last);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Booking'), findsWidgets);
    expect(find.text('Phase berikutnya akan memuat booking schedule dan checkout.'), findsOneWidget);

    await tester.tap(find.text('Akun').last);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Akun'), findsWidgets);
    expect(find.text('Phase berikutnya akan memuat profil dan pengaturan akun.'), findsOneWidget);
  });
}
