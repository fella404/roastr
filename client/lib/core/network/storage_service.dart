import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _tokenKey = 'auth_token';

  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> removeToken() async {
    await _prefs.remove(_tokenKey);
  }

  bool get hasToken => getToken() != null;
}
