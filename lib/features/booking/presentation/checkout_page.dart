import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/session/auth_session.dart';
import '../../service/data/service_model.dart';
import '../../stylist/data/stylist_model.dart';
import '../bloc/booking_cubit.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({
    required this.stylists,
    required this.services,
    super.key,
  });

  final List<StylistModel> stylists;
  final List<ServiceModel> services;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late Future<BookingCheckoutSnapshot> _snapshotFuture;

  @override
  void initState() {
    super.initState();
    _snapshotFuture = context.read<BookingCubit>().buildCheckoutSnapshot();
  }
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }

        if (state is BookingSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking berhasil dikonfirmasi.')),
          );

          // Return the created booking as the result to the caller so callers
          // (BookingSchedulePage, ServiceListPage, etc.) can react and refresh.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.of(context).pop(state.booking);
          });
        }
      },
      builder: (context, state) {
        final bool isSubmitting = state is BookingLoading;

        return Scaffold(
          appBar: AppBar(title: const Text('Checkout Booking')),
          body: FutureBuilder<BookingCheckoutSnapshot>(
            future: _snapshotFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Gagal memuat ringkasan checkout.'),
                );
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final BookingCheckoutSnapshot checkout = snapshot.data!;
              final StylistModel? selectedStylist = widget.stylists
                  .where((stylist) => stylist.id == checkout.scheduleState.selectedStylistId)
                  .cast<StylistModel?>()
                  .firstOrNull;

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    AuthSession.activeUser.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(AuthSession.activeUser.email),

                  const SizedBox(height: 20),

                  _SectionCard(
                    title: 'Ringkasan Booking',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_dateTimeLabel(checkout.scheduleState)),
                        const SizedBox(height: 8),
                        Text(selectedStylist?.name ?? '-'),
                        const SizedBox(height: 8),
                        Text(checkout.scheduleState.selectedTime ?? '-'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  _SectionCard(
                    title: 'Service Dipilih',
                    child: Column(
                      children: checkout.selectedServices
                          .map(
                            (service) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Expanded(child: Text(service.name)),
                                  Text(_toRupiah(service.price)),
                                ],
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _SectionCard(
                    title: 'Pembayaran',
                    child: Column(
                      children: [
                        _priceRow('Subtotal', _toRupiah(checkout.payment.subtotal)),
                        const SizedBox(height: 8),
                        _priceRow(
                          checkout.discountLabel,
                          '- ${_toRupiah(checkout.payment.discountAmount)}',
                          valueColor: Colors.green,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(),
                        ),
                        _priceRow(
                          'Total Pembayaran',
                          _toRupiah(checkout.payment.totalPrice),
                          isStrong: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isSubmitting ? null : () => Navigator.of(context).maybePop(),
                          child: const Text('Kembali'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: isSubmitting
                              ? null
                              : () => context.read<BookingCubit>().confirmBooking(),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Konfirmasi Booking'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  String _dateTimeLabel(BookingScheduleState state) {
    if (state.selectedDate == null) {
      return '-';
    }

    final DateTime date = state.selectedDate!;
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return '$day/$month/$year ${state.selectedTime ?? ''}'.trim();
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
        Expanded(child: Text(label)),
        const SizedBox(width: 12),
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
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
