import 'package:flutter/material.dart';

class WorkoutGridScreen extends StatefulWidget {
  const WorkoutGridScreen({super.key});

  @override
  State<WorkoutGridScreen> createState() => _WorkoutGridScreenState();
}

class _WorkoutGridScreenState extends State<WorkoutGridScreen> {
  String selectedDifficulty = "Medium";

  // 🏋️ THE MEGA LIST
  final List<Map<String, dynamic>> exercises = [
    {"name": "Pushups", "icon": Icons.fitness_center, "color": Colors.greenAccent},
    {"name": "Squats", "icon": Icons.accessibility_new, "color": Colors.orangeAccent},
    {"name": "Plank", "icon": Icons.timer, "color": Colors.blueAccent},
    {"name": "Chin-ups", "icon": Icons.upload, "color": Colors.redAccent},
    {"name": "Jumping Jacks", "icon": Icons.directions_run, "color": Colors.purpleAccent},
    {"name": "High Knees", "icon": Icons.bolt, "color": Colors.yellowAccent},
    {"name": "Lunges", "icon": Icons.straighten, "color": Colors.cyanAccent},
    {"name": "Burpees", "icon": Icons.whatshot, "color": Colors.pinkAccent},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text("CHIKU AI GYM", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔥 DIFFICULTY SELECTOR
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ["Easy", "Medium", "Hard"].map((d) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: ChoiceChip(
                  label: Text(d),
                  selected: selectedDifficulty == d,
                  onSelected: (s) => setState(() => selectedDifficulty = d),
                  selectedColor: const Color(0xFF00FF99),
                ),
              )).toList(),
            ),
          ),

          // 🔳 GRID OF EXERCISES
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 1.1,
              ),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                var ex = exercises[index];
                return InkWell(
                  onTap: () => _startWorkout(ex['name']),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(ex['icon'], color: ex['color'], size: 40),
                        const SizedBox(height: 10),
                        Text(ex['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text(selectedDifficulty, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _startWorkout(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Starting $name ($selectedDifficulty)... Stand back from camera!"))
    );
    // 🚀 Logic to trigger AI Engine will go here
  }
}