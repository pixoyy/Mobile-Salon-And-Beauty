import 'package:flutter_test/flutter_test.dart';
import 'package:salon_and_beauty/Models/StylistModel.dart';

void main() {
  group('StylistModel.fromJson', () {
    test('parses full stylist data', () {
      final json = {
        'id': '1',
        'name': 'Nadia Putri',
        'specialization': 'Hair Stylist',
        'rating': 4.8,
        'review_count': 120,
        'experience_years': 5,
        'photo_url': 'http://localhost/photos/nadia.jpg',
        'skills': ['Haircut', 'Hair Coloring'],
        'bio': 'Expert hair stylist',
        'reviews': [
          {
            'id': 'r1',
            'customer_name': 'Anna',
            'rating': 5.0,
            'comment': 'Great service!',
            'created_at': '2025-01-15T10:00:00Z',
          },
        ],
      };

      final stylist = StylistModel.fromJson(json);

      expect(stylist.id, '1');
      expect(stylist.name, 'Nadia Putri');
      expect(stylist.rating, 4.8);
      expect(stylist.reviewCount, 120);
      expect(stylist.experienceYears, 5);
      expect(stylist.photoUrl, 'http://localhost/photos/nadia.jpg');
      expect(stylist.skills, ['Haircut', 'Hair Coloring']);
      expect(stylist.reviews.length, 1);
      expect(stylist.reviews.first.customerName, 'Anna');
      expect(stylist.reviews.first.rating, 5.0);
      expect(stylist.reviews.first.comment, 'Great service!');
    });

    test('handles empty reviews and skills', () {
      final json = {
        'id': '2',
        'name': 'Minimal Stylist',
        'specialization': 'Makeup Artist',
        'rating': 4.0,
        'review_count': 0,
        'experience_years': 2,
        'photo_url': '',
        'skills': [],
        'bio': '',
        'reviews': [],
      };

      final stylist = StylistModel.fromJson(json);

      expect(stylist.skills, isEmpty);
      expect(stylist.reviews, isEmpty);
      expect(stylist.photoUrl, '');
    });
  });

  group('StylistReview.fromJson', () {
    test('parses review with snake_case', () {
      final json = {
        'id': 'r1',
        'customer_name': 'Budi',
        'rating': 4.5,
        'comment': 'Good',
        'created_at': '2025-03-01T08:00:00Z',
      };

      final review = StylistReview.fromJson(json);

      expect(review.customerName, 'Budi');
      expect(review.rating, 4.5);
      expect(review.comment, 'Good');
    });
  });
}
