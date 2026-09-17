import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // 🔑 Sign up free at https://api-ninjas.com to get your key
  // Then replace the value below with your actual key
  static const String _apiKey = 'YOUR_API_NINJAS_KEY_HERE';

  static Future<String> fetchQuote() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.api-ninjas.com/v1/quotes?category=inspirational'),
        headers: {'X-Api-Key': _apiKey},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final quote = data[0]['quote'] as String;
          final author = data[0]['author'] as String? ?? 'Unknown';
          return '"$quote" — $author';
        }
      }
    } catch (e) {
      debugPrint('Quote API error: $e');
    }

    // Fallback if API key not set or network fails
    return '"Stay productive today — one task at a time!" 💗';
  }
}