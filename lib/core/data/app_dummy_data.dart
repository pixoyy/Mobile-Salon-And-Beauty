import '../../features/booking/data/dummy_bookings.dart';
import '../../features/customer/data/dummy_customers.dart';
import '../../features/service/data/dummy_services.dart';
import '../../features/stylist/data/dummy_stylists.dart';

class AppDummyData {
  const AppDummyData._();

  static final stylists = DummyStylists.data;
  static const services = DummyServices.data;
  static const customers = DummyCustomers.data;
  static final upcomingBookings = DummyBookings.upcoming;
  static final bookingHistory = DummyBookings.history;
}
