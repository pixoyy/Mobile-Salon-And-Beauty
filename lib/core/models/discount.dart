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
}
