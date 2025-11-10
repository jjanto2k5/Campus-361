import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

// Faculty Screens
import 'screens/faculty/dashboard_faculty.dart';
import 'screens/faculty/edit_timetable.dart';
import 'screens/faculty/change_status.dart';
import 'screens/faculty/timetable.dart';

// Student Screens
import 'screens/student/student_dashboard.dart';
import 'screens/student/student_timetable.dart';

// Common Screens
import 'screens/common/sos.dart';

// Welcome Flow
import 'screens/welcome_screen.dart';

void main() {
  runApp(const CampusApp());
}

/// Root App
class CampusApp extends StatelessWidget {
  const CampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Campus 361",
      theme: ThemeData(
        fontFamily: "Inter",
        scaffoldBackgroundColor: const Color(0xFFF6F7F8),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1173D4),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF111418)),
        ),
      ),
      home: const WelcomeScreen(), // 👈 Start at Welcome page
    );
  }
}

/// MainScreen with role-based navigation (student / faculty)
class MainScreen extends StatefulWidget {
  final String role; // 👈 Either "student" or "faculty"
  const MainScreen({super.key, required this.role});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;

  // ✅ Define userRole inside the class
  late String userRole;

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();

    // Set userRole based on the widget’s role
    userRole = widget.role;

    _widgetOptions = [
      const Center(child: Text('🗺️ Campus Map Coming Soon')),

      // 🏠 Home based on role
      widget.role == 'faculty'
          ? const DashboardFacultyScreen()
          : const StudentDashboardScreen(),

      // 📅 Timetable based on role
      widget.role == 'faculty'
          ? TimetableScreen(onNavigateToTab: (index) => _onItemTapped(index))
          : StudentTimetableScreen(onNavigateToTab: (index) => _onItemTapped(index)),

      // 🚨 SOS Screen — passes correct role
      SOSScreen(role: userRole),
    ];
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                color: Colors.grey.withOpacity(0.2),
                offset: const Offset(0, -1),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: GNav(
            gap: 8,
            color: Colors.grey[600],
            activeColor: Colors.white,
            iconSize: 26,
            tabBackgroundColor: const Color(0xFF1173D4),
            padding: const EdgeInsets.all(14),
            selectedIndex: _selectedIndex,
            onTabChange: _onItemTapped,
            tabs: const [
              GButton(icon: Icons.map_outlined, text: 'Map'),
              GButton(icon: Icons.home_filled, text: 'Home'),
              GButton(icon: Icons.calendar_today, text: 'Timetable'),
              GButton(icon: Icons.sos_outlined, text: 'SOS'),
            ],
          ),
        ),
      ),
    );
  }
}
