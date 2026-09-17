import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthHelper {
  static const String _usersKey = 'users';
  static const String _sessionKey = 'current_user';

  // Save a new user on signup
  static Future<bool> registerUser(String name, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_usersKey);
    final List<dynamic> users = data != null ? json.decode(data) : [];

    // Check if email already exists
    final exists = users.any((u) => u['email'] == email.toLowerCase().trim());
    if (exists) return false;

    users.add({
      'name': name.trim(),
      'email': email.toLowerCase().trim(),
      'password': password,
    });

    await prefs.setString(_usersKey, json.encode(users));
    return true;
  }

  // Returns user name if credentials match, null if wrong
  static Future<String?> loginUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_usersKey);
    if (data == null) return null;

    final List<dynamic> users = json.decode(data);
    final normalizedEmail = email.toLowerCase().trim();
    Map<String, dynamic>? user;

    for (final entry in users) {
      if (entry is Map &&
          entry['email'] == normalizedEmail &&
          entry['password'] == password) {
        user = Map<String, dynamic>.from(entry);
        break;
      }
    }

    if (user == null) return null;

    await prefs.setString(
      _sessionKey,
      json.encode({
        'name': user['name'],
        'email': user['email'],
      }),
    );

    return user['name'] as String?;
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_sessionKey);
  }

  static Future<String?> currentEmail() async {
    final session = await _session();
    return session?['email'] as String?;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  static Future<Map<String, dynamic>?> _session() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_sessionKey);
    if (data == null) return null;
    return Map<String, dynamic>.from(json.decode(data));
  }
}
