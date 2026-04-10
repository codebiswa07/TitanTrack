import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pose_provider.dart';
import '../widgets/glass_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final poseData = Provider.of<PoseProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(radius: 50, backgroundColor: Color(0xFF00FF99), child: Icon(Icons.person, size: 50)),
            const Text("chiku", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text("KIIT Fitness Pro", style: TextStyle(color: Colors.white38)),
            
            const SizedBox(height: 30),
            const Text("WORKOUT HISTORY", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
            
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: poseData.history.length,
                itemBuilder: (context, index) {
                  var log = poseData.history[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GlassCard(
                      child: ListTile(
                        leading: const Icon(Icons.history, color: Color(0xFF00FF99)),
                        title: Text("${log['exercise'].toUpperCase()} - ${log['reps']} Reps"),
                        subtitle: Text(log['timestamp']),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}