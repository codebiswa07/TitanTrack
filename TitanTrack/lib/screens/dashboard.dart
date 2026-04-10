import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pose_provider.dart';
import '../widgets/glass_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final poseData = Provider.of<PoseProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(backgroundImage: (poseData.profileImage.isNotEmpty ? NetworkImage(poseData.profileImage) : const AssetImage('assets/profile.png')) as ImageProvider<Object>),
                      const SizedBox(width: 15),
                      Text("Welcome, ${poseData.username}!", style: const TextStyle(fontSize: 20)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.sync, color: Color(0xFF00FF99)),
                    onPressed: () async {
                      // Show a loading snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Syncing with AI Engine..."), duration: Duration(seconds: 1)),
                      );

                      // Trigger the provider refresh
                      // TODO: Replace with actual refresh method from PoseProvider
                      await Provider.of<PoseProvider>(context, listen: false).syncAndRefresh();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // FEATURE 1: WALLET BALANCE (Merged Backend)
              _sectionLabel("YOUR EARNINGS"),
              GlassCard(
                padding: const EdgeInsets.all(15),
                height: 100,
                child: Center(
                  child: Text("₹ ${poseData.points.toStringAsFixed(2)}", 
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF00FF99))),
                ),
              ),

              const SizedBox(height: 25),

              // FEATURE 2: QUICK HEALTH STATS
              _sectionLabel("LIVE ACTIVITY"),
              Row(
                children: [
                  Expanded(child: _miniStatCard("Reps", "${poseData.reps}", Icons.bolt)),
                  const SizedBox(width: 15),
                  Expanded(child: _miniStatCard("Calories", "${poseData.calories}", Icons.local_fire_department)),
                ],
              ),

              const SizedBox(height: 25),

              // FEATURE 3: TRAINING MODES
              _sectionLabel("TRAINING MODES"),
              _featureTile("AI POSE ANALYSIS", "Uses MediaPipe for real-time rep counting", Icons.videocam, Colors.blueAccent),
              _featureTile("OUTDOOR RUNNING", "GPS tracking with per-KM rewards", Icons.location_on, Colors.greenAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1.2)),
  );

  Widget _miniStatCard(String title, String value, IconData icon) {
    return GlassCard(
      padding: const EdgeInsets.all(15),
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF00FF99), size: 20),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.white30)),
        ],
      ),
    );
  }

  Widget _featureTile(String title, String desc, IconData icon, Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: GlassCard(
        padding: const EdgeInsets.all(15),
        child: ListTile(
          leading: CircleAvatar(backgroundColor: accent.withOpacity(0.2), child: Icon(icon, color: accent)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text(desc, style: const TextStyle(fontSize: 11, color: Colors.white54)),
          trailing: const Icon(Icons.chevron_right, color: Colors.white24),
        ),
      ),
    );
  }
}