import 'package:salon_and_beauty/Models/UserModel.dart';
import 'package:salon_and_beauty/core/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthSession {
  static String? _token;
  static UserModel? _currentUser;

  static UserModel? get currentUser => _currentUser;
  static String? get token => _token;
  static bool get isLoggedIn => _token != null;

  static Future<void> bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    if (_token != null) {
      try {
        final response = await ApiClient().get('/auth/me');
        _currentUser = UserModel.fromJson(response.data['data']);
      } catch (_) {
        await clearSession();
      }
    }
  }

  static Future<void> persistLogin(String token, UserModel user) async {
    _token = token;
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearSession() async {
    _token = null;
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
