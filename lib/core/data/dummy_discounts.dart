import '../models/discount.dart';

class DummyDiscounts {
  DummyDiscounts._();

  static final List<Discount> data = <Discount>[
    Discount(
      code: 'WEDDING50',
      title: 'Wedding Season Special',
      percent: 50,
      maxAmount: 200000,
      minSpend: 600000,
      startDate: DateTime(2026, 5, 1),
      endDate: DateTime(2026, 5, 31),
    ),
    Discount(
      code: 'SAVE20K',
      title: 'Save More on Your Beauty Session',
      percent: 20,
      maxAmount: 50000,
      minSpend: 100000,
      startDate: DateTime(2026, 5, 1),
      endDate: DateTime(2026, 5, 31),
    ),
    Discount(
      code: 'SPEND150',
      title: 'Special Treat for Minimum Spend',
      percent: 30,
      maxAmount: 75000,
      minSpend: 150000,
      startDate: DateTime(2026, 6, 1),
      endDate: DateTime(2026, 6, 30),
    ),
    Discount(
      code: 'BEAUTYDEAL',
      title: 'Glow Up & Save More',
      percent: 15,
      maxAmount: 30000,
      minSpend: 90000,
      startDate: DateTime(2026, 7, 1),
      endDate: DateTime(2026, 7, 31),
    ),
    Discount(
      code: 'BIGSAVE35',
      title: 'Bigger Spend, Bigger Discount',
      percent: 35,
      maxAmount: 85000,
      minSpend: 200000,
      startDate: DateTime(2026, 10, 1),
      endDate: DateTime(2026, 10, 31),
    ),
    Discount(
      code: 'LUXE50',
      title: 'Luxury Beauty Deals Await',
      percent: 50,
      maxAmount: 200000,
      minSpend: 500000,
      startDate: DateTime(2026, 11, 1),
      endDate: DateTime(2026, 11, 30),
    ),
  ];
}