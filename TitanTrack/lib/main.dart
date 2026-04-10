import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// Import your screens (Ensure these filenames match yours exactly)
import 'screens/dashboard.dart';
import 'screens/workout.dart';
import 'screens/running.dart';
import 'screens/redeem.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'services/pose_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => PoseProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        initialRoute: '/login', // 👈 App starts here
        routes: {
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/home': (context) => const MainNavigator(),
        },
      ),
    ),
  );
}

class ChikuAIHero extends StatelessWidget {
  const ChikuAIHero({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chiku AI Hero',
      
      // 🎨 Setting the 2026 Dark Theme
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        primaryColor: const Color(0xFF00FF99),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const MainNavigator(),
    );
  }
}

// 🧭 THE MASTER NAVIGATOR
class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  // 📝 List of all the pages you created
  final List<Widget> _pages = [
    const DashboardScreen(), // Home
    const WorkoutScreen(),   // AI Pushups
    const RunningScreen(),   // GPS Run
    const RedeemScreen(),    // Wallet
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body changes based on which icon you tap
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      
      // 📱 The Bottom Navigation Bar (Interactive Shell)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF0F0F0F),
          selectedItemColor: const Color(0xFF00FF99),
          unselectedItemColor: Colors.white38,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_outlined),
              activeIcon: Icon(Icons.fitness_center),
              label: 'Workout',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_run_outlined),
              activeIcon: Icon(Icons.directions_run),
              label: 'Run',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Wallet',
            ),
          ],
        ),
      ),
    );
  }
}