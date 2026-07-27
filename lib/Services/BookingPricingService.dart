import 'package:salon_and_beauty/Models/DiscountModel.dart';
import 'package:salon_and_beauty/Models/PaymentModel.dart';
import 'package:salon_and_beauty/Models/ServiceModel.dart';

class PricingResult {
  const PricingResult({
    required this.payment,
    this.appliedDiscount,
  });

  final PaymentModel payment;
  final Discount? appliedDiscount;
}

class BookingPricingService {
  static Future<PricingResult> calculate({
    required List<ServiceModel> services,
    required DateTime bookingDate,
    required List<Discount> discounts,
  }) async {
    final subtotal = services.fold<int>(0, (sum, s) => sum + s.price);

    final activeDiscounts = discounts.where(
      (d) =>
          !bookingDate.isBefore(d.startDate) &&
          !bookingDate.isAfter(d.endDate),
    );

    final eligible = activeDiscounts
        .where((d) => d.minSpend <= subtotal)
        .toList(growable: false);

    if (eligible.isEmpty) {
      return PricingResult(
        payment: PaymentModel.fromSubtotal(subtotal: subtotal),
      );
    }

    eligible.sort((a, b) {
      final cmp = b.minSpend.compareTo(a.minSpend);
      if (cmp != 0) return cmp;
      final aAmount = (subtotal * a.percent / 100).round();
      final bAmount = (subtotal * b.percent / 100).round();
      return bAmount.compareTo(aAmount);
    });

    final best = eligible.first;
    final rawDiscount = (subtotal * best.percent / 100).round();
    final discountAmount =
        rawDiscount > best.maxAmount ? best.maxAmount : rawDiscount;

    final payment = PaymentModel.fromSubtotal(
      subtotal: subtotal,
      discountPercentage: best.percent.toDouble(),
      discountAmount: discountAmount,
    );

    return PricingResult(payment: payment, appliedDiscount: best);
  }
}
