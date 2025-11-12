import 'package:campusapp/screens/common/events.dart';
import 'package:campusapp/screens/faculty/batch_search.dart';
import 'package:campusapp/screens/faculty/faculty_search.dart';
import 'package:flutter/material.dart';
import 'student_timetable.dart';
 // ✅ Import timetable screen

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF1173D4),
        title: const Text(
          'Student Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Header
              Row(
                children: [
                  const Icon(Icons.school_rounded, color: Color(0xFF1173D4), size: 30),
                  const SizedBox(width: 8),
                  const Text(
                    'Campus361',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1173D4),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),
              Text(
                
                'Welcome, Student 👋',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),

              const SizedBox(height: 25),

              // Dashboard Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    // 🕓 My Timetable
                    // _buildDashboardTile(
                    //   context,
                    //   icon: Icons.access_time,
                    //   title: 'My Timetable',
                    //   color: Colors.blue.shade100,
                    //   iconColor: Colors.blue.shade700,
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => const StudentTimetableScreen(),
                    //       ),
                    //     );
                    //   },
                    // ),

                    // 👨‍🏫 Faculty Timetable
                    _buildDashboardTile(
                      context,
                      icon: Icons.people_outline,
                      title: 'Check Faculty TT',
                      color: Colors.orange.shade100,
                      iconColor: Colors.orange.shade700,
                      onTap: () {
                        Navigator.push(context,MaterialPageRoute(builder:(c) => const FacultySearchPage()));
                        
                      },
                    ),

                    // 🎓 Batch Timetable
                    _buildDashboardTile(
                      context,
                      icon: Icons.school_outlined,
                      title: 'Check Batch TT',
                      color: Colors.purple.shade100,
                      iconColor: Colors.purple.shade700,
                      onTap: () {
                        Navigator.push(context,MaterialPageRoute(builder:(c) => const BatchSearchPage() ));
                        
                        
                      },
                    ),

                    // ⚙️ Settings
                    _buildDashboardTile(
                      context,
                      icon: Icons.settings,
                      title: 'Events',
                      color: Colors.teal.shade100,
                      iconColor: Colors.teal.shade700,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EventsPage()),
                        );
                      },
                        
                    ),
                  ],
                ),
              ),

              // Footer
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
                  child: Text(
                    'Campus361 © 2025',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Dashboard Tile Widget ---
  Widget _buildDashboardTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 40),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
