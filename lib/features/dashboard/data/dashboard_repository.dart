import 'package:flutter/material.dart';

class DashboardRepository {
  const DashboardRepository();

  DashboardSnapshot getSnapshot() {
    return const DashboardSnapshot(
      customer: CustomerProfile(
        name: 'Siska Amanda',
        greeting: 'Halo,',
        email: 'siska.amanda@email.com',
      ),
      promo: PromoBanner(
        title: 'Special Promo',
        subtitle: 'All Hair Treatment',
        discountLabel: 'Disc. 20%',
        note: 'Berlaku hingga 31 Mei 2025',
      ),
      nextBooking: BookingPreview(
        dateLabel: 'Sabtu, 25 Mei 2025',
        timeLabel: '10:00 - 12:00',
        stylistName: 'Nadia Putri',
        serviceSummary: 'Haircut + Hair Spa',
        statusLabel: 'Menunggu',
      ),
      quickActions: <QuickAction>[
        QuickAction(
          title: 'Stylist',
          icon: Icons.person_outline,
        ),
        QuickAction(
          title: 'Layanan',
          icon: Icons.content_cut,
        ),
        QuickAction(
          title: 'Booking',
          icon: Icons.calendar_month_outlined,
        ),
        QuickAction(
          title: 'Riwayat',
          icon: Icons.receipt_long_outlined,
        ),
      ],
    );
  }
}

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.customer,
    required this.promo,
    required this.nextBooking,
    required this.quickActions,
  });

  final CustomerProfile customer;
  final PromoBanner promo;
  final BookingPreview nextBooking;
  final List<QuickAction> quickActions;
}

class CustomerProfile {
  const CustomerProfile({
    required this.name,
    required this.greeting,
    required this.email,
  });

  final String name;
  final String greeting;
  final String email;
}

class PromoBanner {
  const PromoBanner({
    required this.title,
    required this.subtitle,
    required this.discountLabel,
    required this.note,
  });

  final String title;
  final String subtitle;
  final String discountLabel;
  final String note;
}

class BookingPreview {
  const BookingPreview({
    required this.dateLabel,
    required this.timeLabel,
    required this.stylistName,
    required this.serviceSummary,
    required this.statusLabel,
  });

  final String dateLabel;
  final String timeLabel;
  final String stylistName;
  final String serviceSummary;
  final String statusLabel;
}

class QuickAction {
  const QuickAction({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;
}
