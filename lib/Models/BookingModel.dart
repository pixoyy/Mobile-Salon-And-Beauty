enum BookingStatus { upcoming, onGoing, completed, cancelled }

extension BookingStatusX on BookingStatus {
  String get value {
    switch (this) {
      case BookingStatus.upcoming:
        return 'upcoming';
      case BookingStatus.onGoing:
        return 'on_going';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.cancelled:
        return 'cancelled';
    }
  }

  static BookingStatus fromValue(String value) {
    switch (value.toLowerCase()) {
      case 'on_going':
      case 'ongoing':
        return BookingStatus.onGoing;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'upcoming':
      default:
        return BookingStatus.upcoming;
    }
  }
}

class BookingModel {
  BookingModel({
    required this.id,
    required this.customerId,
    required this.stylistId,
    required this.serviceIds,
    DateTime? bookingDate,
    String? bookingTime,
    DateTime? bookingDateTime,
    String? notes,
    int? subtotal,
    int? discount,
    int? totalPrice,
    required this.status,
    DateTime? createdAt,
    String? note,
  })  : assert(
          (bookingDate != null && bookingTime != null) || bookingDateTime != null,
          'Either bookingDate + bookingTime or bookingDateTime must be provided.',
        ),
        bookingDate = bookingDate ?? _dateOnly(bookingDateTime!),
        bookingTime = bookingTime ?? _formatTime(bookingDateTime!),
        notes = notes ?? note,
        subtotal = subtotal ?? totalPrice ?? 0,
        discount = discount ?? 0,
        totalPrice = totalPrice ?? ((subtotal ?? 0) - (discount ?? 0)),
        createdAt = createdAt ?? bookingDateTime ?? bookingDate ?? DateTime(1970);

  final String id;
  final String customerId;
  final String stylistId;
  final List<String> serviceIds;
  final DateTime bookingDate;
  final String bookingTime;
  final String? notes;
  final int subtotal;
  final int discount;
  final int totalPrice;
  final BookingStatus status;
  final DateTime createdAt;

  String get bookingCode {
    final String yearMonth = '${bookingDate.year}${bookingDate.month.toString().padLeft(2, '0')}';
    final String suffix = _bookingCodeSuffix(id);
    return 'BK-$yearMonth-$suffix';
  }

  DateTime get bookingDateTime => _mergeDateAndTime(bookingDate, bookingTime);

  String? get note => notes;

  BookingModel copyWith({
    String? id,
    String? customerId,
    String? stylistId,
    List<String>? serviceIds,
    DateTime? bookingDate,
    String? bookingTime,
    String? notes,
    int? subtotal,
    int? discount,
    DateTime? bookingDateTime,
    int? totalPrice,
    BookingStatus? status,
    String? note,
    DateTime? createdAt,
  }) {
    final resolvedDate = bookingDate ?? (bookingDateTime != null ? _dateOnly(bookingDateTime) : this.bookingDate);
    final resolvedTime = bookingTime ?? (bookingDateTime != null ? _formatTime(bookingDateTime) : this.bookingTime);
    final resolvedNotes = notes ?? note ?? this.notes;

    return BookingModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      stylistId: stylistId ?? this.stylistId,
      serviceIds: serviceIds ?? this.serviceIds,
      bookingDate: resolvedDate,
      bookingTime: resolvedTime,
      notes: resolvedNotes,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'stylistId': stylistId,
      'serviceIds': serviceIds,
      'bookingDate': _toIsoDate(bookingDate),
      'bookingTime': bookingTime,
      'subtotal': subtotal,
      'discount': discount,
      'totalPrice': totalPrice,
      'status': status.value,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawServiceIds = json['serviceIds'] ?? const <dynamic>[];
    final DateTime? parsedDateTime = _tryParseDateTime(
      json['bookingDateTime']?.toString(),
    );

    return BookingModel(
      id: json['id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      stylistId: json['stylistId']?.toString() ?? '',
      serviceIds: rawServiceIds is List
          ? rawServiceIds.map((item) => item.toString()).toList()
          : const <String>[],
      bookingDate: _tryParseDate(json['bookingDate']?.toString()) ??
          (parsedDateTime != null ? _dateOnly(parsedDateTime) : DateTime(1970)),
      bookingTime: json['bookingTime']?.toString() ??
          (parsedDateTime != null ? _formatTime(parsedDateTime) : '00:00'),
      notes: json['notes']?.toString() ?? json['note']?.toString(),
      subtotal: _toInt(json['subtotal']) ?? _toInt(json['totalPrice']) ?? 0,
      discount: _toInt(json['discount']) ?? 0,
      totalPrice: _toInt(json['totalPrice']),
      status: BookingStatusX.fromValue(
        json['status']?.toString() ?? BookingStatus.upcoming.value,
      ),
      createdAt: _tryParseDateTime(json['createdAt']?.toString()) ??
          parsedDateTime ??
          DateTime(1970),
    );
  }

  static DateTime _dateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  static String _formatTime(DateTime dateTime) {
    final String hour = dateTime.hour.toString().padLeft(2, '0');
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static DateTime _mergeDateAndTime(DateTime date, String time) {
    final List<String> parts = time.split(':');
    final int hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final int minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  static String _toIsoDate(DateTime date) {
    final String year = date.year.toString().padLeft(4, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static DateTime? _tryParseDate(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final DateTime? dateTime = DateTime.tryParse(raw);
    if (dateTime == null) {
      return null;
    }
    return _dateOnly(dateTime);
  }

  static DateTime? _tryParseDateTime(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  static int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static String _bookingCodeSuffix(String bookingId) {
    final RegExp digits = RegExp(r'\d+');
    final Match? match = digits.allMatches(bookingId).lastOrNull;
    if (match != null) {
      return match.group(0)!.padLeft(3, '0').substring(match.group(0)!.length >= 3 ? match.group(0)!.length - 3 : 0);
    }

    final int hash = bookingId.hashCode.abs() % 1000;
    return hash.toString().padLeft(3, '0');
  }
}
