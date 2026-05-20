class PaymentModel {
  const PaymentModel({
    required this.subtotal,
    required this.discountPercentage,
    required this.discountAmount,
    required this.totalPrice,
  });

  final int subtotal;
  final double discountPercentage;
  final int discountAmount;
  final int totalPrice;

  factory PaymentModel.fromSubtotal({
    required int subtotal,
    double discountPercentage = 0,
    int? discountAmount,
  }) {
    final int resolvedDiscountAmount = discountAmount ??
        ((subtotal * discountPercentage) / 100).round();
    final int resolvedTotal = subtotal - resolvedDiscountAmount;

    return PaymentModel(
      subtotal: subtotal,
      discountPercentage: discountPercentage,
      discountAmount: resolvedDiscountAmount,
      totalPrice: resolvedTotal < 0 ? 0 : resolvedTotal,
    );
  }

  PaymentModel copyWith({
    int? subtotal,
    double? discountPercentage,
    int? discountAmount,
    int? totalPrice,
  }) {
    return PaymentModel(
      subtotal: subtotal ?? this.subtotal,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountAmount: discountAmount ?? this.discountAmount,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subtotal': subtotal,
      'discountPercentage': discountPercentage,
      'discountAmount': discountAmount,
      'totalPrice': totalPrice,
    };
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      subtotal: _toInt(json['subtotal']),
      discountPercentage: _toDouble(json['discountPercentage']),
      discountAmount: _toInt(json['discountAmount']),
      totalPrice: _toInt(json['totalPrice']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }
}
