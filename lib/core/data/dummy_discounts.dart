import '../models/discount.dart';

class DummyDiscounts {
  DummyDiscounts._();

  static final List<Discount> data = <Discount>[
    Discount(
      code: 'GLAMORA20',
      title: 'All Hair Treatment',
      percent: 20,
      maxAmount: 50000,
      minSpend: 100000,
      startDate: DateTime(2026, 5, 1),
      endDate: DateTime(2026, 5, 31),
    ),
    Discount(
      code: 'NAIL30',
      title: 'Nail Art & Spa',
      percent: 30,
      maxAmount: 75000,
      minSpend: 150000,
      startDate: DateTime(2026, 6, 1),
      endDate: DateTime(2026, 6, 30),
    ),
    Discount(
      code: 'FACIAL15',
      title: 'Premium Facial',
      percent: 15,
      maxAmount: 30000,
      minSpend: 90000,
      startDate: DateTime(2026, 7, 1),
      endDate: DateTime(2026, 7, 31),
    ),
    Discount(
      code: 'KERATIN35',
      title: 'Keratin Smooth Hair',
      percent: 35,
      maxAmount: 85000,
      minSpend: 200000,
      startDate: DateTime(2026, 10, 1),
      endDate: DateTime(2026, 10, 31),
    ),
    Discount(
      code: 'WEDDING50',
      title: 'Wedding Package',
      percent: 50,
      maxAmount: 200000,
      minSpend: 500000,
      startDate: DateTime(2026, 11, 1),
      endDate: DateTime(2026, 11, 30),
    ),
  ];
}