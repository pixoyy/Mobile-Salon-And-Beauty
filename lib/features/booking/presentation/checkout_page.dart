import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../user/data/dummy_user.dart';
import 'booking_detail_page.dart';
import '../../service/data/service_model.dart';
import '../../stylist/data/stylist_model.dart';
import '../bloc/booking_cubit.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({
    required this.stylists,
    required this.services,
    super.key,
  });

  final List<StylistModel> stylists;
  final List<ServiceModel> services;

  @override
  Widget build(BuildContext context) {
    return _CheckoutView(
      stylists: stylists,
      services: services,
    );
  }
}

class _CheckoutView extends StatelessWidget {
  const _CheckoutView({
    required this.stylists,
    required this.services,
  });

  final List<StylistModel> stylists;
  final List<ServiceModel> services;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state is BookingSuccess) {
          _showSuccessSheet(context, state);
          return;
        }

        if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final BookingScheduleState scheduleState = _resolveScheduleState(context, state);
        final bool isSubmitting = state is BookingLoading;

        final _CheckoutSnapshot snapshot = _buildSnapshot(scheduleState);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Checkout Booking'),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                _SectionCard(
                  title: '1. Data Customer',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DummyUser.activeCustomer.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(DummyUser.activeCustomer.email),
                      // Text(DummyCustomers.activeCustomer.phone),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: '2. Ringkasan Booking',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.face_retouching_natural, color: AppColors.primary),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.stylistName,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(snapshot.dateTimeLabel),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Layanan',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 6),
                      ...snapshot.selectedServices.map(
                        (service) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text('${service.name} (${service.durationMinutes} menit)'),
                              ),
                              Text(_toRupiah(service.price)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: '3. Rincian Pembayaran',
                  child: Column(
                    children: [
                      _priceRow('Subtotal', _toRupiah(snapshot.subtotal)),
                      const SizedBox(height: 8),
                      _priceRow(
                        'Diskon GLAMORA20 (20% maks Rp50.000)',
                        '- ${_toRupiah(snapshot.discountAmount)}',
                        valueColor: AppColors.success,
                      ),
                      const Divider(height: 20),
                      _priceRow(
                        'Total Pembayaran',
                        _toRupiah(snapshot.total),
                        isStrong: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (state is BookingError)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(child: Text(state.message)),
                        TextButton(
                          onPressed: isSubmitting ? null : () => context.read<BookingCubit>().confirmBooking(),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
                        child: const Text('Kembali'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : () => context.read<BookingCubit>().confirmBooking(),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                              )
                            : const Text('Konfirmasi Booking'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showSuccessSheet(BuildContext context, BookingSuccess state) async {
    if (!context.mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Booking berhasil dibuat!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  state.booking.bookingCode,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total pembayaran',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mutedText),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _toRupiah(state.payment.totalPrice),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      // Pop back to BookingMenuPage (pop 2: CheckoutPage and BookingSchedulePage)
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      // Navigate to detail page on top of booking menu
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BookingDetailPage(booking: state.booking),
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('Lihat Detail Booking'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      // Pop back to BookingMenuPage to show the new booking in the list
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back_outlined),
                    label: const Text('Kembali ke Daftar Booking'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  BookingScheduleState _resolveScheduleState(BuildContext context, BookingState state) {
    if (state is BookingScheduleState) {
      return state;
    }

    if (state is BookingLoading && state.previousState != null) {
      return state.previousState!;
    }

    if (state is BookingError) {
      return state.scheduleState;
    }

    if (state is BookingSuccess) {
      return state.scheduleState;
    }

    return context.read<BookingCubit>().scheduleState;
  }

  _CheckoutSnapshot _buildSnapshot(BookingScheduleState state) {
    final String? stylistId = state.selectedStylistId;
    final StylistModel? stylist = stylistId == null
        ? null
        : stylists.where((item) => item.id == stylistId).firstOrNull;

    final List<ServiceModel> selectedServices = services
        .where((service) => state.selectedServiceIds.contains(service.id))
        .toList(growable: false);

    final int subtotal = selectedServices.fold<int>(0, (sum, service) => sum + service.price);
    final int twentyPercent = ((subtotal * 20) / 100).round();
    final int discountAmount = twentyPercent > 50000 ? 50000 : twentyPercent;

    return _CheckoutSnapshot(
      stylistName: stylist?.name ?? '-',
      dateTimeLabel: _dateTimeLabel(state),
      selectedServices: selectedServices,
      subtotal: subtotal,
      discountAmount: discountAmount,
      total: subtotal - discountAmount,
    );
  }

  String _dateTimeLabel(BookingScheduleState state) {
    if (state.selectedDate == null || state.selectedTime == null) {
      return '-';
    }

    final DateTime date = state.selectedDate!;
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return '$day/$month/$year • ${state.selectedTime}';
  }

  Widget _priceRow(
    String label,
    String value, {
    Color? valueColor,
    bool isStrong = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontWeight: isStrong ? FontWeight.w700 : FontWeight.w400),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: isStrong ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _toRupiah(int value) {
    final String digits = value.toString();
    final StringBuffer buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      final int reverseIndex = digits.length - i;
      buffer.write(digits[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }

    return 'Rp$buffer';
  }
}

class _CheckoutSnapshot {
  const _CheckoutSnapshot({
    required this.stylistName,
    required this.dateTimeLabel,
    required this.selectedServices,
    required this.subtotal,
    required this.discountAmount,
    required this.total,
  });

  final String stylistName;
  final String dateTimeLabel;
  final List<ServiceModel> selectedServices;
  final int subtotal;
  final int discountAmount;
  final int total;
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    if (isEmpty) {
      return null;
    }
    return first;
  }
}
