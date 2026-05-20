import 'package:salon_and_beauty/features/user/data/user_model.dart';

class AuthSession {
  static UserModel? currentUser;

  static bool get isLoggedIn => currentUser != null;

  static void logout() {
    currentUser = null;
  }
}