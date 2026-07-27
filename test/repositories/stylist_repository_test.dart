import 'package:flutter_test/flutter_test.dart';
import 'package:salon_and_beauty/Models/StylistModel.dart';

void main() {
  group('StylistRepository parser', () {
    test('_parseList transforms API response to models', () {
      final jsonList = [
        {
          'id': '1',
          'name': 'Stylist A',
          'specialization': 'Hair',
          'rating': 4.5,
          'review_count': 10,
          'experience_years': 3,
          'photo_url': 'http://example.com/a.jpg',
          'skills': ['Cut', 'Color'],
          'bio': 'Expert',
          'reviews': [],
        },
        {
          'id': '2',
          'name': 'Stylist B',
          'specialization': 'Makeup',
          'rating': 4.0,
          'review_count': 5,
          'experience_years': 2,
          'photo_url': 'http://example.com/b.jpg',
          'skills': ['Bridal'],
          'bio': 'Makeup artist',
          'reviews': [],
        },
      ];

      final stylists = (jsonList as List)
          .map((j) => StylistModel.fromJson(j))
          .toList();

      expect(stylists.length, 2);
      expect(stylists[0].name, 'Stylist A');
      expect(stylists[1].name, 'Stylist B');
    });
  });
}
