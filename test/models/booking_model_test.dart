import 'package:flutter_test/flutter_test.dart';
import 'package:salon_and_beauty/Models/BookingModel.dart';

void main() {
  group('BookingModel.fromJson', () {
    test('parses booking with nested stylist and items', () {
      final json = {
        'id': 'bk-001',
        'status': 'upcoming',
        'booking_date': '2025-07-25',
        'booking_time': '10:00',
        'stylist': {'id': 's1'},
        'items': [
          {'service_id': 'svc1'},
          {'service_id': 'svc2'},
        ],
        'notes': 'Test booking',
        'subtotal': 100000,
        'discount_amount': 10000,
        'total_price': 90000,
        'created_at': '2025-07-20T08:00:00Z',
      };

      final booking = BookingModel.fromJson(json);

      expect(booking.id, 'bk-001');
      expect(booking.status, BookingStatus.upcoming);
      expect(booking.stylistId, 's1');
      expect(booking.serviceIds, ['svc1', 'svc2']);
      expect(booking.notes, 'Test booking');
      expect(booking.subtotal, 100000);
      expect(booking.discount, 10000);
      expect(booking.totalPrice, 90000);
      expect(booking.bookingDate.year, 2025);
      expect(booking.bookingDate.month, 7);
      expect(booking.bookingDate.day, 25);
      expect(booking.bookingTime, '10:00');
    });

    test('parses booking with camelCase fallback fields', () {
      final json = {
        'id': 'bk-002',
        'status': 'completed',
        'booking_date': '2025-07-20',
        'booking_time': '14:00',
        'stylist_id': 's2',
        'stylist': {'id': 's2'},
        'service_ids': ['svc1'],
        'subtotal': 50000,
        'totalPrice': 50000,
        'created_at': '2025-07-19T10:00:00Z',
      };

      final booking = BookingModel.fromJson(json);

      expect(booking.status, BookingStatus.completed);
      expect(booking.stylistId, 's2');
      expect(booking.serviceIds, ['svc1']);
    });

    test('parses cancelled booking', () {
      final json = {
        'id': 'bk-003',
        'status': 'cancelled',
        'booking_date': '2025-07-22',
        'booking_time': '09:00',
        'stylist': {'id': 's1'},
        'items': [{'service_id': 'svc1'}],
        'subtotal': 50000,
        'discount_amount': 0,
        'total_price': 50000,
        'created_at': '2025-07-21T10:00:00Z',
      };

      final booking = BookingModel.fromJson(json);

      expect(booking.status, BookingStatus.cancelled);
    });
  });
}
