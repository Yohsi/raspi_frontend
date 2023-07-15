import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Credentials {
  Credentials({required this.username, required this.password});

  String username;
  String password;

  Map<String, String> generateAuthorizationHeader() {
    var concat = "$username:$password";
    var encoded = base64Encode(utf8.encode(concat));
    return {"Authorization": "Basic $encoded"};
  }
}

class SettingsSaving {
  static const _serverUrlKey = 'server_url';
  static const _serverUsernameKey = 'server_username';
  static const _serverPasswordKey = 'server_password';
  static const _seriesKey = 'series';

  static Future<void> saveServerUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_serverUrlKey, url);
  }

  static Future<String?> loadServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_serverUrlKey);
  }

  static Future<void> saveServerCredentials(
      String user, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_serverUsernameKey, user);
    await prefs.setString(_serverPasswordKey, password);
  }

  static Future<Credentials?> loadServerCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    var username = prefs.getString(_serverUsernameKey);
    var password = prefs.getString(_serverPasswordKey);
    if (username == null || password == null) {
      return null;
    }
    return Credentials(username: username, password: password);
  }

  static Future<void> saveSeries(List<String> series) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_seriesKey, series);
  }

  static Future<List<String>?> loadSeries() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_seriesKey);
  }
}
