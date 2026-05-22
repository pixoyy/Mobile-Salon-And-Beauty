// import 'package:salon_and_beauty/features/user/data/user_model.dart';

// import 'package:salon_and_beauty/core/session/auth_session.dart';

// class UserRepository {
//   Future<UserModel> getProfile() async {
//     await Future.delayed(const Duration(milliseconds: 300));

//     final user = AuthSession.currentUser;

//     if (user == null) {
//       throw Exception('User belum login');
//     }

//     return user;
//   }

//   Future<UserModel> updateProfile(UserModel newUser) async {
//     await Future.delayed(const Duration(milliseconds: 300));

//     AuthSession.currentUser = newUser;

//     return newUser;
//   }

//   Future<void> changePassword({
//     required String oldPassword,
//     required String newPassword,
//   }) async {
//     await Future.delayed(const Duration(seconds: 1));

//     final current = AuthSession.currentUser;

//     if (current == null) {
//       throw Exception('User belum login');
//     }

//     if (current.password != oldPassword) {
//       throw Exception('Password lama tidak sesuai');
//     }

//     AuthSession.currentUser = current.copyWith(password: newPassword);
//   }
// }

import 'package:salon_and_beauty/core/session/auth_session.dart';
import 'package:salon_and_beauty/features/auth/data/auth_repository.dart';
import 'package:salon_and_beauty/features/user/data/user_model.dart';

class UserRepository {
  final AuthRepository _authRepository = AuthRepository();

  /// GET PROFILE
  Future<UserModel> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final user = AuthSession.currentUser;

    if (user == null) {
      throw Exception('User belum login');
    }

    return user;
  }

  /// UPDATE PROFILE
  Future<UserModel> updateProfile(UserModel newUser) async {
    await Future.delayed(const Duration(milliseconds: 300));

    /// UPDATE VIA AUTH REPOSITORY
    _authRepository.updateCurrentUser(newUser);

    return newUser;
  }

  /// CHANGE PASSWORD
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final success = _authRepository.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );

    if (!success) {
      throw Exception('Password lama tidak sesuai');
    }
  }
}
