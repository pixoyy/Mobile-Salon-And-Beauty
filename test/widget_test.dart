// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:salon_and_beauty/app.dart';
import 'package:salon_and_beauty/features/booking/bloc/booking_cubit.dart';
import 'package:salon_and_beauty/features/booking/data/booking_repository.dart';
import 'package:salon_and_beauty/features/service/data/service_repository.dart';
import 'package:salon_and_beauty/features/shell/presentation/app_shell.dart';
import 'package:salon_and_beauty/features/stylist/data/stylist_repository.dart';

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

  testWidgets('app shell navigation tabs work', (WidgetTester tester) async {
    final ServiceRepository serviceRepository = ServiceRepository();

    await tester.pumpWidget(
      RepositoryProvider<StylistRepository>(
        create: (_) => StylistRepository(),
        child: RepositoryProvider<ServiceRepository>(
          create: (_) => serviceRepository,
          child: RepositoryProvider<BookingRepository>(
            create: (_) => BookingRepository(),
            child: BlocProvider<BookingCubit>(
              create: (context) => BookingCubit(
                context.read<BookingRepository>(),
                serviceRepository,
              ),
              child: const MaterialApp(home: AppShell()),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Beranda'), findsWidgets);

    await tester.tap(find.text('Stylist').last);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Pilih Stylist'), findsOneWidget);

    await tester.tap(find.text('Layanan').last);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Layanan Salon'), findsOneWidget);
    expect(find.text('Cari layanan...'), findsOneWidget);

    await tester.tap(find.text('Booking').last);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Booking Schedule'), findsOneWidget);
    expect(find.text('1. Pilih Stylist'), findsOneWidget);

    await tester.tap(find.text('Akun').last);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Akun'), findsWidgets);
    expect(find.text('Phase berikutnya akan memuat profil dan pengaturan akun.'), findsOneWidget);
  });
}
