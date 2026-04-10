import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pose_provider.dart';
import '../widgets/glass_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PoseProvider>(context, listen: false);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                const Text("CHIKU AI", style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Color(0xFF00FF99), letterSpacing: 2)),
                const Text("2026 Fitness Revolution", style: TextStyle(color: Colors.white38, fontSize: 12)),
                const SizedBox(height: 50),
                
                GlassCard(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    children: [
                      TextField(
                        controller: userCtrl, 
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: "Username", labelStyle: TextStyle(color: Colors.white60)),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: passCtrl, 
                        obscureText: true, 
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: "Password", labelStyle: TextStyle(color: Colors.white60)),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                isLoading 
                  ? const CircularProgressIndicator(color: Color(0xFF00FF99))
                  : ElevatedButton(
                      onPressed: () async {
                        setState(() => isLoading = true);
                        
                        // 🚀 CALLING THE SMART LOGIN
                        int status = await provider.loginUser(userCtrl.text, passCtrl.text);
                        
                        setState(() => isLoading = false);

                        if (status == 200) {
                          Navigator.pushReplacementNamed(context, '/home');
                        } 
                        else if (status == 404) {
                          _showRegisterPrompt(context);
                        } 
                        else if (status == 401) {
                          _showResetDialog(context, userCtrl.text);
                        } 
                        else {
                          _showError("Connection failed. Check if FastAPI is running!");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00FF99),
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text("LOGIN", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
  }

  // 🛡️ SECURITY QUESTION DIALOG
  void _showResetDialog(BuildContext context, String user) {
    final answerCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Forgot Password?", style: TextStyle(color: Color(0xFF00FF99))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Security Question: Favorite color?", style: TextStyle(color: Colors.white70)),
            TextField(controller: answerCtrl, decoration: const InputDecoration(hintText: "Your Answer")),
            TextField(controller: newPassCtrl, decoration: const InputDecoration(hintText: "New Password"), obscureText: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              bool ok = await Provider.of<PoseProvider>(context, listen: false).resetPassword(user, answerCtrl.text, newPassCtrl.text);
              Navigator.pop(ctx);
              _showError(ok ? "Password updated! Try logging in." : "Incorrect Answer!");
            }, 
            child: const Text("Reset")
          ),
        ],
      ),
    );
  }

  // 📝 REDIRECT TO REGISTER PROMPT
  void _showRegisterPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("User Not Found"),
        content: const Text("No account exists with this name. Would you like to create one?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("No")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, '/register');
            }, 
            child: const Text("Register")
          ),
        ],
      ),
    );
  }
}