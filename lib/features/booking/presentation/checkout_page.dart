import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/discount.dart';

import '../../user/data/dummy_user.dart';
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
    return _CheckoutView(stylists: stylists, services: services);
  }
}

class _CheckoutView extends StatelessWidget {
  const _CheckoutView({required this.stylists, required this.services});

  final List<StylistModel> stylists;
  final List<ServiceModel> services;

  /// 🔥 DATA PROMO (GLOBAL DI CHECKOUT)
  static final List<Discount> discounts = [
    Discount(
      code: "JULY20",
      title: "Promo Juli",
      percent: 20,
      maxAmount: 50000,
      minSpend: 100000,
      startDate: DateTime(2026, 7, 1),
      endDate: DateTime(2026, 7, 31),
    ),
    Discount(
      code: "AUG15",
      title: "Promo Agustus",
      percent: 15,
      maxAmount: 30000,
      minSpend: 80000,
      startDate: DateTime(2026, 8, 1),
      endDate: DateTime(2026, 8, 31),
    ),
  ];

  /// 🔥 FUNCTION CARI PROMO BERDASARKAN TANGGAL
  Discount? getDiscountByDate(DateTime date) {
    for (final d in discounts) {
      final isInRange =
          date.isAfter(d.startDate.subtract(const Duration(days: 1))) &&
          date.isBefore(d.endDate.add(const Duration(days: 1)));

      if (isInRange) return d;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingCubit, BookingState>(
      builder: (context, state) {
        final BookingScheduleState scheduleState = context
            .read<BookingCubit>()
            .scheduleState;

        final snapshot = _buildSnapshot(scheduleState);

        return Scaffold(
          appBar: AppBar(title: const Text('Checkout Booking')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              /// CUSTOMER
              Text(
                DummyUser.activeCustomer.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(DummyUser.activeCustomer.email),

              const SizedBox(height: 20),

              /// BOOKING INFO
              Text(snapshot.dateTimeLabel),

              const SizedBox(height: 20),

              /// SERVICES
              ...snapshot.selectedServices.map(
                (service) => Row(
                  children: [
                    Expanded(child: Text(service.name)),
                    Text(_toRupiah(service.price)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// PAYMENT
              _priceRow('Subtotal', _toRupiah(snapshot.subtotal)),

              _priceRow(
                snapshot.discountLabel,
                '- ${_toRupiah(snapshot.discountAmount)}',
                valueColor: Colors.green,
              ),

              const Divider(),

              _priceRow('Total', _toRupiah(snapshot.total), isStrong: true),
            ],
          ),
        );
      },
    );
  }

  /// 🔥 SNAPSHOT (INI INTI LOGIC)
  _CheckoutSnapshot _buildSnapshot(BookingScheduleState state) {
    final List<ServiceModel> selectedServices = services
        .where((service) => state.selectedServiceIds.contains(service.id))
        .toList();

    final int subtotal = selectedServices.fold(0, (sum, s) => sum + s.price);

    final DateTime? selectedDate = state.selectedDate;

    final Discount? discount = selectedDate != null
        ? getDiscountByDate(selectedDate)
        : null;

    int discountAmount = 0;
    String discountLabel = 'Tidak ada diskon';

    if (discount != null && subtotal >= discount.minSpend) {
      final percentValue = ((subtotal * discount.percent) / 100).round();

      discountAmount = percentValue > discount.maxAmount
          ? discount.maxAmount
          : percentValue;

      discountLabel =
          'Diskon ${discount.code} (${discount.percent}% maks Rp${discount.maxAmount})';
    }

    return _CheckoutSnapshot(
      dateTimeLabel: _dateTimeLabel(state),
      selectedServices: selectedServices,
      subtotal: subtotal,
      discountAmount: discountAmount,
      total: subtotal - discountAmount,
      discountLabel: discountLabel,
    );
  }

  String _dateTimeLabel(BookingScheduleState state) {
    if (state.selectedDate == null) return '-';

    final date = state.selectedDate!;
    return "${date.day}/${date.month}/${date.year}";
  }

  Widget _priceRow(
    String label,
    String value, {
    Color? valueColor,
    bool isStrong = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: isStrong ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  String _toRupiah(int value) {
    return "Rp$value";
  }
}

class _CheckoutSnapshot {
  final String dateTimeLabel;
  final List<ServiceModel> selectedServices;
  final int subtotal;
  final int discountAmount;
  final int total;
  final String discountLabel;

  _CheckoutSnapshot({
    required this.dateTimeLabel,
    required this.selectedServices,
    required this.subtotal,
    required this.discountAmount,
    required this.total,
    required this.discountLabel,
  });
}
