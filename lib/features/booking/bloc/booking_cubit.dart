import 'package:flutter_bloc/flutter_bloc.dart';

import '../../service/data/service_model.dart';
import '../../service/data/service_repository.dart';
import '../data/booking_model.dart';
import '../data/booking_repository.dart';
import '../data/payment_model.dart';
import '../domain/booking_pricing_service.dart';
import '../../../core/data/dummy_discounts.dart';
import '../../../core/models/discount.dart';
import '../../../core/session/auth_session.dart';

abstract class BookingState {
  const BookingState();
}

class BookingInitial extends BookingState {
  const BookingInitial();
}

class BookingLoading extends BookingState {
  const BookingLoading({this.previousState});

  final BookingScheduleState? previousState;
}

class BookingScheduleState extends BookingState {
  const BookingScheduleState({
    required this.selectedStylistId,
    required this.selectedServiceIds,
    required this.selectedDate,
    required this.selectedTime,
    required this.notes,
    required this.availableSlots,
  });

  const BookingScheduleState.initial()
      : selectedStylistId = null,
        selectedServiceIds = const <String>[],
        selectedDate = null,
        selectedTime = null,
        notes = '',
        availableSlots = const <String>[];

  final String? selectedStylistId;
  final List<String> selectedServiceIds;
  final DateTime? selectedDate;
  final String? selectedTime;
  final String notes;
  final List<String> availableSlots;

  bool get canProceedToCheckout {
    return selectedStylistId != null &&
        selectedServiceIds.isNotEmpty &&
        selectedDate != null &&
        selectedTime != null;
  }

  BookingScheduleState copyWith({
    String? selectedStylistId,
    bool clearSelectedStylist = false,
    List<String>? selectedServiceIds,
    DateTime? selectedDate,
    bool clearSelectedDate = false,
    String? selectedTime,
    bool clearSelectedTime = false,
    String? notes,
    List<String>? availableSlots,
    bool clearAvailableSlots = false,
  }) {
    return BookingScheduleState(
      selectedStylistId:
          clearSelectedStylist ? null : selectedStylistId ?? this.selectedStylistId,
      selectedServiceIds: selectedServiceIds ?? this.selectedServiceIds,
      selectedDate: clearSelectedDate ? null : selectedDate ?? this.selectedDate,
      selectedTime: clearSelectedTime ? null : selectedTime ?? this.selectedTime,
      notes: notes ?? this.notes,
      availableSlots: clearAvailableSlots ? const <String>[] : availableSlots ?? this.availableSlots,
    );
  }
}

class AvailableSlotsLoaded extends BookingScheduleState {
  const AvailableSlotsLoaded({
    required super.selectedStylistId,
    required super.selectedServiceIds,
    required super.selectedDate,
    required super.selectedTime,
    required super.notes,
    required super.availableSlots,
  });

  factory AvailableSlotsLoaded.fromSchedule(BookingScheduleState state) {
    return AvailableSlotsLoaded(
      selectedStylistId: state.selectedStylistId,
      selectedServiceIds: state.selectedServiceIds,
      selectedDate: state.selectedDate,
      selectedTime: state.selectedTime,
      notes: state.notes,
      availableSlots: state.availableSlots,
    );
  }
}

class BookingSuccess extends BookingState {
  const BookingSuccess({
    required this.booking,
    required this.payment,
    required this.scheduleState,
    this.appliedDiscount,
  });

  final BookingModel booking;
  final PaymentModel payment;
  final BookingScheduleState scheduleState;
  final Discount? appliedDiscount;
}

class BookingCheckoutSnapshot {
  const BookingCheckoutSnapshot({
    required this.scheduleState,
    required this.selectedServices,
    required this.payment,
    this.appliedDiscount,
  });

  final BookingScheduleState scheduleState;
  final List<ServiceModel> selectedServices;
  final PaymentModel payment;
  final Discount? appliedDiscount;

  String get discountLabel {
    final Discount? discount = appliedDiscount;
    if (discount == null) {
      return 'Tidak ada diskon';
    }

    return 'Diskon ${discount.code} (${discount.percent}% maks Rp${discount.maxAmount})';
  }
}

class BookingError extends BookingState {
  const BookingError({
    required this.message,
    required this.scheduleState,
  });

  final String message;
  final BookingScheduleState scheduleState;
}

