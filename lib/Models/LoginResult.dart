import 'package:salon_and_beauty/Models/UserModel.dart';

class LoginResult {
  const LoginResult({
    required this.isSuccess,
    this.user,
    this.token,
    this.error,
  });

  final bool isSuccess;
  final UserModel? user;
  final String? token;
  final String? error;

  factory LoginResult.success({
    required UserModel user,
    required String token,
  }) {
    return LoginResult(
      isSuccess: true,
      user: user,
      token: token,
    );
  }

  factory LoginResult.failure({required String message}) {
    return LoginResult(
      isSuccess: false,
      error: message,
    );
  }
}
