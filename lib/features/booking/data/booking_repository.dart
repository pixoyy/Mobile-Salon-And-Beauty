import 'booking_model.dart';
import 'dummy_bookings.dart';
import '../../stylist/data/dummy_stylists.dart';

class BookingRepository {
  static final BookingRepository _instance = BookingRepository._internal();

  factory BookingRepository() {
    return _instance;
  }

  BookingRepository._internal() {
    _initializeDummyBookings();
  }

  static const String _activeCustomerId = 'demo-001';
  static const int _startHour = 9;
  static const int _endHour = 17;

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

    final bool isAvailable = await checkAvailability(
      booking.stylistId,
      booking.bookingDate,
      booking.bookingTime,
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

    final bool isAvailable = await checkAvailability(
      nextBooking.stylistId,
      nextBooking.bookingDate,
      nextBooking.bookingTime,
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
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final List<String> allSlots = _buildDefaultSlots();
    final List<String> bookedSlots = _bookings
        .where(
          (booking) =>
              booking.stylistId == stylistId &&
              _isSameDate(booking.bookingDate, date) &&
              booking.status != BookingStatus.cancelled,
        )
        .map((booking) => _normalizeTime(booking.bookingTime))
        .whereType<String>()
        .toSet()
        .toList(growable: false);

    return allSlots
        .where((slot) => !bookedSlots.contains(slot))
        .toList(growable: false);
  }

  Future<bool> checkAvailability(
    String stylistId,
    DateTime date,
    String time, {
    String? excludedBookingId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 140));

    final String? normalizedTime = _normalizeTime(time);
    if (normalizedTime == null ||
        !_buildDefaultSlots().contains(normalizedTime)) {
      return false;
    }

    for (final booking in _bookings) {
      if (excludedBookingId != null && booking.id == excludedBookingId) {
        continue;
      }

      final String? existingTime = _normalizeTime(booking.bookingTime);
      if (existingTime == null) {
        continue;
      }

      final bool hasConflict =
          booking.stylistId == stylistId &&
          _isSameDate(booking.bookingDate, date) &&
          existingTime == normalizedTime &&
          booking.status != BookingStatus.cancelled;

      if (hasConflict) {
        return false;
      }
    }

    return true;
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

  List<String> _buildDefaultSlots() {
    final List<String> slots = <String>[];

    for (int hour = _startHour; hour <= _endHour; hour++) {
      slots.add('${hour.toString().padLeft(2, '0')}:00');
    }

    return slots;
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDate(DateTime date) {
    final String year = date.year.toString().padLeft(4, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String? _normalizeTime(String rawTime) {
    final List<String> parts = rawTime.trim().split(':');
    if (parts.length != 2) {
      return null;
    }

    final int? hour = int.tryParse(parts[0]);
    final int? minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) {
      return null;
    }

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return null;
    }

    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
