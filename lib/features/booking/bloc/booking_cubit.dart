import 'package:flutter_bloc/flutter_bloc.dart';

import '../../service/data/service_model.dart';
import '../../service/data/service_repository.dart';
import '../data/booking_model.dart';
import '../data/booking_repository.dart';
import '../data/payment_model.dart';

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
  });

  final BookingModel booking;
  final PaymentModel payment;
  final BookingScheduleState scheduleState;
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

  static const String _activeCustomerId = 'cus-001';

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
      final List<String> slots = await _bookingRepository.getAvailableSlotsForStylist(
        stylistId,
        _scheduleState.selectedDate!,
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
      final PaymentModel payment = await _calculatePayment(_scheduleState.selectedServiceIds);

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

  Future<PaymentModel> _calculatePayment(List<String> serviceIds) async {
    final List<Future<ServiceModel?>> requests = serviceIds
        .map((serviceId) => _serviceRepository.getServiceById(serviceId))
        .toList(growable: false);

    final List<ServiceModel?> services = await Future.wait(requests);

    int subtotal = 0;
    for (final service in services) {
      if (service != null) {
        subtotal += service.price;
      }
    }

    final int twentyPercentDiscount = ((subtotal * 20) / 100).round();
    final int discountAmount = twentyPercentDiscount > 50000 ? 50000 : twentyPercentDiscount;

    return PaymentModel.fromSubtotal(
      subtotal: subtotal,
      discountPercentage: 20,
      discountAmount: discountAmount,
    );
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
