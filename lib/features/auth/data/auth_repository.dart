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

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:salon_and_beauty/core/data/database_helper.dart';
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
  Future<UserModel?> validateLogin({
    required String identifier,
    required String password,
  }) async {
    if (
        identifier.trim().isEmpty ||
        password.trim().length < 6) {
      return null;
    }

    // First try DB
    try {
      final db = await DatabaseHelper.instance.database;
      final rows = await db.query(
        'users',
        where: '(email = ? OR name = ?) AND password = ?',
        whereArgs: [identifier, identifier, password],
      );

      if (rows.isNotEmpty) {
        final user = UserModel.fromMap(rows.first);
        // persist session
        await AuthSession.persistLogin(user);
        return user;
      }
    } catch (error, stackTrace) {
      debugPrint('AuthRepository.validateLogin DB error: $error');
      debugPrintStack(stackTrace: stackTrace);
      // ignore DB errors and fallback to memory
    }

    try {
      final user = _registeredUsers.firstWhere(
        (u) => (u.email == identifier || u.name == identifier) && u.password == password,
      );
      await AuthSession.persistLogin(user);
      return user;
    } catch (e) {
      return null;
    }
  }

  /// REGISTER
  Future<RegisterResult> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {

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
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      password: password,
    );

    // try persist to DB
    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert('users', newUser.toMap());
    } catch (error, stackTrace) {
      debugPrint('AuthRepository.register DB error: $error');
      debugPrintStack(stackTrace: stackTrace);
      // fallback to memory
      _registeredUsers.add(newUser);
    }

    return RegisterResult.success();
  }

  /// UPDATE USER LOGIN SEKARANG
  void updateCurrentUser(UserModel updatedUser) {

    /// UPDATE SESSION
    AuthSession.currentUser = updatedUser;
    // persist user id
    AuthSession.persistLogin(updatedUser);

    /// UPDATE LIST USER
    final index = _registeredUsers.indexWhere((u) => u.id == updatedUser.id);

    // update DB record as well
    unawaited(_updateUserToDb(updatedUser));

    if (index != -1) {
      _registeredUsers[index] = updatedUser;
    }
  }

  Future<void> _updateUserToDb(UserModel user) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
    } catch (error, stackTrace) {
      debugPrint('AuthRepository._updateUserToDb DB error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// UPDATE PASSWORD
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {

    final sessionUser = AuthSession.currentUser;

    if (sessionUser == null) {
      return false;
    }

    UserModel currentUser = sessionUser;

    try {
      final db = await DatabaseHelper.instance.database;
      final rows = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [sessionUser.id],
        limit: 1,
      );

      if (rows.isNotEmpty) {
        currentUser = UserModel.fromMap(rows.first);
      }
    } catch (error, stackTrace) {
      debugPrint('AuthRepository.changePassword read DB error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    await AuthSession.persistLogin(currentUser);

    /// VALIDASI PASSWORD LAMA
    if (currentUser.password != oldPassword) {
      return false;
    }

    /// UPDATE PASSWORD
    final updatedUser = currentUser.copyWith(password: newPassword);

    // update DB if possible
    try {
      final db = await DatabaseHelper.instance.database;
      final updated = await db.update(
        'users',
        updatedUser.toMap(),
        where: 'id = ?',
        whereArgs: [updatedUser.id],
      );

      if (updated > 0) {
        // DB already updated; continue syncing local state below.
      }
    } catch (error, stackTrace) {
      debugPrint('AuthRepository.changePassword DB error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    // Keep local session and in-memory cache in sync even when the DB row is
    // missing or the device is running against a memory-only account.
    await AuthSession.persistLogin(updatedUser);

    final index = _registeredUsers.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      _registeredUsers[index] = updatedUser;
    } else {
      _registeredUsers.add(updatedUser);
    }

    return true;
  }

  /// OPTIONAL
  List<UserModel> get users =>
      _registeredUsers;

  String get demoCredentialHint =>
      'Demo: user@gmail.com / test123';
}