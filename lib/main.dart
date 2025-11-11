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
import 'screens/common/campus_map_main.dart'; // ✅ the polished version
import 'screens/common/campus_map.dart'; // optional older version if still used

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
      home: const WelcomeScreen(), // ✅ always start from Welcome page
    );
  }
}

/// Role-based Main Screen (Student / Faculty)
class MainScreen extends StatefulWidget {
  final String role; // 👈 "student" or "faculty"

  const MainScreen({super.key, required this.role});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;
  late String userRole;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    userRole = widget.role;

    // Define tabs for both roles
    _widgetOptions = [
      // 🗺️ Map
      const MapTab(),

      // 🏠 Home
      userRole == 'faculty'
          ? const DashboardFacultyScreen()
          : const StudentDashboardScreen(),

      // 📅 Timetable
      userRole == 'faculty'
          ? TimetableScreen()
          : const StudentTimetableScreen(),

      // 🚨 SOS
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

/// 🗺️ Separate Map Tab Widget for cleaner structure
class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  String? selectedStart;
  String? selectedDestination;

  void _openMap() {
    if (selectedStart != null && selectedDestination != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CampusMapMainScreen(
            startRoom: selectedStart!,
            destinationRoom: selectedDestination!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both locations')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Campus Map"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Find Path Between Rooms",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // From Dropdown
            DropdownButtonFormField<String>(
              value: selectedStart,
              decoration: _dropdownDecoration("From (Your Location)"),
              items: ['S101', 'S102', 'S103', 'S104', 'S105', 'S106']
                  .map((room) => DropdownMenuItem(
                        value: room,
                        child: Text(room),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => selectedStart = val),
            ),
            const SizedBox(height: 16),

            // To Dropdown
            DropdownButtonFormField<String>(
              value: selectedDestination,
              decoration: _dropdownDecoration("To (Destination)"),
              items: ['S101', 'S102', 'S103', 'S104', 'S105', 'S106']
                  .map((room) => DropdownMenuItem(
                        value: room,
                        child: Text(room),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => selectedDestination = val),
            ),
            const SizedBox(height: 24),

            // Show Path Button
            ElevatedButton.icon(
              onPressed: _openMap,
              icon: const Icon(Icons.navigation_outlined, color: Colors.white),
              label: const Text(
                "Show Path",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1173D4),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      filled: true,
      fillColor: Colors.grey.shade100,
    );
  }
}
