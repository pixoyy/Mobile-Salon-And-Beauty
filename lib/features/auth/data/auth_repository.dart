// import 'package:salon_and_beauty/features/user/data/dummy_user.dart';
// import 'package:salon_and_beauty/features/user/data/user_model.dart';

// import 'register_result.dart';

// class AuthRepository {
//   static final AuthRepository _instance = AuthRepository._internal();

//   factory AuthRepository() {
//     return _instance;
//   }

//   AuthRepository._internal() {
//     _initializeDummyUser();
//   }

//   final List<UserModel> _registeredUsers = [];

//   void _initializeDummyUser() {
//     _registeredUsers.add(DummyUser.activeCustomer);
//   }

//   UserModel? validateLogin({
//     required String identifier,
//     required String password,
//   }) {
//     if (identifier.trim().isEmpty || password.trim().length < 6) {
//       return null;
//     }

//     try {
//       final user = _registeredUsers.firstWhere(
//         (u) =>
//             (u.email == identifier || u.name == identifier) &&
//             u.password == password,
//       );
//       return user;
//     } catch (e) {
//       return null;
//     }
//   }

//   RegisterResult register({
//     required String name,
//     required String email,
//     required String password,
//     required String phone,
//   }) {
//     if (name.trim().isEmpty) {
//       return RegisterResult.failure('Nama tidak boleh kosong');
//     }

//     if (email.trim().isEmpty) {
//       return RegisterResult.failure('Email tidak boleh kosong');
//     }

//     if (phone.trim().isEmpty) {
//       return RegisterResult.failure('Nomor telepon tidak boleh kosong');
//     }

//     if (password.trim().length < 6) {
//       return RegisterResult.failure('Password minimal 6 karakter');
//     }

//     final emailExists = _registeredUsers.any((u) => u.email == email);
//     if (emailExists) {
//       return RegisterResult.failure('Email sudah terdaftar');
//     }
    
//     final phoneExists = _registeredUsers.any((u) => u.phone == phone);
//     if (phoneExists) {
//       return RegisterResult.failure('Nomor telepon sudah terdaftar');
//     }

//     final newUser = UserModel(
//       id: 'user_${DateTime.now().millisecondsSinceEpoch}',
//       name: name,
//       email: email,
//       phone: phone,
//       password: password,
//     );

//     _registeredUsers.add(newUser);
//     return RegisterResult.success();
//   }

//   String get demoCredentialHint =>
//       'Demo: siska.amanda@example.com / password123 atau daftar akun baru';
// }

import 'package:salon_and_beauty/core/session/auth_session.dart';
import 'package:salon_and_beauty/features/user/data/dummy_user.dart';
import 'package:salon_and_beauty/features/user/data/user_model.dart';

import 'register_result.dart';

class AuthRepository {
  static final AuthRepository _instance =
      AuthRepository._internal();

  factory AuthRepository() {
    return _instance;
  }

  AuthRepository._internal() {
    _initializeDummyUser();
  }

  final List<UserModel> _registeredUsers = [];

  void _initializeDummyUser() {
    if (_registeredUsers.isEmpty) {
      _registeredUsers.add(
        DummyUser.activeCustomer,
      );
    }
  }

  /// LOGIN
  UserModel? validateLogin({
    required String identifier,
    required String password,
  }) {
    if (
        identifier.trim().isEmpty ||
        password.trim().length < 6) {
      return null;
    }

    try {

      /// CARI USER
      final user = _registeredUsers.firstWhere(
        (u) =>
            (u.email == identifier ||
                u.name == identifier) &&
            u.password == password,
      );

      /// SIMPAN SESSION
      AuthSession.currentUser = user;

      return user;

    } catch (e) {

      return null;
    }
  }

  /// REGISTER
  RegisterResult register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) {

    if (name.trim().isEmpty) {
      return RegisterResult.failure(
        'Nama tidak boleh kosong',
      );
    }

    if (email.trim().isEmpty) {
      return RegisterResult.failure(
        'Email tidak boleh kosong',
      );
    }

    if (phone.trim().isEmpty) {
      return RegisterResult.failure(
        'Nomor telepon tidak boleh kosong',
      );
    }

    if (password.trim().length < 6) {
      return RegisterResult.failure(
        'Password minimal 6 karakter',
      );
    }

    final emailExists = _registeredUsers.any(
      (u) => u.email == email,
    );

    if (emailExists) {
      return RegisterResult.failure(
        'Email sudah terdaftar',
      );
    }

    final phoneExists = _registeredUsers.any(
      (u) => u.phone == phone,
    );

    if (phoneExists) {
      return RegisterResult.failure(
        'Nomor telepon sudah terdaftar',
      );
    }

    final newUser = UserModel(
      id:
          'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      password: password,
    );

    _registeredUsers.add(newUser);

    return RegisterResult.success();
  }

  /// UPDATE USER LOGIN SEKARANG
  void updateCurrentUser(UserModel updatedUser) {

    /// UPDATE SESSION
    AuthSession.currentUser = updatedUser;

    /// UPDATE LIST USER
    final index = _registeredUsers.indexWhere(
      (u) => u.id == updatedUser.id,
    );

    if (index != -1) {
      _registeredUsers[index] = updatedUser;
    }
  }

  /// UPDATE PASSWORD
  bool changePassword({
    required String oldPassword,
    required String newPassword,
  }) {

    final currentUser =
        AuthSession.currentUser;

    if (currentUser == null) {
      return false;
    }

    /// VALIDASI PASSWORD LAMA
    if (currentUser.password != oldPassword) {
      return false;
    }

    /// UPDATE PASSWORD
    final updatedUser =
        currentUser.copyWith(
      password: newPassword,
    );

    /// UPDATE DATA
    updateCurrentUser(updatedUser);

    return true;
  }

  /// OPTIONAL
  List<UserModel> get users =>
      _registeredUsers;

  String get demoCredentialHint =>
      'Demo: user@gmail.com / test123';
}