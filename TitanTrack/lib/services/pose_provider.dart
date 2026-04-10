import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PoseProvider with ChangeNotifier {
  // --- 1. DATA FIELDS ---
  int? userId;
  String username = "Guest";
  String profileImage = "";
  
  // Unified variable names to match your UI and Backend
  double points = 0.0; 
  int reps = 0; 
  double calories = 0.0;
  
  List<dynamic> history = [];

  // Replace with your Laptop's IP (e.g., 10.226.40.165 or 10.0.2.2 for emulator)
  final String baseUrl = "http://10.190.156.172:8000";

  // --- 2. SMART LOGIN METHOD ---
  // Returns: 200 (Success), 404 (Not Found -> Trigger Register), 401 (Wrong Pass -> Trigger Reset)
  Future<int> loginUser(String user, String pass) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": user, "password": pass}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        userId = data['user_id'];
        username = data['username'];
        profileImage = data['profile_image'];
        // Using 'points' and 'calories' to match the state variables
        points = (data['points'] ?? 0.0).toDouble();
        calories = (data['calories'] ?? 0.0).toDouble();
        
        await fetchHistory();
        notifyListeners();
        return 200;
      }
      return response.statusCode; 
    } catch (e) {
      debugPrint("Login Connection Error: $e");
      return 500;
    }
  }

  // --- 3. AUTO-REGISTER METHOD ---
  Future<bool> registerUser(String user, String pass, String answer) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": user, 
          "password": pass, 
          "security_answer": answer
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- 4. PASSWORD RESET METHOD ---
  Future<bool> resetPassword(String user, String answer, String newPass) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": user, 
          "answer": answer, 
          "new_password": newPass
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- 5. HISTORY FETCH METHOD ---
  Future<void> fetchHistory() async {
    if (userId == null) return;
    try {
      final response = await http.get(Uri.parse('$baseUrl/user/$userId/history'));
      if (response.statusCode == 200) {
        history = jsonDecode(response.body);
        
        if (history.isNotEmpty) {
          reps = history[0]['reps'] ?? 0;
        } else {
          reps = 0;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("History Fetch Error: $e");
    }
  }

  // --- 6. DATA SYNC & REFRESH ---
  // Call this after you close the AI webcam window
  Future<void> syncAndRefresh() async {
    if (userId == null) return;
    
    try {
      final profileRes = await http.get(Uri.parse('$baseUrl/user/$userId'));
      if (profileRes.statusCode == 200) {
        var data = jsonDecode(profileRes.body);
        // Note: ensure these keys match your FastAPI response keys
        points = (data['total_points'] ?? 0.0).toDouble();
        calories = (data['calories_burned'] ?? 0.0).toDouble();
      }

      await fetchHistory(); 
      notifyListeners();
      debugPrint("✅ App Synced with MySQL successfully.");
    } catch (e) {
      debugPrint("❌ Sync Error: $e");
    }
  }

  Future<int> login(String text, String text2) async {
    return await loginUser(text, text2);
  }
}