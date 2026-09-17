import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthHelper {
  static const String _usersKey = 'users';

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
    final user = users.firstWhere(
          (u) =>
      u['email'] == email.toLowerCase().trim() &&
          u['password'] == password,
      orElse: () => null,
    );

    return user?['name'];
  }
}