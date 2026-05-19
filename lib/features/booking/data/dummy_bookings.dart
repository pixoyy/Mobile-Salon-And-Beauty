import 'booking_model.dart';

class DummyBookings {
  static final List<BookingModel> upcoming = [
    BookingModel(
      id: 'bk-001',
      customerId: 'cus-001',
      stylistId: 'sty-001',
      serviceIds: const ['svc-001', 'svc-005'],
      bookingDateTime: DateTime(2026, 5, 25, 10, 0),
      totalPrice: 270000,
      status: BookingStatus.pending,
      note: 'Ingin style natural untuk acara kantor.',
    ),
    BookingModel(
      id: 'bk-002',
      customerId: 'cus-001',
      stylistId: 'sty-003',
      serviceIds: const ['svc-006'],
      bookingDateTime: DateTime(2026, 5, 29, 13, 30),
      totalPrice: 390000,
      status: BookingStatus.confirmed,
    ),
  ];

  static final List<BookingModel> history = [
    BookingModel(
      id: 'bk-003',
      customerId: 'cus-001',
      stylistId: 'sty-002',
      serviceIds: const ['svc-002'],
      bookingDateTime: DateTime(2026, 5, 2, 15, 0),
      totalPrice: 135000,
      status: BookingStatus.completed,
    ),
    BookingModel(
      id: 'bk-004',
      customerId: 'cus-001',
      stylistId: 'sty-004',
      serviceIds: const ['svc-004'],
      bookingDateTime: DateTime(2026, 4, 14, 9, 30),
      totalPrice: 650000,
      status: BookingStatus.completed,
    ),
    BookingModel(
      id: 'bk-005',
      customerId: 'cus-001',
      stylistId: 'sty-005',
      serviceIds: const ['svc-001'],
      bookingDateTime: DateTime(2026, 3, 20, 16, 0),
      totalPrice: 95000,
      status: BookingStatus.cancelled,
      note: 'Reschedule karena bentrok agenda.',
    ),
  ];
}
