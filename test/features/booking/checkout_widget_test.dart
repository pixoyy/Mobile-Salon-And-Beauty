import 'package:flutter_test/flutter_test.dart';

import '../../test_helper.dart';
import 'package:salon_and_beauty/Controllers/BookingCubit.dart';
import 'package:salon_and_beauty/Models/BookingModel.dart';
import 'package:salon_and_beauty/Models/UserModel.dart';
import 'package:salon_and_beauty/Repositories/BookingRepository.dart';
import 'package:salon_and_beauty/Repositories/ServiceRepository.dart';
import 'package:salon_and_beauty/Support/AuthSession.dart';

Future<BookingCubit> _buildCubit() async {
  final bookingRepo = BookingRepository();
  final serviceRepo = ServiceRepository();
  final bookingCubit = BookingCubit(bookingRepo, serviceRepo)
    ..selectStylist('sty-001')
    ..selectServices(['svc-003', 'svc-005']);

  await bookingCubit.selectDateTime(DateTime(2026, 5, 20), '14:00');
  return bookingCubit;
}

void main() {
  setUpAll(() async {
    await initTestEnv();
  });
  UserModel? previousUser;

  setUp(() {
    previousUser = AuthSession.currentUser;
  });

  tearDown(() {
    AuthSession.currentUser = previousUser;
  });

  test('BookingCubit builds checkout snapshot from pricing module', () async {
    final BookingCubit bookingCubit = await _buildCubit();

    final BookingCheckoutSnapshot snapshot = await bookingCubit.buildCheckoutSnapshot();

    expect(snapshot.payment.subtotal, 625000);
    expect(snapshot.payment.discountAmount, 200000);
    expect(snapshot.payment.totalPrice, 425000);
    expect(snapshot.discountLabel, contains('WEDDING50'));
  });

  test('confirmBooking stores the final pricing snapshot', () async {
    AuthSession.currentUser = const UserModel(
      id: 'cus-step9-checkout',
      name: 'Checkout User',
      email: 'checkout@example.com',
      phone: '081299999999',
      password: 'password123',
    );

    final BookingCubit bookingCubit = await _buildCubit();
    final BookingRepository bookingRepo = BookingRepository();

    await bookingCubit.confirmBooking();

    final List<BookingModel> bookings = await bookingRepo.getAllBookings(
      customerId: AuthSession.activeCustomerId,
    );
    expect(bookings, isNotEmpty);

    final BookingModel latest = bookings.first;
    expect(latest.subtotal, 625000);
    expect(latest.discount, 200000);
    expect(latest.totalPrice, 425000);
  });

}
