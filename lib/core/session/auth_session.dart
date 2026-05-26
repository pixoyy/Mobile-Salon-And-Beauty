import 'package:salon_and_beauty/features/user/data/dummy_user.dart';
import 'package:salon_and_beauty/features/user/data/user_model.dart';

class AuthSession {
  static UserModel? currentUser;

  static UserModel get activeUser => currentUser ?? DummyUser.activeCustomer;

  static String get activeCustomerId => activeUser.id;

  static bool get isLoggedIn => currentUser != null;

  static void logout() {
    currentUser = null;
  }
}