class BookingCubit extends Cubit<BookingState> {
  BookingCubit(this._bookingRepository, this._serviceRepository)
      : _scheduleState = const BookingScheduleState.initial(),
        super(const BookingInitial());

  final BookingRepository _bookingRepository;
  final ServiceRepository _serviceRepository;

  static String get _activeCustomerId => AuthSession.activeCustomerId;

  BookingScheduleState _scheduleState;

  BookingScheduleState get scheduleState => _scheduleState;

  Future<void> selectStylist(String stylistId) async {
    final bool stylistChanged = _scheduleState.selectedStylistId != stylistId;

    _scheduleState = _scheduleState.copyWith(
      selectedStylistId: stylistId,
      clearSelectedTime: stylistChanged,
      clearAvailableSlots: stylistChanged,
    );

    emit(_scheduleState);

    if (_scheduleState.selectedDate != null) {
      await loadAvailableSlots(stylistId, _scheduleState.selectedDate!);
    }
  }

  void selectServices(List<String> serviceIds) {
    _scheduleState = _scheduleState.copyWith(
      selectedServiceIds: serviceIds.toSet().toList(growable: false),
    );

    emit(_scheduleState);
    // When selected services change, total duration may change -> recheck available slots
    // Fire-and-forget loadAvailableSlots so UI updates availability in background.
    final String? stylistId = _scheduleState.selectedStylistId;
    final DateTime? date = _scheduleState.selectedDate;
    if (stylistId != null && date != null) {
      // trigger availability reload in background
      loadAvailableSlots(stylistId, date);
    }
  }

  void selectDate(DateTime date) {
    _scheduleState = _scheduleState.copyWith(
      selectedDate: DateTime(date.year, date.month, date.day),
      clearSelectedTime: true,
      clearAvailableSlots: true,
    );
    emit(_scheduleState);
  }

  Future<void> selectDateTime(DateTime date, String time) async {
    final String? normalizedTime = _normalizeTime(time);
    if (normalizedTime == null) {
      emit(BookingError(
        message: 'Format jam tidak valid. Gunakan format HH:mm.',
        scheduleState: _scheduleState,
      ));
      emit(_scheduleState);
      return;
    }

    _scheduleState = _scheduleState.copyWith(
      selectedDate: DateTime(date.year, date.month, date.day),
    );

    final String? stylistId = _scheduleState.selectedStylistId;
    if (stylistId == null) {
      _scheduleState = _scheduleState.copyWith(clearSelectedTime: true);
      emit(_scheduleState);
      return;
    }

    final bool isAvailable = await _bookingRepository.checkAvailability(
      stylistId,
      _scheduleState.selectedDate!,
      normalizedTime,
      durationMinutes: await _selectedServicesDurationMinutes(),
    );

    if (!isAvailable) {
      emit(BookingError(
        message: 'Jam yang dipilih sudah terisi. Silakan pilih jam lain.',
        scheduleState: _scheduleState,
      ));
      await loadAvailableSlots(stylistId, _scheduleState.selectedDate!);
      return;
    }

    _scheduleState = _scheduleState.copyWith(selectedTime: normalizedTime);
    emit(_scheduleState);
  }

  void updateNotes(String notes) {
    _scheduleState = _scheduleState.copyWith(notes: notes);
    emit(_scheduleState);
  }

  Future<void> loadAvailableSlots(String stylistId, DateTime date) async {
    _scheduleState = _scheduleState.copyWith(
      selectedStylistId: stylistId,
      selectedDate: DateTime(date.year, date.month, date.day),
    );

    emit(BookingLoading(previousState: _scheduleState));

    try {
      print('DBG: BookingCubit.loadAvailableSlots: start for $stylistId ${date.toIso8601String()}');
      final List<String> slots = await _bookingRepository.getAvailableSlotsForStylist(
        stylistId,
        _scheduleState.selectedDate!,
        durationMinutes: await _selectedServicesDurationMinutes(),
      );
      print('DBG: BookingCubit.loadAvailableSlots: got ${slots.length} slots');

      final bool hasCurrentTime =
          _scheduleState.selectedTime != null && slots.contains(_scheduleState.selectedTime);

      _scheduleState = _scheduleState.copyWith(
        availableSlots: slots,
        clearSelectedTime: !hasCurrentTime,
      );

      emit(AvailableSlotsLoaded.fromSchedule(_scheduleState));
    } catch (_) {
      emit(BookingError(
        message: 'Gagal memuat slot waktu yang tersedia.',
        scheduleState: _scheduleState,
      ));
      emit(_scheduleState);
    }
  }

