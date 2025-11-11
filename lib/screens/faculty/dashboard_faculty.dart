import 'package:flutter/material.dart';
import '../common/facilty_directory.dart';
import 'change_status.dart';
import 'edit_timetable.dart';
import '../common/batch_schedule.dart';


class DashboardFacultyScreen extends StatelessWidget {
  const DashboardFacultyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Campus361 Heading
              Row(
                children: [
                  const Icon(Icons.school_rounded, color: Colors.blue, size: 30),
                  const SizedBox(width: 8),
                  Text(
                    'Campus361',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Welcome back 👋',
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
                    _buildDashboardTile(
                      context,
                      icon: Icons.edit_calendar_rounded,
                      title: 'Edit Timetable',
                      color: Colors.blue.shade100,
                      iconColor: Colors.blue.shade700,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditTimetableScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDashboardTile(
                      context,
                      icon: Icons.toggle_on_outlined,
                      title: 'Change Status',
                      color: Colors.green.shade100,
                      iconColor: Colors.green.shade700,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChangeStatusScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDashboardTile(
                      context,
                      icon: Icons.people_outline,
                      title: 'Faculty Timetable',
                      color: Colors.orange.shade100,
                      iconColor: Colors.orange.shade700,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FacultyDirectoryScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDashboardTile(
                      context,
                      icon: Icons.school_outlined,
                      title: 'Batch Timetable',
                      color: Colors.purple.shade100,
                      iconColor: Colors.purple.shade700,
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SchedulePage(),
                          ),
                        );
                      }
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

  Widget _buildDashboardTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title clicked')),
            );
          },
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
            Icon(icon, color: iconColor, size: 36),
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
