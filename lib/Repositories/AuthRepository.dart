import 'package:dio/dio.dart';
import 'package:salon_and_beauty/Models/LoginResult.dart';
import 'package:salon_and_beauty/Models/RegisterResult.dart';
import 'package:salon_and_beauty/Models/UserModel.dart';
import 'package:salon_and_beauty/Support/AuthSession.dart';
import 'package:salon_and_beauty/core/network/api_client.dart';

class AuthRepository {
  Future<LoginResult> validateLogin({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await ApiClient().post('/auth/login', data: {
        'identifier': identifier,
        'password': password,
      });
      final data = response.data['data'];
      final user = UserModel.fromJson(data['user']);
      final token = data['token'] as String;
      return LoginResult.success(user: user, token: token);
    } on DioException catch (e) {
      final message = e.response?.data['message'] as String? ?? 'Login gagal';
      return LoginResult.failure(message: message);
    }
  }

  Future<RegisterResult> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    if (name.trim().isEmpty) {
      return RegisterResult.failure('Nama tidak boleh kosong');
    }
    if (email.trim().isEmpty) {
      return RegisterResult.failure('Email tidak boleh kosong');
    }
    if (phone.trim().isEmpty) {
      return RegisterResult.failure('Nomor telepon tidak boleh kosong');
    }
    if (password.trim().length < 6) {
      return RegisterResult.failure('Password minimal 6 karakter');
    }

    try {
      await ApiClient().post('/auth/register', data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      });
      return RegisterResult.success();
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = data?['message'] as String? ?? 'Registrasi gagal';
      final errors = data?['errors'] as Map<String, dynamic>?;
      if (errors != null) {
        final messages = errors.values.expand((e) => e is List ? e : [e]).join('\n');
        return RegisterResult.failure(messages);
      }
      return RegisterResult.failure(message);
    }
  }

  Future<void> logout() async {
    try {
      await ApiClient().post('/auth/logout');
    } catch (_) {}
    await AuthSession.clearSession();
  }
}
