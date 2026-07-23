import 'package:flutter_test/flutter_test.dart';
import 'package:salon_and_beauty/Models/ServiceModel.dart';

void main() {
  group('ServiceModel.fromJson', () {
    test('parses service with snake_case', () {
      final json = {
        'id': '1',
        'name': 'Haircut',
        'category': 'Hair',
        'description': 'Basic haircut',
        'duration_minutes': 60,
        'price': 50000,
        'is_popular': true,
      };

      final service = ServiceModel.fromJson(json);

      expect(service.id, '1');
      expect(service.name, 'Haircut');
      expect(service.category, 'Hair');
      expect(service.durationMinutes, 60);
      expect(service.price, 50000);
      expect(service.isPopular, true);
    });

    test('handles non-popular service', () {
      final json = {
        'id': '2',
        'name': 'Facial',
        'category': 'Skincare',
        'description': 'Basic facial',
        'duration_minutes': 90,
        'price': 100000,
        'is_popular': false,
      };

      final service = ServiceModel.fromJson(json);

      expect(service.isPopular, false);
    });

    test('toJson produces snake_case', () {
      final service = ServiceModel(
        id: '3',
        name: 'Hair Spa',
        category: 'Hair',
        description: 'Luxury hair treatment',
        durationMinutes: 120,
        price: 150000,
        isPopular: true,
      );

      final json = service.toJson();

      expect(json['duration_minutes'], 120);
      expect(json['is_popular'], true);
    });
  });
}
