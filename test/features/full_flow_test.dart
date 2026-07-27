import 'package:flutter_test/flutter_test.dart';
import 'package:salon_and_beauty/Models/BookingModel.dart';
import 'package:salon_and_beauty/Models/LoginResult.dart';
import 'package:salon_and_beauty/Models/RegisterResult.dart';
import 'package:salon_and_beauty/Models/ServiceModel.dart';
import 'package:salon_and_beauty/Models/StylistModel.dart';
import 'package:salon_and_beauty/Models/UserModel.dart';

void main() {
  group('Full Flow — Model Parsing', () {
    test('login response parsing', () {
      final json = {
        'data': {
          'user': {
            'id': 1,
            'name': 'Customer',
            'email': 'customer@test.com',
            'phone': '081234567890',
            'image_url': null,
          },
          'token': 'token-abc-123',
        },
      };

      final data = json['data'];
      final user = UserModel.fromJson(data['user']);
      final token = data['token'] as String;

      expect(user.name, 'Customer');
      expect(token, 'token-abc-123');
    });

    test('register response parsing', () {
      final result = RegisterResult.success();
      expect(result.isSuccess, true);
    });

    test('stylist list response parsing', () {
      final json = {
        'data': [
          {
            'id': 's1',
            'name': 'Stylist 1',
            'specialization': 'Hair',
            'rating': 4.5,
            'review_count': 10,
            'experience_years': 3,
            'photo_url': '',
            'skills': ['Cut'],
            'bio': '',
            'reviews': [],
          },
        ],
      };

      final stylists = (json['data'] as List)
          .map((j) => StylistModel.fromJson(j))
          .toList();

      expect(stylists.length, 1);
    });

    test('service list response parsing', () {
      final json = {
        'data': [
          {
            'id': 'svc1',
            'name': 'Haircut',
            'category': 'Hair',
            'description': 'Basic cut',
            'duration_minutes': 60,
            'price': 50000,
            'is_popular': true,
          },
        ],
      };

      final services = (json['data'] as List)
          .map((j) => ServiceModel.fromJson(j))
          .toList();

      expect(services.length, 1);
      expect(services.first.price, 50000);
    });

    test('booking create response parsing', () {
      final json = {
        'data': {
          'id': 'bk-1',
          'status': 'upcoming',
          'booking_date': '2025-08-01',
          'booking_time': '10:00',
          'stylist': {'id': 's1'},
          'items': [{'service_id': 'svc1'}],
          'subtotal': 50000,
          'discount_amount': 0,
          'total_price': 50000,
          'created_at': '2025-07-28T10:00:00Z',
        },
      };

      final booking = BookingModel.fromJson(json['data']);

      expect(booking.id, 'bk-1');
      expect(booking.status, BookingStatus.upcoming);
      expect(booking.totalPrice, 50000);
    });
  });
}
