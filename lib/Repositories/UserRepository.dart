import 'package:dio/dio.dart';
import 'package:salon_and_beauty/Models/UserModel.dart';
import 'package:salon_and_beauty/Support/AuthSession.dart';
import 'package:salon_and_beauty/core/network/api_client.dart';

class UserRepository {
  Future<UserModel> getProfile() async {
    final response = await ApiClient().get('/user/profile');
    return UserModel.fromJson(response.data['data']);
  }

  Future<UserModel> updateProfile({
    required String name,
    required String email,
    required String phone,
    String? avatarPath,
  }) async {
    final formData = FormData.fromMap({
      '_method': 'PUT',
      'name': name,
      'email': email,
      'phone': phone,
      if (avatarPath != null)
        'avatar': await MultipartFile.fromFile(avatarPath),
    });
    final response = await ApiClient().post('/user/profile', data: formData);
    return UserModel.fromJson(response.data['data']);
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    await ApiClient().post('/user/change-password', data: {
      'old_password': oldPassword,
      'new_password': newPassword,
      'new_password_confirmation': newPasswordConfirmation,
    });
  }
}
