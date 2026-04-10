import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pose_provider.dart';
import '../widgets/glass_card.dart';

class RedeemScreen extends StatelessWidget {
  const RedeemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final poseData = Provider.of<PoseProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("REDEEM REWARDS")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🪙 TOTAL BALANCE CARD
            GlassCard(
              height: 120,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("YOUR TOTAL BALANCE", style: TextStyle(color: Colors.white70)),
                  Text("₹ ${poseData.points.toStringAsFixed(2)}", 
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF00FF99))),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            const Text("AVAILABLE COUPONS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 15),

            // 🎁 REWARDS LIST
            Expanded(
              child: ListView(
                children: [
                  _rewardTile(context, "Amazon Pay Voucher", "500 Points", Icons.shopping_bag, 500),
                  _rewardTile(context, "Gym Supplement Disc.", "200 Points", Icons.fitness_center, 200),
                  _rewardTile(context, "Premium AI Coach", "1000 Points", Icons.psychology, 1000),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rewardTile(BuildContext context, String title, String subtitle, IconData icon, int cost) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(icon, color: const Color(0xFF00FF99), size: 30),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(subtitle, style: const TextStyle(color: Colors.white60)),
            trailing: TextButton(
              onPressed: () {
                // Logic: Deduct points and show a success snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Processing Redemption..."), backgroundColor: Colors.orangeAccent),
                );
              },
              child: const Text("REDEEM", style: TextStyle(color: Color(0xFF00FF99))),
            ),
          ),
        ),
      ),
    );
  }
}