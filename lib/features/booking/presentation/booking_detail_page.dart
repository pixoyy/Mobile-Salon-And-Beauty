import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../service/data/service_model.dart';
import '../../service/data/service_repository.dart';
import '../../stylist/data/dummy_stylists.dart';
import '../../stylist/data/stylist_model.dart';
import '../../stylist/data/stylist_repository.dart';
import '../data/booking_model.dart';
import '../data/booking_repository.dart';

class BookingDetailPage extends StatefulWidget {
  const BookingDetailPage({required this.booking, super.key});

  final BookingModel booking;

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  final BookingRepository _bookingRepository = BookingRepository();
  late final Future<_BookingDetailPayload> _payloadFuture;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _payloadFuture = _loadPayload();
  }

  Future<_BookingDetailPayload> _loadPayload() async {
    final StylistRepository stylistRepository = StylistRepository();
    final ServiceRepository serviceRepository = ServiceRepository();

    final StylistModel? stylist = await stylistRepository.getStylistById(widget.booking.stylistId);
    final List<ServiceModel> services = await Future.wait<ServiceModel?>(
      widget.booking.serviceIds.map(serviceRepository.getServiceById),
    ).then(
      (items) => items.whereType<ServiceModel>().toList(growable: false),
    );

    return _BookingDetailPayload(
      stylist: stylist ?? DummyStylists.data.first,
      services: services,
    );
  }

  Future<void> _cancelBooking() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Batalkan booking?'),
          content: const Text('Booking yang dibatalkan akan ditandai cancelled dan tidak bisa digunakan lagi.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Ya, batalkan'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    setState(() => _isProcessing = true);
    try {
      final BookingModel updated = widget.booking.copyWith(status: BookingStatus.cancelled);
      await _bookingRepository.updateBooking(widget.booking.id, updated);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking dibatalkan.')),
      );
      Navigator.of(context).pop(updated);
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membatalkan booking.')),
      );
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_BookingDetailPayload>(
      future: _payloadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Booking')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Booking')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.event_busy_outlined, size: 44, color: AppColors.mutedText),
                    const SizedBox(height: 12),
                    Text(
                      'Detail booking tidak bisa dimuat.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Silakan kembali dan coba buka detail booking lainnya.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final _BookingDetailPayload payload = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail Booking'),
            actions: [
              IconButton(
                tooltip: 'Share booking',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Berbagi booking akan hadir di phase berikutnya.')),
                  );
                },
                icon: const Icon(Icons.ios_share_outlined),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                _BookingHeaderCard(booking: widget.booking),
                const SizedBox(height: 14),
                _StylistInfoCard(stylist: payload.stylist),
                const SizedBox(height: 14),
                _ServicesCard(services: payload.services, booking: widget.booking),
                const SizedBox(height: 14),
                _ScheduleCard(booking: widget.booking),
                const SizedBox(height: 14),
                _MapSnippetCard(stylistName: payload.stylist.name),
                const SizedBox(height: 14),
                _NotesCard(notes: widget.booking.notes),
                const SizedBox(height: 14),
                _PricingCard(booking: widget.booking),
                const SizedBox(height: 18),
                if (_canCancel(widget.booking.status))
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                          child: const Text('Kembali'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _isProcessing ? null : _cancelBooking,
                          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                          child: _isProcessing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Cancel Booking'),
                        ),
                      ),
                    ],
                  )
                else
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                    child: const Text('Kembali'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _canCancel(BookingStatus status) {
    return status == BookingStatus.upcoming || status == BookingStatus.onGoing;
  }
}

