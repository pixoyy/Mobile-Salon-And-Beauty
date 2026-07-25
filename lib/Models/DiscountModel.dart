class Discount {
  final String code;
  final String title;
  final int percent;
  final int maxAmount;
  final int minSpend;
  final DateTime startDate;
  final DateTime endDate;

  Discount({
    required this.code,
    required this.title,
    required this.percent,
    required this.maxAmount,
    required this.minSpend,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'title': title,
      'percent': percent,
      'maxAmount': maxAmount,
      'minSpend': minSpend,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'title': title,
      'percent': percent,
      'max_amount': maxAmount,
      'min_spend': minSpend,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }

  factory Discount.fromMap(Map<String, dynamic> map) {
    return Discount(
      code: map['code']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      percent: _toInt(map['percent']),
      maxAmount: _toInt(map['maxAmount']),
      minSpend: _toInt(map['minSpend']),
      startDate: _toDateTime(map['startDate']),
      endDate: _toDateTime(map['endDate']),
    );
  }

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      code: json['code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      percent: _toInt(json['percent']),
      maxAmount: _toInt(json['max_amount']),
      minSpend: _toInt(json['min_spend']),
      startDate: _toDateTime(json['start_date']),
      endDate: _toDateTime(json['end_date']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      final d = double.tryParse(value);
      if (d != null) return d.round();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is DateTime) return value;
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    return parsed ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
}
