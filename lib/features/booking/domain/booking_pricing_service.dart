import '../../service/data/service_model.dart';
import '../../booking/data/payment_model.dart';
import '../../../core/models/discount.dart';
import '../../../core/data/dummy_discounts.dart';

class PricingResult {
  PricingResult({required this.payment, this.appliedDiscount});

  final PaymentModel payment;
  final Discount? appliedDiscount;
}

class BookingPricingService {
  BookingPricingService._();

  /// Calculate pricing for given services and optional discounts list.
  ///
  /// Policy: auto-apply the discount (within date range) that yields the
  /// highest nominal discount amount, provided `subtotal >= minSpend`.
  static Future<PricingResult> calculate(
    List<ServiceModel> services, {
    DateTime? bookingDate,
    List<Discount>? discounts,
  }) async {
    final int subtotal = services.fold<int>(0, (s, item) => s + item.price);

    final List<Discount> pool = discounts ?? DummyDiscounts.data;

    Discount? best;
    int bestAmount = 0;

    for (final d in pool) {
      final bool inRange = bookingDate == null
          ? true
          : !(bookingDate.isBefore(d.startDate) || bookingDate.isAfter(d.endDate));

      if (!inRange) continue;
      if (subtotal < d.minSpend) continue;

      final int computed = ((subtotal * d.percent) / 100).round();
      final int capped = computed > d.maxAmount ? d.maxAmount : computed;

      if (capped > bestAmount) {
        bestAmount = capped;
        best = d;
      }
    }

    if (best == null) {
      return PricingResult(
        payment: PaymentModel.fromSubtotal(subtotal: subtotal),
        appliedDiscount: null,
      );
    }

    final int discountAmount = bestAmount;
    return PricingResult(
      payment: PaymentModel.fromSubtotal(
        subtotal: subtotal,
        discountPercentage: best.percent.toDouble(),
        discountAmount: discountAmount,
      ),
      appliedDiscount: best,
    );
  }
}
