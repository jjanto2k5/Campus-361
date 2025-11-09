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

//sos
import 'screens/common/sos.dart';


void main() {
  runApp(const CampusNavigatorApp());
}
const String userRole = 'student';

class CampusNavigatorApp extends StatelessWidget {
  const CampusNavigatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Navigator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;

  late List<Widget> _widgetOptions; // make it dynamic

  @override
  void initState() {
    super.initState();

    // Define all screens dynamically (so _onItemTapped can be used)
    _widgetOptions = [
      const Center(child: Text('Map Screen')),

      // Home screen (changes based on user role)
      userRole == 'faculty'
          ? const DashboardFacultyScreen()
          : const DashboardStudentScreen(),

      // Timetable (faculty/student difference handled here)
      userRole == 'faculty'
          ? TimetableScreen(onNavigateToTab: (index) {
              _onItemTapped(index); // ✅ Works now
            })
          : StudentTimetableScreen(onNavigateToTab: (index) {
              _onItemTapped(index); // ✅ Works here too
            }),

      const SOSScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
            tabBackgroundColor: Colors.blue.shade600,
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

