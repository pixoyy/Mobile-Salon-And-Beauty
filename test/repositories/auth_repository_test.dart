import 'package:flutter_test/flutter_test.dart';
import 'package:salon_and_beauty/Models/LoginResult.dart';
import 'package:salon_and_beauty/Models/RegisterResult.dart';
import 'package:salon_and_beauty/Models/UserModel.dart';

void main() {
  group('LoginResult', () {
    test('success creates login result with user and token', () {
      final result = LoginResult.success(
        user: const UserModel(
          id: '1',
          name: 'Test',
          email: 'test@test.com',
          phone: '081234567890',
        ),
        token: 'abc123',
      );

      expect(result.isSuccess, true);
      expect(result.user?.name, 'Test');
      expect(result.token, 'abc123');
      expect(result.error, isNull);
    });

    test('failure creates login result with error message', () {
      final result = LoginResult.failure(message: 'Invalid credentials');

      expect(result.isSuccess, false);
      expect(result.error, 'Invalid credentials');
      expect(result.user, isNull);
      expect(result.token, isNull);
    });
  });

  group('RegisterResult', () {
    test('success', () {
      final result = RegisterResult.success();
      expect(result.isSuccess, true);
      expect(result.error, isNull);
    });

    test('failure with message', () {
      final result = RegisterResult.failure('Email already taken');
      expect(result.isSuccess, false);
      expect(result.error, 'Email already taken');
    });
  });
}
