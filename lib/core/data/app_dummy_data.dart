import '../../features/booking/data/dummy_bookings.dart';
import '../../features/user/data/dummy_user.dart';
import '../../features/service/data/dummy_services.dart';
import '../../features/stylist/data/dummy_stylists.dart';

class AppDummyData {
  const AppDummyData._();

  static final stylists = DummyStylists.data;
  static const services = DummyServices.data;
  static const customers = DummyUser.data;
  static final upcomingBookings = DummyBookings.upcoming;
  static final bookingHistory = DummyBookings.history;
}
