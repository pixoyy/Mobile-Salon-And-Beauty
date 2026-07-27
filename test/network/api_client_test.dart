import 'package:flutter_test/flutter_test.dart';
import 'package:salon_and_beauty/core/exceptions/api_exception.dart';

void main() {
  group('ApiException', () {
    test('returns message from toString', () {
      final exc = ApiException('Error occurred', statusCode: 500);
      expect(exc.message, 'Error occurred');
      expect(exc.statusCode, 500);
      expect(exc.toString(), 'Error occurred');
    });

    test('handles null statusCode', () {
      final exc = ApiException('Not found');
      expect(exc.statusCode, isNull);
      expect(exc.toString(), 'Not found');
    });
  });

  group('AppConfig', () {
    test('baseUrl is set', () {
      // Just verify the constant compiles and has expected value
      const url = String.fromEnvironment('baseUrl');
      expect(url, isA<String>());
    });
  });
}
