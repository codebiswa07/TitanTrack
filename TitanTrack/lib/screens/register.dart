import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pose_provider.dart';
import '../widgets/glass_card.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController userCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController answerCtrl = TextEditingController(); // 👈 Added for security

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 Fetching the baseUrl from your Provider automatically
    final provider = Provider.of<PoseProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("CREATE ACCOUNT", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF00FF99))),
              const SizedBox(height: 40),
              
              GlassCard(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    TextField(controller: userCtrl, decoration: const InputDecoration(labelText: "Username")),
                    const SizedBox(height: 10),
                    TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
                    const SizedBox(height: 10),
                    // 🛡️ SECURITY QUESTION
                    TextField(
                      controller: answerCtrl, 
                      decoration: const InputDecoration(labelText: "Security Answer", hintText: "Favorite color?"),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              ElevatedButton(
                onPressed: () async {
                  // 🚀 Using the Provider to handle the API call
                  bool success = await provider.registerUser(
                    userCtrl.text, 
                    passCtrl.text, 
                    answerCtrl.text
                  );

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Account Created! You can now Login."), backgroundColor: Colors.green)
                    );
                    Navigator.pop(context); // Go back to Login screen
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Registration Failed. Username might be taken."), backgroundColor: Colors.redAccent)
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FF99),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("REGISTER NOW", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
              
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Already have an account? Login", style: TextStyle(color: Colors.white38)),
              )
            ],
          ),
        ),
      ),
    );
  }
}