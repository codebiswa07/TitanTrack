import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // 💡 2026 Connectivity Logic:
  // Android Emulator uses 10.0.2.2 to talk to your PC's localhost.
  // Windows/Desktop and iOS use 127.0.0.1.
  static String get baseUrl {
    if (kIsWeb) return "http://localhost:8000";
    if (Platform.isAndroid) return "http://10.0.2.2:8000";
    return "http://127.0.0.1:8000";
  }

  static Future<bool> postWorkout({
    required int userId,
    required String exercise,
    required int level,
    required int reps,
  }) async {
    final url = Uri.parse('$baseUrl/sync-workout');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "user_id": userId,
          "exercise": exercise,
          "level": level,
          "reps": reps,
          "timestamp": DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Data Synced to Backend: ${response.body}");
        return true;
      } else {
        print("❌ Server Error: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Network Failure: $e");
      return false;
    }
  }
}