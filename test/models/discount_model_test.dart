import 'package:flutter_test/flutter_test.dart';
import 'package:salon_and_beauty/Models/DiscountModel.dart';

void main() {
  group('Discount.fromJson', () {
    test('parses discount with snake_case', () {
      final json = {
        'code': 'PROMO20',
        'title': 'Promo 20%',
        'percent': 20,
        'max_amount': 50000,
        'min_spend': 100000,
        'start_date': '2025-01-01T00:00:00Z',
        'end_date': '2025-12-31T23:59:59Z',
      };

      final discount = Discount.fromJson(json);

      expect(discount.code, 'PROMO20');
      expect(discount.percent, 20);
      expect(discount.maxAmount, 50000);
      expect(discount.minSpend, 100000);
      expect(discount.startDate.year, 2025);
      expect(discount.endDate.year, 2025);
    });

    test('handles zero values', () {
      final json = {
        'code': 'FREE',
        'title': 'Free',
        'percent': 0,
        'max_amount': 0,
        'min_spend': 0,
        'start_date': '2025-06-01T00:00:00Z',
        'end_date': '2025-06-30T23:59:59Z',
      };

      final discount = Discount.fromJson(json);

      expect(discount.percent, 0);
      expect(discount.maxAmount, 0);
      expect(discount.minSpend, 0);
    });

    test('toJson produces snake_case', () {
      final discount = Discount(
        code: 'TEST',
        title: 'Test',
        percent: 10,
        maxAmount: 10000,
        minSpend: 50000,
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 12, 31),
      );

      final json = discount.toJson();

      expect(json['max_amount'], 10000);
      expect(json['min_spend'], 50000);
      expect(json['start_date'], isA<String>());
      expect(json['end_date'], isA<String>());
    });
  });
}
