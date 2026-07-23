import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salon_and_beauty/Models/ServiceModel.dart';
import 'package:salon_and_beauty/Repositories/ServiceRepository.dart';
import 'package:salon_and_beauty/Models/BookingModel.dart';
import 'package:salon_and_beauty/Repositories/BookingRepository.dart';
import 'package:salon_and_beauty/Models/PaymentModel.dart';
import 'package:salon_and_beauty/Services/BookingRulesService.dart';
import 'package:salon_and_beauty/Models/DiscountModel.dart';
import 'package:salon_and_beauty/Repositories/DiscountRepository.dart';
import 'package:salon_and_beauty/Support/AuthSession.dart';

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
  BookingCubit(
    this._bookingRepository,
    this._serviceRepository,
    this._discountRepository,
  )   : _scheduleState = const BookingScheduleState.initial(),
        super(const BookingInitial());

  final BookingRepository _bookingRepository;
  final ServiceRepository _serviceRepository;
  final DiscountRepository _discountRepository;

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
    final String? stylistId = _scheduleState.selectedStylistId;
    final DateTime? date = _scheduleState.selectedDate;
    if (stylistId != null && date != null) {
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
    _scheduleState = _scheduleState.copyWith(
      selectedDate: DateTime(date.year, date.month, date.day),
    );

    final String? stylistId = _scheduleState.selectedStylistId;
    final List<String> serviceIds = _scheduleState.selectedServiceIds;
    if (stylistId == null || serviceIds.isEmpty) {
      _scheduleState = _scheduleState.copyWith(clearSelectedTime: true);
      emit(_scheduleState);
      return;
    }

    final String dateStr = _toIsoDate(_scheduleState.selectedDate!);
    final bool isAvailable = await _bookingRepository.checkAvailability(
      stylistId,
      dateStr,
      time,
      serviceIds,
    );

    if (!isAvailable) {
      emit(BookingError(
        message: 'Jam yang dipilih belum tersedia. Silakan pilih jam lain.',
        scheduleState: _scheduleState,
      ));
      await loadAvailableSlots(stylistId, _scheduleState.selectedDate!);
      return;
    }

    _scheduleState = _scheduleState.copyWith(selectedTime: time);
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
      final String dateStr = _toIsoDate(_scheduleState.selectedDate!);
      final List<String> slots = await _bookingRepository.getAvailableSlots(
        stylistId,
        dateStr,
        serviceIds: _scheduleState.selectedServiceIds,
      );

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
    final String? validationMessage = BookingRulesService.validateSelection(
      selectedStylistId: _scheduleState.selectedStylistId,
      selectedServiceIds: _scheduleState.selectedServiceIds,
      selectedDate: _scheduleState.selectedDate,
      selectedTime: _scheduleState.selectedTime,
    );
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
      final services = await _resolveSelectedServices(_scheduleState.selectedServiceIds);
      final subtotal = services.fold<int>(0, (sum, s) => sum + s.price);
      final payment = PaymentModel.fromSubtotal(subtotal: subtotal);

      final String dateStr = _toIsoDate(_scheduleState.selectedDate!);

      final BookingModel savedBooking = await _bookingRepository.createBooking(
        stylistId: _scheduleState.selectedStylistId!,
        serviceIds: _scheduleState.selectedServiceIds,
        bookingDate: dateStr,
        bookingTime: _scheduleState.selectedTime!,
        notes: _scheduleState.notes.trim().isEmpty ? null : _scheduleState.notes.trim(),
        subtotal: payment.subtotal,
        discountAmount: payment.discountAmount,
        totalPrice: payment.totalPrice,
      );

      emit(BookingSuccess(
        booking: savedBooking,
        payment: payment,
        scheduleState: _scheduleState,
      ));

      _scheduleState = const BookingScheduleState.initial();
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

  Future<BookingCheckoutSnapshot> buildCheckoutSnapshot() async {
    final List<ServiceModel> selectedServices = await _resolveSelectedServices(
      _scheduleState.selectedServiceIds,
    );

    final subtotal = selectedServices.fold<int>(0, (sum, s) => sum + s.price);
    final payment = PaymentModel.fromSubtotal(subtotal: subtotal);

    return BookingCheckoutSnapshot(
      scheduleState: _scheduleState,
      selectedServices: selectedServices,
      payment: payment,
    );
  }

  Future<List<ServiceModel>> _resolveSelectedServices(List<String> serviceIds) async {
    final List<Future<ServiceModel?>> requests = serviceIds
        .map((serviceId) => _serviceRepository.getServiceById(serviceId))
        .toList(growable: false);

    final List<ServiceModel?> services = await Future.wait(requests);
    return services.whereType<ServiceModel>().toList(growable: false);
  }

  Future<int> _selectedServicesDurationMinutes() async {
    if (_scheduleState.selectedServiceIds.isEmpty) {
      return 0;
    }

    final List<Future<ServiceModel?>> requests = _scheduleState.selectedServiceIds
        .map((serviceId) => _serviceRepository.getServiceById(serviceId))
        .toList(growable: false);

    final List<ServiceModel?> services = await Future.wait(requests);

    return BookingRulesService.totalDurationMinutes(services.whereType<ServiceModel>());
  }

  String _toIsoDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
