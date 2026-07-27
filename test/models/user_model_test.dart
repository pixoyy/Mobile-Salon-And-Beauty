import 'package:flutter_test/flutter_test.dart';
import 'package:salon_and_beauty/Models/UserModel.dart';

void main() {
  group('UserModel.fromJson', () {
    test('parses full user data', () {
      final json = {
        'id': 1,
        'name': 'Test User',
        'email': 'test@example.com',
        'phone': '081234567890',
        'image_url': 'http://localhost/storage/avatars/test.jpg',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, '1');
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.phone, '081234567890');
      expect(user.imageUrl, 'http://localhost/storage/avatars/test.jpg');
      expect(user.password, isNull);
    });

    test('handles missing optional fields', () {
      final json = {
        'id': '2',
        'name': 'Minimal User',
        'email': 'minimal@example.com',
        'phone': '081200000000',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, '2');
      expect(user.name, 'Minimal User');
      expect(user.imageUrl, isNull);
    });

    test('toJson produces snake_case', () {
      final user = UserModel(
        id: '3',
        name: 'ToJson Test',
        email: 'tojson@example.com',
        phone: '081200000001',
        imageUrl: 'http://localhost/img.jpg',
      );

      final json = user.toJson();

      expect(json['id'], '3');
      expect(json['image_url'], 'http://localhost/img.jpg');
      expect(json.containsKey('password'), false);
    });
  });
}
