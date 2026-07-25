import 'package:salon_and_beauty/Models/BookingModel.dart';
import 'package:salon_and_beauty/core/network/api_client.dart';

class BookingRepository {
  Future<List<BookingModel>> getAllBookings({
    String? status,
    String? dateFrom,
    String? dateTo,
  }) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;
    if (dateFrom != null) params['date_from'] = dateFrom;
    if (dateTo != null) params['date_to'] = dateTo;
    final response = await ApiClient().get('/bookings', params: params);
    return _parseList(response.data['data']);
  }

  Future<BookingModel> getBookingById(String id) async {
    final response = await ApiClient().get('/bookings/$id');
    return BookingModel.fromJson(response.data['data']);
  }

  Future<BookingModel> createBooking({
    required String stylistId,
    required List<String> serviceIds,
    required String bookingDate,
    required String bookingTime,
    String? notes,
    required int subtotal,
    int discountAmount = 0,
    required int totalPrice,
    String? discountCode,
  }) async {
    final data = <String, dynamic>{
      'stylist_id': stylistId,
      'service_ids': serviceIds,
      'booking_date': bookingDate,
      'booking_time': bookingTime,
      'notes': notes,
      'subtotal': subtotal,
      'discount_amount': discountAmount,
      'total_price': totalPrice,
    };
    if (discountCode != null) {
      data['discount_code'] = discountCode;
    }
    final response = await ApiClient().post('/bookings', data: data);
    return BookingModel.fromJson(response.data['data']);
  }

  Future<BookingModel> updateBooking(
    String id, {
    String? stylistId,
    List<String>? serviceIds,
    String? bookingDate,
    String? bookingTime,
    String? notes,
    int? subtotal,
    int? discountAmount,
    int? totalPrice,
  }) async {
    final data = <String, dynamic>{};
    if (stylistId != null) data['stylist_id'] = stylistId;
    if (serviceIds != null) data['service_ids'] = serviceIds;
    if (bookingDate != null) data['booking_date'] = bookingDate;
    if (bookingTime != null) data['booking_time'] = bookingTime;
    if (notes != null) data['notes'] = notes;
    if (subtotal != null) data['subtotal'] = subtotal;
    if (discountAmount != null) data['discount_amount'] = discountAmount;
    if (totalPrice != null) data['total_price'] = totalPrice;
    final response = await ApiClient().put('/bookings/$id', data: data);
    return BookingModel.fromJson(response.data['data']);
  }

  Future<BookingModel> cancelBooking(String id, {String? reason}) async {
    final data = <String, dynamic>{};
    if (reason != null) data['reason'] = reason;
    final response = await ApiClient().patch('/bookings/$id/cancel', data: data);
    return BookingModel.fromJson(response.data['data']);
  }

  Future<List<String>> getAvailableSlots(
    String stylistId,
    String date, {
    List<String>? serviceIds,
  }) async {
    final params = <String, dynamic>{
      'stylist_id': stylistId,
      'date': date,
    };
    if (serviceIds != null && serviceIds.isNotEmpty) {
      params['service_ids[]'] = serviceIds;
    }
    final response = await ApiClient().get('/bookings/available-slots', params: params);
    final data = response.data['data'] as Map<String, dynamic>;
    final slots = data['slots'] as List;
    return slots
        .where((e) => (e as Map<String, dynamic>)['available'] == true)
        .map((e) => e['time'] as String)
        .toList();
  }

  Future<bool> checkAvailability(
    String stylistId,
    String date,
    String time,
    List<String> serviceIds,
  ) async {
    final response = await ApiClient().get('/bookings/check-availability', params: {
      'stylist_id': stylistId,
      'date': date,
      'time': time,
      'service_ids[]': serviceIds,
    });
    final data = response.data['data'] as Map<String, dynamic>;
    return data['available'] == true;
  }

  List<BookingModel> _parseList(dynamic data) {
    return (data as List).map((j) => BookingModel.fromJson(j)).toList();
  }
}
