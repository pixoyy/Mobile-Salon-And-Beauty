import 'package:flutter_test/flutter_test.dart';

import '../../test_helper.dart';
import 'package:salon_and_beauty/core/session/auth_session.dart';
import 'package:salon_and_beauty/features/booking/bloc/booking_cubit.dart';
import 'package:salon_and_beauty/features/booking/data/booking_model.dart';
import 'package:salon_and_beauty/features/booking/data/booking_repository.dart';
import 'package:salon_and_beauty/features/service/data/service_repository.dart';
import 'package:salon_and_beauty/features/user/data/user_model.dart';

Future<BookingCubit> _buildPreparedCubit() async {
  final BookingRepository bookingRepository = BookingRepository();
  final ServiceRepository serviceRepository = ServiceRepository();
  final BookingCubit bookingCubit = BookingCubit(bookingRepository, serviceRepository);

  await bookingCubit.selectStylist('sty-001');
  bookingCubit.selectServices(<String>['svc-001']);
  bookingCubit.selectDate(DateTime(2026, 5, 20));
  await bookingCubit.loadAvailableSlots('sty-001', DateTime(2026, 5, 20));
  await bookingCubit.selectDateTime(
    DateTime(2026, 5, 20),
    bookingCubit.scheduleState.availableSlots.first,
  );

  return bookingCubit;
}

void main() {
  setUpAll(() async {
    await initTestEnv();
  });
  UserModel? previousUser;

  setUp(() {
    previousUser = AuthSession.currentUser;
    AuthSession.currentUser = const UserModel(
      id: 'cus-step11-flow',
      name: 'Step Eleven User',
      email: 'step11@example.com',
      phone: '081200000011',
      password: 'password123',
    );
  });

  tearDown(() {
    AuthSession.currentUser = previousUser;
  });

  test('schedule state flows into checkout snapshot and confirm persistence', () async {
    final BookingCubit bookingCubit = await _buildPreparedCubit();
    final BookingRepository bookingRepository = BookingRepository();

    final BookingCheckoutSnapshot snapshot = await bookingCubit.buildCheckoutSnapshot();

    expect(snapshot.scheduleState.canProceedToCheckout, isTrue);
    expect(snapshot.selectedServices, isNotEmpty);
    expect(snapshot.payment.subtotal, greaterThan(0));

    await bookingCubit.confirmBooking();

    final List<BookingModel> bookings = await bookingRepository.getAllBookings(
      customerId: AuthSession.activeCustomerId,
    );

    expect(bookings, isNotEmpty);
    expect(bookings.first.totalPrice, snapshot.payment.totalPrice);
    expect(bookings.first.serviceIds, contains('svc-001'));
  });
}