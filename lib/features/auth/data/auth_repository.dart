import 'dummy_customer.dart';
import 'register_result.dart';
import 'user_model.dart';

class AuthRepository {
  static final AuthRepository _instance = AuthRepository._internal();

  factory AuthRepository() {
    return _instance;
  }

  AuthRepository._internal() {
    _initializeDummyUser();
  }

  final List<User> _registeredUsers = [];

  void _initializeDummyUser() {
    _registeredUsers.add(DummyCustomer.demo);
  }

  User? validateLogin({
    required String identifier,
    required String password,
  }) {
    if (identifier.trim().isEmpty || password.trim().length < 6) {
      return null;
    }

    try {
      final user = _registeredUsers.firstWhere(
        (u) => (u.email == identifier || u.name == identifier) && u.password == password,
      );
      return user;
    } catch (e) {
      return null;
    }
  }

  RegisterResult register({
    required String name,
    required String email,
    required String password,
  }) {
    if (name.trim().isEmpty) {
      return RegisterResult.failure('Nama tidak boleh kosong');
    }

    if (email.trim().isEmpty) {
      return RegisterResult.failure('Email tidak boleh kosong');
    }

    if (password.trim().length < 6) {
      return RegisterResult.failure('Password minimal 6 karakter');
    }

    final emailExists = _registeredUsers.any((u) => u.email == email);
    if (emailExists) {
      return RegisterResult.failure('Email sudah terdaftar');
    }

    final newUser = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      password: password,
    );

    _registeredUsers.add(newUser);
    return RegisterResult.success();
  }

  String get demoCredentialHint =>
      'Demo: siska.amanda@example.com / password123 atau daftar akun baru';
}
