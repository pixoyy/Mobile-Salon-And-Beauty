import 'package:flutter_test/flutter_test.dart';

import 'package:salon_and_beauty/core/data/dummy_discounts.dart';
import 'package:salon_and_beauty/core/models/discount.dart';
import 'package:salon_and_beauty/features/booking/domain/booking_pricing_service.dart';
import 'package:salon_and_beauty/features/service/data/service_model.dart';

const List<ServiceModel> _activePromoServices = <ServiceModel>[
  ServiceModel(
    id: 'svc-active-1',
    name: 'Active Promo A',
    category: 'Haircut',
    description: 'Test service A',
    durationMinutes: 60,
    price: 300000,
    isPopular: false,
  ),
  ServiceModel(
    id: 'svc-active-2',
    name: 'Active Promo B',
    category: 'Haircut',
    description: 'Test service B',
    durationMinutes: 60,
    price: 325000,
    isPopular: false,
  ),
];

const List<ServiceModel> _smallSpendServices = <ServiceModel>[
  ServiceModel(
    id: 'svc-small-1',
    name: 'Small Spend A',
    category: 'Haircut',
    description: 'Test service A',
    durationMinutes: 30,
    price: 40000,
    isPopular: false,
  ),
  ServiceModel(
    id: 'svc-small-2',
    name: 'Small Spend B',
    category: 'Haircut',
    description: 'Test service B',
    durationMinutes: 30,
    price: 30000,
    isPopular: false,
  ),
];

const List<ServiceModel> _noPromoServices = <ServiceModel>[
  ServiceModel(
    id: 'svc-no-promo-1',
    name: 'No Promo A',
    category: 'Treatment',
    description: 'Test service A',
    durationMinutes: 45,
    price: 45000,
    isPopular: false,
  ),
  ServiceModel(
    id: 'svc-no-promo-2',
    name: 'No Promo B',
    category: 'Treatment',
    description: 'Test service B',
    durationMinutes: 60,
    price: 30000,
    isPopular: false,
  ),
];

void main() {
  test('applies the active promo when min spend is met and cap is respected', () async {
    final PricingResult result = await BookingPricingService.calculate(
      _activePromoServices,
      bookingDate: DateTime(2026, 5, 20),
      discounts: DummyDiscounts.data,
    );

    expect(result.appliedDiscount?.code, 'WEDDING50');
    expect(result.payment.subtotal, 625000);
    expect(result.payment.discountAmount, 200000);
    expect(result.payment.totalPrice, 425000);
  });

  test('does not apply promo when minimum spend is not reached', () async {
    final PricingResult result = await BookingPricingService.calculate(
      _smallSpendServices,
      bookingDate: DateTime(2026, 5, 20),
      discounts: DummyDiscounts.data,
    );

    expect(result.appliedDiscount, isNull);
    expect(result.payment.subtotal, 70000);
    expect(result.payment.discountAmount, 0);
    expect(result.payment.totalPrice, 70000);
  });

  test('prefers the active discount with the closest min spend below subtotal', () async {
    final List<Discount> customDiscounts = <Discount>[
      Discount(
        code: 'LOW10',
        title: 'Low Spend',
        percent: 10,
        maxAmount: 50000,
        minSpend: 50000,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 12, 31),
      ),
      Discount(
        code: 'MID20',
        title: 'Mid Spend',
        percent: 20,
        maxAmount: 70000,
        minSpend: 150000,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 12, 31),
      ),
      Discount(
        code: 'HIGH30',
        title: 'High Spend',
        percent: 30,
        maxAmount: 100000,
        minSpend: 250000,
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 12, 31),
      ),
    ];

    final PricingResult result = await BookingPricingService.calculate(
      const <ServiceModel>[
        ServiceModel(
          id: 'svc-close-1',
          name: 'Close Selection',
          category: 'Haircare',
          description: 'Test service',
          durationMinutes: 90,
          price: 260000,
          isPopular: false,
        ),
      ],
      bookingDate: DateTime(2026, 6, 20),
      discounts: customDiscounts,
    );

    expect(result.appliedDiscount?.code, 'HIGH30');
    expect(result.payment.subtotal, 260000);
    expect(result.payment.discountAmount, 78000);
    expect(result.payment.totalPrice, 182000);
  });

  test('caps discount amount at maxAmount', () async {
    final Discount cappedDiscount = Discount(
      code: 'CAP50',
      title: 'Cap Test',
      percent: 50,
      maxAmount: 20000,
      minSpend: 1000,
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 12, 31),
    );

    final PricingResult result = await BookingPricingService.calculate(
      const <ServiceModel>[
        ServiceModel(
          id: 'svc-cap-1',
          name: 'Cap Service',
          category: 'Styling',
          description: 'Test service',
          durationMinutes: 60,
          price: 100000,
          isPopular: false,
        ),
      ],
      bookingDate: DateTime(2026, 6, 20),
      discounts: <Discount>[cappedDiscount],
    );

    expect(result.appliedDiscount?.code, 'CAP50');
    expect(result.payment.subtotal, 100000);
    expect(result.payment.discountAmount, 20000);
    expect(result.payment.totalPrice, 80000);
  });

  test('does not apply promo when no discount reaches minimum spend', () async {
    final PricingResult result = await BookingPricingService.calculate(
      _noPromoServices,
      bookingDate: DateTime(2026, 12, 20),
      discounts: DummyDiscounts.data,
    );

    expect(result.appliedDiscount, isNull);
    expect(result.payment.subtotal, 75000);
    expect(result.payment.discountAmount, 0);
    expect(result.payment.totalPrice, 75000);
  });
}