class _BookingHeaderCard extends StatelessWidget {
  const _BookingHeaderCard({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B3A62), Color(0xFFB45A86)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.bookingCode,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              _StatusChip(status: booking.status, isLight: true),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Detail reservasi yang tersimpan untuk kunjungan ini.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.92)),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _HeaderMeta(
                icon: Icons.event_outlined,
                text: _formatDate(booking.bookingDate),
              ),
              const SizedBox(width: 10),
              _HeaderMeta(
                icon: Icons.schedule_outlined,
                text: booking.bookingTime,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderMeta extends StatelessWidget {
  const _HeaderMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _StylistInfoCard extends StatelessWidget {
  const _StylistInfoCard({required this.stylist});

  final StylistModel stylist;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      title: 'Stylist',
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              stylist.photoUrl,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  width: 72,
                  height: 72,
                  color: AppColors.secondary.withValues(alpha: 0.18),
                  alignment: Alignment.center,
                  child: const Icon(Icons.person, color: AppColors.primary),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stylist.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  stylist.specialization,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: stylist.skills.take(3).map((skill) => _TinyChip(label: skill)).toList(growable: false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicesCard extends StatelessWidget {
  const _ServicesCard({required this.services, required this.booking});

  final List<ServiceModel> services;
  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      title: 'Layanan',
      child: Column(
        children: [
          for (final ServiceModel service in services)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(service.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(
                          '${service.durationMinutes} menit',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mutedText),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _toRupiah(service.price),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: _TinyChip(label: '${booking.serviceIds.length} layanan dipilih'),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      title: 'Jadwal',
      child: Row(
        children: [
          Expanded(
            child: _ScheduleTile(
              icon: Icons.event_outlined,
              label: 'Tanggal',
              value: _formatDate(booking.bookingDate),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ScheduleTile(
              icon: Icons.schedule_outlined,
              label: 'Jam',
              value: booking.bookingTime,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mutedText)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _MapSnippetCard extends StatelessWidget {
  const _MapSnippetCard({required this.stylistName});

  final String stylistName;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      title: 'Lokasi Salon',
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F2F4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _MapGridPainter(),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 18, offset: Offset(0, 8))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Glamora Salon • ${stylistName.split(' ').first}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Text(
                'Snip lokasi ini memudahkan user melihat konteks salon sebelum datang.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mutedText),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = const Color(0x1A8B3A62)
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }

    for (double y = 0; y <= size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final Paint accent = Paint()..color = const Color(0x338B3A62);
    canvas.drawCircle(Offset(size.width * 0.68, size.height * 0.34), 26, accent);
    canvas.drawCircle(Offset(size.width * 0.32, size.height * 0.62), 16, accent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.notes});

  final String? notes;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      title: 'Catatan',
      child: Text(
        (notes == null || notes!.trim().isEmpty) ? 'Tidak ada catatan tambahan.' : notes!,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.text),
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  const _PricingCard({required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      title: 'Rincian Harga',
      child: Column(
        children: [
          _PriceRow(label: 'Subtotal', value: _toRupiah(booking.subtotal)),
          const SizedBox(height: 8),
          _PriceRow(label: 'Diskon', value: '- ${_toRupiah(booking.discount)}', valueColor: AppColors.success),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1),
          ),
          _PriceRow(
            label: 'Total Pembayaran',
            value: _toRupiah(booking.totalPrice),
            valueColor: AppColors.primary,
            valueWeight: FontWeight.w800,
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.valueWeight,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final FontWeight? valueWeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: valueColor,
                fontWeight: valueWeight ?? FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, this.isLight = false});

  final BookingStatus status;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;
    final Color foregroundColor;

    switch (status) {
      case BookingStatus.upcoming:
        backgroundColor = isLight ? Colors.white.withValues(alpha: 0.16) : const Color(0xFFFFF2CC);
        foregroundColor = isLight ? Colors.white : const Color(0xFF8A5B00);
      case BookingStatus.onGoing:
        backgroundColor = isLight ? Colors.white.withValues(alpha: 0.16) : const Color(0xFFE3F3E8);
        foregroundColor = isLight ? Colors.white : const Color(0xFF1F7A3D);
      case BookingStatus.completed:
        backgroundColor = isLight ? Colors.white.withValues(alpha: 0.16) : const Color(0xFFE7EEFF);
        foregroundColor = isLight ? Colors.white : const Color(0xFF2952A3);
      case BookingStatus.cancelled:
        backgroundColor = isLight ? Colors.white.withValues(alpha: 0.16) : const Color(0xFFF5E4E7);
        foregroundColor = isLight ? Colors.white : const Color(0xFF9B314D);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusLabel(status),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _TinyChip extends StatelessWidget {
  const _TinyChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _BookingDetailPayload {
  const _BookingDetailPayload({required this.stylist, required this.services});

  final StylistModel stylist;
  final List<ServiceModel> services;
}

String _statusLabel(BookingStatus status) {
  switch (status) {
    case BookingStatus.upcoming:
      return 'Upcoming';
    case BookingStatus.onGoing:
      return 'On Going';
    case BookingStatus.completed:
      return 'Completed';
    case BookingStatus.cancelled:
      return 'Dibatalkan';
  }
}

String _formatDate(DateTime dateTime) {
  const List<String> monthNames = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  return '${dateTime.day.toString().padLeft(2, '0')} ${monthNames[dateTime.month - 1]} ${dateTime.year}';
}

String _toRupiah(int value) {
  final String digits = value.abs().toString();
  final StringBuffer buffer = StringBuffer();

  for (int index = 0; index < digits.length; index++) {
    final int reverseIndex = digits.length - index;
    buffer.write(digits[index]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write('.');
    }
  }

  final String formatted = buffer.toString();
  return value < 0 ? 'Rp-$formatted' : 'Rp$formatted';
}