  Future<void> confirmBooking() async {
    final String? validationMessage = _validateSelection(_scheduleState);
    if (validationMessage != null) {
      emit(BookingError(
        message: validationMessage,
        scheduleState: _scheduleState,
      ));
      emit(_scheduleState);
      return;
    }

    emit(BookingLoading(previousState: _scheduleState));

    try {
      final PricingResult pricing = await _calculatePayment(_scheduleState.selectedServiceIds);
      final PaymentModel payment = pricing.payment;

      final BookingModel draftBooking = BookingModel(
        id: '',
        customerId: _activeCustomerId,
        stylistId: _scheduleState.selectedStylistId!,
        serviceIds: _scheduleState.selectedServiceIds,
        bookingDate: _scheduleState.selectedDate!,
        bookingTime: _scheduleState.selectedTime!,
        notes: _scheduleState.notes.trim().isEmpty ? null : _scheduleState.notes.trim(),
        subtotal: payment.subtotal,
        discount: payment.discountAmount,
        totalPrice: payment.totalPrice,
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
      );

      final BookingModel savedBooking = await _bookingRepository.createBooking(draftBooking);

      emit(BookingSuccess(
        booking: savedBooking,
        payment: payment,
        scheduleState: _scheduleState,
        appliedDiscount: pricing.appliedDiscount,
      ));

      _scheduleState = const BookingScheduleState.initial();
      emit(_scheduleState);
    } on StateError catch (error) {
      emit(BookingError(
        message: error.message,
        scheduleState: _scheduleState,
      ));
      emit(_scheduleState);
    } catch (_) {
      emit(BookingError(
        message: 'Gagal membuat booking. Coba lagi.',
        scheduleState: _scheduleState,
      ));
      emit(_scheduleState);
    }
  }

  void clearBooking() {
    _scheduleState = const BookingScheduleState.initial();
    emit(_scheduleState);
  }

  String? _validateSelection(BookingScheduleState state) {
    if (state.selectedStylistId == null) {
      return 'Silakan pilih stylist terlebih dahulu.';
    }
    if (state.selectedServiceIds.isEmpty) {
      return 'Silakan pilih minimal satu layanan.';
    }
    if (state.selectedDate == null) {
      return 'Silakan pilih tanggal booking.';
    }
    if (state.selectedTime == null) {
      return 'Silakan pilih jam booking.';
    }

    return null;
  }

  Future<PricingResult> _calculatePayment(List<String> serviceIds) async {
    final List<ServiceModel> resolved = await _resolveSelectedServices(serviceIds);

    final PricingResult result = await BookingPricingService.calculate(
      resolved,
      bookingDate: _scheduleState.selectedDate,
      discounts: DummyDiscounts.data,
    );

    return result;
  }

  Future<BookingCheckoutSnapshot> buildCheckoutSnapshot() async {
    final List<ServiceModel> selectedServices = await _resolveSelectedServices(
      _scheduleState.selectedServiceIds,
    );

    final PricingResult pricing = await BookingPricingService.calculate(
      selectedServices,
      bookingDate: _scheduleState.selectedDate,
      discounts: DummyDiscounts.data,
    );

    return BookingCheckoutSnapshot(
      scheduleState: _scheduleState,
      selectedServices: selectedServices,
      payment: pricing.payment,
      appliedDiscount: pricing.appliedDiscount,
    );
  }

  Future<List<ServiceModel>> _resolveSelectedServices(List<String> serviceIds) async {
    final List<Future<ServiceModel?>> requests = serviceIds
        .map((serviceId) => _serviceRepository.getServiceById(serviceId))
        .toList(growable: false);

    final List<ServiceModel?> services = await Future.wait(requests);
    return services.whereType<ServiceModel>().toList(growable: false);
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

  Future<int> _selectedServicesDurationMinutes() async {
    if (_scheduleState.selectedServiceIds.isEmpty) {
      return 0;
    }

    final List<Future<ServiceModel?>> requests = _scheduleState.selectedServiceIds
        .map((serviceId) => _serviceRepository.getServiceById(serviceId))
        .toList(growable: false);

    final List<ServiceModel?> services = await Future.wait(requests);

    return services.whereType<ServiceModel>().fold<int>(0, (sum, service) {
      return sum + service.durationMinutes;
    });
  }
}
