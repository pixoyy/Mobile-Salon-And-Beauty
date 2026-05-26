import '../../service/data/dummy_services.dart';
import '../../service/data/service_model.dart';
import '../../service/data/service_repository.dart';
import '../data/booking_model.dart';

class BookingAvailabilityService {
  BookingAvailabilityService._();

  static const int startHour = 8;
  static const int endHour = 20;
  static const int slotDurationMinutes = 60;
  static const int turnaroundMinutes = 0;

  static Future<int> resolveBookingDurationMinutes(
    List<String> serviceIds,
    ServiceRepository serviceRepository,
  ) async {
    if (serviceIds.isEmpty) {
      return 0;
    }

    final List<Future<ServiceModel?>> requests = serviceIds
        .map((serviceId) => serviceRepository.getServiceById(serviceId))
        .toList(growable: false);

    final List<ServiceModel?> services = await Future.wait(requests);
    return services.whereType<ServiceModel>().fold<int>(0, (sum, service) {
      return sum + service.durationMinutes;
    });
  }

  static Future<List<String>> getAvailableSlotsForStylist(
    List<BookingModel> bookings,
    String stylistId,
    DateTime date, {
    int durationMinutes = 0,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final List<String> allSlots = buildDefaultSlots();
    // final int requiredSlots = _requiredSlotCount(durationMinutes);

    return allSlots.where((slot) {
      return availabilityFailureReason(
            bookings: bookings,
            stylistId: stylistId,
            date: date,
            time: slot,
            durationMinutes: durationMinutes,
          ) ==
          null;
    }).toList(growable: false);
  }

  static Future<bool> checkAvailability(
    List<BookingModel> bookings,
    String stylistId,
    DateTime date,
    String time, {
    int durationMinutes = 0,
    String? excludedBookingId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 140));

    return availabilityFailureReason(
          bookings: bookings,
          stylistId: stylistId,
          date: date,
          time: time,
          durationMinutes: durationMinutes,
          excludedBookingId: excludedBookingId,
        ) ==
        null;
  }

  static Future<String?> getAvailabilityMessage(
    List<BookingModel> bookings,
    String stylistId,
    DateTime date,
    String time, {
    int durationMinutes = 0,
    String? excludedBookingId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));

    final String? normalizedTime = normalizeTime(time);
    if (normalizedTime == null) {
      return 'Format jam booking belum valid. Gunakan format HH:mm.';
    }

    final int resolvedDuration = durationMinutes > 0 ? durationMinutes : slotDurationMinutes;
    return availabilityFailureReason(
      bookings: bookings,
      stylistId: stylistId,
      date: date,
      time: normalizedTime,
      durationMinutes: resolvedDuration,
      excludedBookingId: excludedBookingId,
    );
  }

  static List<String> buildDefaultSlots() {
    final List<String> slots = <String>[];

    for (int hour = startHour; hour <= endHour; hour++) {
      slots.add('${hour.toString().padLeft(2, '0')}:00');
    }

    return slots;
  }

  static String? normalizeTime(String rawTime) {
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

  static String? availabilityFailureReason({
    required List<BookingModel> bookings,
    required String stylistId,
    required DateTime date,
    required String time,
    required int durationMinutes,
    String? excludedBookingId,
  }) {
    final String? normalizedTime = normalizeTime(time);
    if (normalizedTime == null) {
      return 'Format jam booking belum valid. Gunakan format HH:mm.';
    }

    final List<String> allSlots = buildDefaultSlots();
    final int selectedIndex = allSlots.indexOf(normalizedTime);
    if (selectedIndex < 0) {
      return 'Jam booking harus berada di antara 08:00 sampai 20:00 dan tetap cukup untuk menyelesaikan layanan.';
    }

    final int requiredSlots = _requiredSlotCount(durationMinutes);
    if (selectedIndex + requiredSlots > allSlots.length) {
      if (normalizedTime == '20:00' && durationMinutes > slotDurationMinutes) {
        return 'Jam 20:00 hanya bisa dipakai untuk layanan berdurasi maksimal 60 menit. Silakan pilih layanan yang lebih singkat atau jam yang lebih awal.';
      }

      final int startHourLabel = startHour;
      final int endHourLabel = endHour;
      return 'Waktu yang dipilih belum cukup untuk durasi layanan ini. Silakan pilih jam yang lebih awal atau pilih layanan yang lebih singkat. Jam booking harus berada di antara ${startHourLabel.toString().padLeft(2, '0')}:00 sampai ${endHourLabel.toString().padLeft(2, '0')}:00 dan tetap cukup untuk menyelesaikan layanan.';
    }

    final int candidateEndIndex = selectedIndex + requiredSlots;

    for (final booking in bookings) {
      if (excludedBookingId != null && booking.id == excludedBookingId) {
        continue;
      }

      if (booking.stylistId != stylistId || !_isSameDate(booking.bookingDate, date) || booking.status == BookingStatus.cancelled) {
        continue;
      }

      final String? existingTime = normalizeTime(booking.bookingTime);
      if (existingTime == null) {
        continue;
      }

      final int existingStartIndex = allSlots.indexOf(existingTime);
      if (existingStartIndex < 0) {
        continue;
      }

      final int existingDuration = _resolveBookingDurationMinutesSync(booking.serviceIds);
      final int existingSlots = _requiredSlotCount(existingDuration);
      final int existingEndIndex = existingStartIndex + existingSlots;

      final bool hasOverlap = selectedIndex < existingEndIndex && candidateEndIndex > existingStartIndex;
      if (hasOverlap) {
        return 'Slot ini sudah terisi oleh booking lain. Silakan pilih jam lain yang masih kosong.';
      }
    }

    return null;
  }

  static bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static int _resolveBookingDurationMinutesSync(List<String> serviceIds) {
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

  static int _timeToMinutes(String time) {
    final List<String> parts = time.split(':');
    final int hour = int.tryParse(parts.isNotEmpty ? parts[0] : '0') ?? 0;
    final int minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    return hour * 60 + minute;
  }

  static int _requiredSlotCount(int durationMinutes) {
    if (durationMinutes <= 0) {
      return 0;
    }

    return (durationMinutes / slotDurationMinutes).ceil();
  }
}