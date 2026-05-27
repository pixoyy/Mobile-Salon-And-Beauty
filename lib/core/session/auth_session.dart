import 'package:salon_and_beauty/features/user/data/dummy_user.dart';
import 'package:salon_and_beauty/features/user/data/user_model.dart';
import 'package:salon_and_beauty/core/data/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kActiveUserIdKey = 'auth_active_user_id';

class AuthSession {
  static UserModel? currentUser;

  static UserModel get activeUser => currentUser ?? DummyUser.activeCustomer;

  static String get activeCustomerId => activeUser.id;

  static bool get isLoggedIn => currentUser != null;

  /// Persist current user id to SharedPreferences and set currentUser
  static Future<void> persistLogin(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kActiveUserIdKey, user.id);
    } catch (_) {
      // ignore persistence errors
    }
    currentUser = user;
  }

  /// Clear persisted session and currentUser
  static Future<void> clearPersistentSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kActiveUserIdKey);
    } catch (_) {
      // ignore
    }
    currentUser = null;
  }

  /// Non-async logout kept for compatibility; also clears persistent session asynchronously.
  static void logout() {
    currentUser = null;
    clearPersistentSession();
  }

  /// Bootstrap session from SharedPreferences (call at app start)
  static Future<void> bootstrap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedId = prefs.getString(_kActiveUserIdKey);
      if (storedId == null || storedId.isEmpty) return;

      final db = await DatabaseHelper.instance.database;
      final rows = await db.query('users', where: 'id = ?', whereArgs: [storedId]);
      if (rows.isNotEmpty) {
        currentUser = UserModel.fromMap(rows.first);
      }
    } catch (_) {
      // ignore bootstrap errors
    }
  }
}