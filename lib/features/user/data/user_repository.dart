import 'package:salon_and_beauty/features/user/data/user_model.dart';

import 'package:salon_and_beauty/core/session/auth_session.dart';

class UserRepository {
  Future<UserModel> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final user = AuthSession.currentUser;

    if (user == null) {
      throw Exception('User belum login');
    }

    return user;
  }

  Future<UserModel> updateProfile(UserModel newUser) async {
    await Future.delayed(const Duration(milliseconds: 300));

    AuthSession.currentUser = newUser;

    return newUser;
  }
}