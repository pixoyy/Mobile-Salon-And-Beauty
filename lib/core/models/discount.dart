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

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is DateTime) return value;
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    return parsed ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
}
