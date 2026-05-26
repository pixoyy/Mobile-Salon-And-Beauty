import '../../service/data/service_model.dart';

class BookingRulesService {
  BookingRulesService._();

  static String? validateSelection({
    required String? selectedStylistId,
    required List<String> selectedServiceIds,
    required DateTime? selectedDate,
    required String? selectedTime,
  }) {
    if (selectedStylistId == null) {
      return 'Silakan pilih stylist terlebih dahulu.';
    }
    if (selectedServiceIds.isEmpty) {
      return 'Silakan pilih minimal satu layanan.';
    }
    if (selectedDate == null) {
      return 'Silakan pilih tanggal booking.';
    }
    if (selectedTime == null) {
      return 'Silakan pilih jam booking.';
    }

    return null;
  }

  static int totalDurationMinutes(Iterable<ServiceModel> services) {
    return services.fold<int>(0, (sum, service) => sum + service.durationMinutes);
  }

  static List<String> highlightedSlots({
    required List<String> allSlots,
    required String? selectedTime,
    required int totalDurationMinutes,
  }) {
    if (selectedTime == null || totalDurationMinutes <= 0) {
      return const <String>[];
    }

    final int selectedIndex = allSlots.indexOf(selectedTime);
    if (selectedIndex < 0) {
      return const <String>[];
    }

    final int totalSlots = (totalDurationMinutes / 60).ceil();
    final int occupiedAfterStart = totalSlots > 0 ? totalSlots - 1 : 0;
    if (occupiedAfterStart <= 0) {
      return const <String>[];
    }

    return allSlots.skip(selectedIndex + 1).take(occupiedAfterStart).toList(growable: false);
  }
}