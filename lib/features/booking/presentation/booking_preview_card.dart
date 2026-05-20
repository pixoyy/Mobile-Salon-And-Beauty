import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/booking_model.dart';

class BookingPreviewCard extends StatelessWidget {
  const BookingPreviewCard({
    required this.booking,
    required this.stylistName,
    required this.stylistPhotoUrl,
    required this.serviceNames,
    required this.onTap,
    super.key,
  });

  final BookingModel booking;
  final String stylistName;
  final String stylistPhotoUrl;
  final List<String> serviceNames;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  stylistPhotoUrl,
                  width: 54,
                  height: 54,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      width: 54,
                      height: 54,
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            booking.bookingCode,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _StatusChip(status: booking.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stylistName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatDate(booking.bookingDate)} • ${booking.bookingTime}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mutedText),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      serviceNames.join(' · '),
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;
    final Color foregroundColor;

    switch (status) {
      case BookingStatus.pending:
        backgroundColor = const Color(0xFFFFF2CC);
        foregroundColor = const Color(0xFF8A5B00);
      case BookingStatus.confirmed:
        backgroundColor = const Color(0xFFE3F3E8);
        foregroundColor = const Color(0xFF1F7A3D);
      case BookingStatus.completed:
        backgroundColor = const Color(0xFFE7EEFF);
        foregroundColor = const Color(0xFF2952A3);
      case BookingStatus.cancelled:
        backgroundColor = const Color(0xFFF5E4E7);
        foregroundColor = const Color(0xFF9B314D);
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

String _statusLabel(BookingStatus status) {
  switch (status) {
    case BookingStatus.pending:
      return 'Pending';
    case BookingStatus.confirmed:
      return 'Confirmed';
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