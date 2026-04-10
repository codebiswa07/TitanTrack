import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  // 🔘 State for Difficulty
  String selectedDifficulty = "Medium";

  // 🏋️ Workout Data List
  final List<Map<String, dynamic>> workouts = [
    {"name": "Pushups", "icon": Icons.fitness_center, "color": Colors.greenAccent},
    {"name": "Squats", "icon": Icons.accessibility_new, "color": Colors.orangeAccent},
    {"name": "Plank", "icon": Icons.timer, "color": Colors.blueAccent},
    {"name": "Chin-ups", "icon": Icons.upload, "color": Colors.redAccent},
    {"name": "Jumping Jacks", "icon": Icons.directions_run, "color": Colors.purpleAccent},
    {"name": "High Knees", "icon": Icons.bolt, "color": Colors.yellowAccent},
    {"name": "Burpees", "icon": Icons.whatshot, "color": Colors.pinkAccent},
    {"name": "Lunges", "icon": Icons.airline_stops, "color": Colors.cyanAccent},
];

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Deep Black
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔝 Header Section
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "CHIKU AI SESSIONS",
                      style: TextStyle(
                        color: Color(0xFF00FF99),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Select your workout & difficulty level",
                      style: TextStyle(color: Colors.white38, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 🔥 1. DIFFICULTY SELECTOR (Glassmorphism Style)
              _buildDifficultySelector(),

              const SizedBox(height: 20),

              // 🔳 2. WORKOUT GRID BODY
              _buildWorkoutGrid(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- 🛠️ COMPONENT: DIFFICULTY SELECTOR ---
  Widget _buildDifficultySelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: ["Easy", "Medium", "Hard"].map((level) {
          bool isSelected = selectedDifficulty == level;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedDifficulty = level),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF00FF99) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    level,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- 🔳 COMPONENT: EXERCISE GRID ---
  Widget _buildWorkoutGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true, // Crucial for SingleChildScrollView
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.1,
      ),
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final item = workouts[index];
        return InkWell(
          onTap: () => _startWorkoutSession(item['name']),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item['icon'], color: item['color'], size: 36),
                const SizedBox(height: 12),
                Text(
                  item['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  selectedDifficulty,
                  style: TextStyle(
                    color: _getDifficultyColor(selectedDifficulty),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- 🚀 LOGIC: START WORKOUT ---
  void _startWorkoutSession(String exerciseName) {
    // 1. Show Trigger Message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Launching $exerciseName AI Engine ($selectedDifficulty)..."),
        backgroundColor: const Color(0xFF00FF99),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // 2. Here you will link to your Python Engine
    // Example logic for chiku:
    debugPrint("AI_TRIGGER: python ai_engine.py $exerciseName $selectedDifficulty");
    _startAI(exerciseName, selectedDifficulty);
  }

  Future<void> _startAI(String name, String level) async {
    final userId = 1; // You can get this from your Auth provider
    final url = Uri.parse("http://127.0.0.1:8000/launch-ai?exercise=$name&difficulty=$level&user_id=$userId");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("🚀 AI Camera Opening for $name ($level)..."))
          );
        }
      }
    } catch (e) {
      debugPrint("Error launching AI: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Failed to connect to Python Backend"))
        );
      }
    }
  }

  // Helper for text colors
  Color _getDifficultyColor(String level) {
    if (level == "Easy") return Colors.blueAccent;
    if (level == "Hard") return Colors.redAccent;
    return Colors.orangeAccent;
  }
}