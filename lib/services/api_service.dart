import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<String> fetchQuote() async {
    try {
      final response = await http
          .get(Uri.parse('https://zenquotes.io/api/random'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final quote = data[0]['q'] as String? ?? '';
          final author = data[0]['a'] as String? ?? 'Unknown';
          if (quote.isNotEmpty) {
            return '"$quote" — $author';
          }
        }
      }
    } catch (e) {
      debugPrint('Quote API error: $e');
    }

    // Fallback if network fails
    return '"Stay productive today — one task at a time!" 💗';
  }
}
