import 'package:flutter_test/flutter_test.dart';

import 'package:salon_and_beauty/features/booking/domain/booking_rules_service.dart';

void main() {
  test('highlighted slots start after the selected slot', () {
    const List<String> allSlots = <String>[
      '08:00',
      '09:00',
      '10:00',
      '11:00',
      '12:00',
      '13:00',
      '14:00',
      '15:00',
      '16:00',
      '17:00',
      '18:00',
      '19:00',
      '20:00',
    ];

    final List<String> highlighted = BookingRulesService.highlightedSlots(
      allSlots: allSlots,
      selectedTime: '17:00',
      totalDurationMinutes: 210,
    );

    expect(highlighted, <String>['18:00', '19:00', '20:00']);
  });
}
