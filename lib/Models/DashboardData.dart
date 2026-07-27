import 'package:flutter/material.dart';
import 'package:salon_and_beauty/Models/BookingModel.dart';
import 'package:salon_and_beauty/Models/DiscountModel.dart';
import 'package:salon_and_beauty/Models/ServiceModel.dart';
import 'package:salon_and_beauty/Models/StylistModel.dart';

class DashboardData {
  final String greeting;
  final List<Discount> promos;
  final BookingModel? nextBooking;
  final List<QuickAction> quickActions;
  final List<ServiceModel> popularServices;
  final List<StylistModel> recommendedStylists;

  DashboardData({
    required this.greeting,
    required this.promos,
    this.nextBooking,
    required this.quickActions,
    required this.popularServices,
    required this.recommendedStylists,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      greeting: json['greeting']?.toString() ?? '',
      promos: (json['promos'] as List?)
              ?.map((j) => Discount.fromJson(j))
              .toList() ??
          [],
      nextBooking: json['next_booking'] != null
          ? BookingModel.fromJson(json['next_booking'])
          : null,
      quickActions: _buildQuickActions(),
      popularServices: (json['popular_services'] as List?)
              ?.map((j) => ServiceModel.fromJson(j))
              .toList() ??
          [],
      recommendedStylists: (json['recommended_stylists'] as List?)
              ?.map((j) => StylistModel.fromJson(j))
              .toList() ??
          [],
    );
  }

  static List<QuickAction> _buildQuickActions() {
    return [
      QuickAction(title: 'Stylist', icon: Icons.person_outline),
      QuickAction(title: 'Layanan', icon: Icons.content_cut),
      QuickAction(title: 'Booking', icon: Icons.calendar_month_outlined),
      QuickAction(title: 'Riwayat', icon: Icons.receipt_long_outlined),
    ];
  }
}

class QuickAction {
  final String title;
  final IconData icon;

  const QuickAction({
    required this.title,
    required this.icon,
  });
}
