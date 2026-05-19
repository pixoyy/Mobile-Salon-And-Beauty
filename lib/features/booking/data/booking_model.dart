enum BookingStatus { pending, confirmed, completed, cancelled }

class BookingModel {
  const BookingModel({
    required this.id,
    required this.customerId,
    required this.stylistId,
    required this.serviceIds,
    required this.bookingDateTime,
    required this.totalPrice,
    required this.status,
    this.note,
  });

  final String id;
  final String customerId;
  final String stylistId;
  final List<String> serviceIds;
  final DateTime bookingDateTime;
  final int totalPrice;
  final BookingStatus status;
  final String? note;

  BookingModel copyWith({
    String? id,
    String? customerId,
    String? stylistId,
    List<String>? serviceIds,
    DateTime? bookingDateTime,
    int? totalPrice,
    BookingStatus? status,
    String? note,
  }) {
    return BookingModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      stylistId: stylistId ?? this.stylistId,
      serviceIds: serviceIds ?? this.serviceIds,
      bookingDateTime: bookingDateTime ?? this.bookingDateTime,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      note: note ?? this.note,
    );
  }
}
