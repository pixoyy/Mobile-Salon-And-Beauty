import 'booking_model.dart';
import 'dummy_bookings.dart';
import '../../service/data/service_repository.dart';
import '../../stylist/data/dummy_stylists.dart';
import '../../../core/session/auth_session.dart';
import '../domain/booking_availability_service.dart';

class BookingRepository {
  static final BookingRepository _instance = BookingRepository._internal();

  factory BookingRepository() {
    return _instance;
  }

  BookingRepository._internal() {
    _initializeDummyBookings();
  }

  static String get _activeCustomerId => AuthSession.activeCustomerId;
  // availability config moved to BookingAvailabilityService

  final List<BookingModel> _bookings = <BookingModel>[];

  void _initializeDummyBookings() {
    if (_bookings.isNotEmpty) {
      return;
    }

    _bookings
      ..addAll(DummyBookings.upcoming)
      ..addAll(DummyBookings.history);
  }

  Future<List<BookingModel>> getAllBookings({String? customerId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));

    final String targetCustomerId = customerId ?? _activeCustomerId;

    final List<BookingModel> filtered = _bookings
        .where((booking) => booking.customerId == targetCustomerId)
        .toList(growable: false);

    filtered.sort((a, b) => b.bookingDateTime.compareTo(a.bookingDateTime));

    return filtered;
  }

  Future<BookingModel?> getBookingById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 160));

    for (final booking in _bookings) {
      if (booking.id == id) {
        return booking;
      }
    }

    return null;
  }

  Future<BookingModel> createBooking(BookingModel booking) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));

    final int bookingDurationMinutes = await BookingAvailabilityService.resolveBookingDurationMinutes(
      booking.serviceIds,
      ServiceRepository(),
    );

    final bool isAvailable = await BookingAvailabilityService.checkAvailability(
      _bookings,
      booking.stylistId,
      booking.bookingDate,
      booking.bookingTime,
      durationMinutes: bookingDurationMinutes,
    );

    if (!isAvailable) {
      throw StateError('Slot tidak tersedia untuk stylist terpilih.');
    }

    final String bookingId = booking.id.trim().isEmpty
        ? _generateBookingId()
        : booking.id;
    final BookingModel savedBooking = booking.copyWith(id: bookingId);

    _bookings.add(savedBooking);
    return savedBooking;
  }

  Future<BookingModel?> updateBooking(String id, BookingModel booking) async {
    await Future<void>.delayed(const Duration(milliseconds: 240));

    final int index = _bookings.indexWhere((item) => item.id == id);
    if (index < 0) {
      return null;
    }

    final BookingModel nextBooking = booking.copyWith(id: id);

    final bool isAvailable = await BookingAvailabilityService.checkAvailability(
      _bookings,
      nextBooking.stylistId,
      nextBooking.bookingDate,
      nextBooking.bookingTime,
      durationMinutes: await BookingAvailabilityService.resolveBookingDurationMinutes(
        nextBooking.serviceIds,
        ServiceRepository(),
      ),
      excludedBookingId: id,
    );

    if (!isAvailable) {
      throw StateError('Slot tidak tersedia untuk stylist terpilih.');
    }

    _bookings[index] = nextBooking;
    return nextBooking;
  }

  Future<bool> deleteBooking(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 160));

    final int index = _bookings.indexWhere((booking) => booking.id == id);
    if (index < 0) {
      return false;
    }

    _bookings.removeAt(index);
    return true;
  }

  Future<List<String>> getAvailableSlotsForStylist(
    String stylistId,
    DateTime date,
    {int durationMinutes = 0}
  ) async {
    print('DBG: BookingRepository.getAvailableSlotsForStylist start: $stylistId ${date.toIso8601String()} duration=$durationMinutes');
    final List<String> result = await BookingAvailabilityService.getAvailableSlotsForStylist(
      _bookings,
      stylistId,
      date,
      durationMinutes: durationMinutes,
    );
    print('DBG: BookingRepository.getAvailableSlotsForStylist result: ${result.length} slots');
    return result;
  }

  Future<bool> checkAvailability(
    String stylistId,
    DateTime date,
    String time, {
    int durationMinutes = 0,
    String? excludedBookingId,
  }) async {
    return BookingAvailabilityService.checkAvailability(
      _bookings,
      stylistId,
      date,
      time,
      durationMinutes: durationMinutes,
      excludedBookingId: excludedBookingId,
    );
  }

  Future<String?> getAvailabilityMessage(
    String stylistId,
    DateTime date,
    String time, {
    int durationMinutes = 0,
    String? excludedBookingId,
  }) async {
    return BookingAvailabilityService.getAvailabilityMessage(
      _bookings,
      stylistId,
      date,
      time,
      durationMinutes: durationMinutes,
      excludedBookingId: excludedBookingId,
    );
  }

  Future<List<BookingModel>> searchBookings(
    String query, {
    String? customerId,
  }) async {
    final String normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return getAllBookings(customerId: customerId);
    }

    await Future<void>.delayed(const Duration(milliseconds: 200));

    final String targetCustomerId = customerId ?? _activeCustomerId;

    final Map<String, String> stylistNamesById = {
      for (final stylist in DummyStylists.data)
        stylist.id: stylist.name.toLowerCase(),
    };

    final List<BookingModel> results = _bookings
        .where((booking) {
          if (booking.customerId != targetCustomerId) {
            return false;
          }

          final String stylistName = stylistNamesById[booking.stylistId] ?? '';
          final String dateText = _formatDate(booking.bookingDate);

          return stylistName.contains(normalizedQuery) ||
              dateText.contains(normalizedQuery);
        })
        .toList(growable: false);

    results.sort((a, b) => b.bookingDateTime.compareTo(a.bookingDateTime));

    return results;
  }

  String _generateBookingId() {
    final int sequence = _bookings.length + 1;
    return 'bk-${sequence.toString().padLeft(3, '0')}';
  }

  String _formatDate(DateTime date) {
    final String year = date.year.toString().padLeft(4, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

}
