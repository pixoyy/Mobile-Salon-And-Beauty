import 'package:salon_and_beauty/Models/DiscountModel.dart';

class DummyDiscounts {
  static List<Discount> get data => <Discount>[
        Discount(
          code: 'WEDDING50',
          title: 'Diskon Pernikahan',
          percent: 50,
          maxAmount: 200000,
          minSpend: 600000,
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 11, 30),
        ),
        Discount(
          code: 'SAVE20K',
          title: 'Hemat 20%',
          percent: 20,
          maxAmount: 50000,
          minSpend: 100000,
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 11, 30),
        ),
        Discount(
          code: 'SPEND150',
          title: 'Diskon Belanja',
          percent: 30,
          maxAmount: 75000,
          minSpend: 150000,
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 11, 30),
        ),
        Discount(
          code: 'BEAUTYDEAL',
          title: 'Deal Cantik',
          percent: 15,
          maxAmount: 30000,
          minSpend: 90000,
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 11, 30),
        ),
        Discount(
          code: 'BIGSAVE35',
          title: 'Hemat Besar',
          percent: 35,
          maxAmount: 85000,
          minSpend: 200000,
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 11, 30),
        ),
        Discount(
          code: 'LUXE50',
          title: 'Luxury Deal',
          percent: 50,
          maxAmount: 200000,
          minSpend: 500000,
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 11, 30),
        ),
      ];
}
