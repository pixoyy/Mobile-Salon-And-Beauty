import 'booking_model.dart';
import 'dummy_bookings.dart';
import '../../service/data/dummy_services.dart';
import '../../service/data/service_repository.dart';
import '../../stylist/data/dummy_stylists.dart';
import '../../../core/session/auth_session.dart';

class BookingRepository {
  static final BookingRepository _instance = BookingRepository._internal();

  factory BookingRepository() {
    return _instance;
  }

  BookingRepository._internal() {
    _initializeDummyBookings();
  }

  static String get _activeCustomerId => AuthSession.activeCustomerId;
  static const int _startHour = 8;
  static const int _endHour = 20;
  static const int _slotDurationMinutes = 60;
  static const int _turnaroundMinutes = 0;

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

    final int bookingDurationMinutes = await _resolveBookingDurationMinutes(booking.serviceIds);

    final bool isAvailable = await checkAvailability(
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

    final bool isAvailable = await checkAvailability(
      nextBooking.stylistId,
      nextBooking.bookingDate,
      nextBooking.bookingTime,
      durationMinutes: await _resolveBookingDurationMinutes(nextBooking.serviceIds),
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
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final List<String> allSlots = _buildDefaultSlots();
    final int duration = durationMinutes > 0 ? durationMinutes : _slotDurationMinutes;

    final List<String> result = allSlots.where((slot) {
      return _isSlotAvailable(
        stylistId: stylistId,
        date: date,
        time: slot,
        durationMinutes: duration,
      );
    }).toList(growable: false);
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
    await Future<void>.delayed(const Duration(milliseconds: 140));

    final String? normalizedTime = _normalizeTime(time);
    if (normalizedTime == null ||
        !_buildDefaultSlots().contains(normalizedTime)) {
      return false;
    }

    final int resolvedDuration = durationMinutes > 0 ? durationMinutes : _slotDurationMinutes;
    if (_availabilityFailureReason(
          stylistId: stylistId,
          date: date,
          time: normalizedTime,
          durationMinutes: resolvedDuration,
          excludedBookingId: excludedBookingId,
        ) !=
        null) {
      return false;
    }

    return _isSlotAvailable(
      stylistId: stylistId,
      date: date,
      time: normalizedTime,
      durationMinutes: resolvedDuration,
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
    await Future<void>.delayed(const Duration(milliseconds: 80));

    final String? normalizedTime = _normalizeTime(time);
    if (normalizedTime == null) {
      return 'Format jam booking belum valid. Gunakan format HH:mm.';
    }

    final int resolvedDuration = durationMinutes > 0 ? durationMinutes : _slotDurationMinutes;
    return _availabilityFailureReason(
      stylistId: stylistId,
      date: date,
      time: normalizedTime,
      durationMinutes: resolvedDuration,
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

  Future<int> _resolveBookingDurationMinutes(List<String> serviceIds) async {
    if (serviceIds.isEmpty) {
      return 0;
    }

    final ServiceRepository serviceRepository = ServiceRepository();
    final List<Future<int>> durationRequests = serviceIds.map((serviceId) async {
      final service = await serviceRepository.getServiceById(serviceId);
      return service?.durationMinutes ?? 0;
    }).toList(growable: false);

    final List<int> durations = await Future.wait(durationRequests);
    return durations.fold<int>(0, (sum, value) => sum + value);
  }

  bool _isSlotAvailable({
    required String stylistId,
    required DateTime date,
    required String time,
    required int durationMinutes,
    String? excludedBookingId,
  }) {
    print('DBG: _isSlotAvailable check for $stylistId $time duration=$durationMinutes');
    final int candidateStart = _timeToMinutes(time);
    final int candidateEnd = candidateStart + durationMinutes + _turnaroundMinutes;

    for (final booking in _bookings) {
      print('DBG: checking existing booking ${booking.id} stylist=${booking.stylistId} date=${booking.bookingDate} time=${booking.bookingTime}');
      if (excludedBookingId != null && booking.id == excludedBookingId) {
        continue;
      }

      if (booking.stylistId != stylistId ||
          !_isSameDate(booking.bookingDate, date) ||
          booking.status == BookingStatus.cancelled) {
        continue;
      }

      final String? existingTime = _normalizeTime(booking.bookingTime);
      if (existingTime == null) {
        continue;
      }

      final int existingDuration = _resolveBookingDurationMinutesSync(booking.serviceIds);
      final int existingStart = _timeToMinutes(existingTime);
      final int existingEnd = existingStart + existingDuration + _turnaroundMinutes;

      final bool hasOverlap = candidateStart < existingEnd && candidateEnd > existingStart;
      if (hasOverlap) {
        return false;
      }
    }

    return true;
  }

  // bool _isWithinOperationalHours(String time, int durationMinutes) {
  //   final int start = _timeToMinutes(time);
  //   final int end = start + durationMinutes + _turnaroundMinutes;
  //   final int operationalStart = _startHour * 60;
  //   final int operationalEnd = _endHour * 60;

  //   if (start == operationalEnd && durationMinutes <= _slotDurationMinutes) {
  //     return true;
  //   }

  //   return start >= operationalStart && end <= operationalEnd;
  // }

  String? _availabilityFailureReason({
    required String stylistId,
    required DateTime date,
    required String time,
    required int durationMinutes,
    String? excludedBookingId,
  }) {
    final int candidateStart = _timeToMinutes(time);
    final int candidateEnd = candidateStart + durationMinutes + _turnaroundMinutes;
    final int operationalStart = _startHour * 60;
    final int operationalEnd = _endHour * 60;

    if (candidateStart == operationalEnd && durationMinutes <= _slotDurationMinutes) {
      return null;
    }

    if (candidateStart == operationalEnd && durationMinutes > _slotDurationMinutes) {
      return 'Jam 20:00 hanya bisa dipakai untuk layanan berdurasi maksimal 60 menit. Silakan pilih layanan yang lebih singkat atau jam yang lebih awal.';
    }

    if (candidateStart < operationalStart || candidateEnd > operationalEnd) {
      final String startLabel = _startHour.toString().padLeft(2, '0');
      final String endLabel = _endHour.toString().padLeft(2, '0');
      final int remainingMinutes = operationalEnd - candidateStart;

      if (remainingMinutes > 0 && remainingMinutes < durationMinutes) {
        return 'Waktu yang dipilih belum cukup untuk durasi layanan ini. Silakan pilih jam yang lebih awal atau pilih layanan yang lebih singkat.';
      }

      return 'Jam booking harus berada di antara $startLabel:00 sampai $endLabel:00 dan tetap cukup untuk menyelesaikan layanan.';
    }

    for (final booking in _bookings) {
      if (excludedBookingId != null && booking.id == excludedBookingId) {
        continue;
      }

      if (booking.stylistId != stylistId ||
          !_isSameDate(booking.bookingDate, date) ||
          booking.status == BookingStatus.cancelled) {
        continue;
      }

      final String? existingTime = _normalizeTime(booking.bookingTime);
      if (existingTime == null) {
        continue;
      }

      final int existingDuration = _resolveBookingDurationMinutesSync(booking.serviceIds);
      final int existingStart = _timeToMinutes(existingTime);
      final int existingEnd = existingStart + existingDuration + _turnaroundMinutes;

      final bool hasOverlap = candidateStart < existingEnd && candidateEnd > existingStart;
      if (hasOverlap) {
        return 'Slot ini sudah terisi oleh booking lain. Silakan pilih jam lain yang masih kosong.';
      }
    }

    return null;
  }

  int _resolveBookingDurationMinutesSync(List<String> serviceIds) {
    if (serviceIds.isEmpty) {
      return 0;
    }

    final Map<String, int> durationById = {
      for (final service in DummyServices.data) service.id: service.durationMinutes,
    };

    return serviceIds.fold<int>(0, (sum, serviceId) {
      return sum + (durationById[serviceId] ?? 0);
    });
  }

  int _timeToMinutes(String time) {
    final List<String> parts = time.split(':');
    final int hour = int.tryParse(parts.isNotEmpty ? parts[0] : '0') ?? 0;
    final int minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    return hour * 60 + minute;
  }
}
