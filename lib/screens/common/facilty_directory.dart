import 'package:flutter/material.dart';

/// ===================== DATA MODELS =====================
class Faculty {
  final String id;
  final String name;
  final String school;
  final String dept;

  const Faculty({
    required this.id,
    required this.name,
    required this.school,
    required this.dept,
  });
}

class FacultySlot {
  final int weekday; // 1=Mon..5=Fri
  final TimeOfDay start;
  final TimeOfDay end;
  final String courseCode;
  final String courseTitle;
  final String room;
  final String label;

  const FacultySlot({
    required this.weekday,
    required this.start,
    required this.end,
    required this.courseCode,
    required this.courseTitle,
    required this.room,
    required this.label,
  });
}

/// ===================== SAMPLE FACULTY DATA =====================
final List<Faculty> kFaculty = [
  Faculty(id: 'CSE101', name: 'Dr. Ananya Rao', school: 'School of Computing', dept: 'Computer Science'),
  Faculty(id: 'EEE201', name: 'Prof. Meera Thomas', school: 'School of Engineering', dept: 'Electrical Engineering'),
  Faculty(id: 'ME301', name: 'Dr. Aditya Menon', school: 'School of Engineering', dept: 'Mechanical Engineering'),
  Faculty(id: 'MATH401', name: 'Dr. Krishnan Nair', school: 'School of Science', dept: 'Mathematics'),
];

/// Simple fake timetable for demo purposes
final Map<String, List<FacultySlot>> kSlots = {
  'CSE101': [
    FacultySlot(
      weekday: 1,
      start: TimeOfDay(hour: 9, minute: 0),
      end: TimeOfDay(hour: 10, minute: 0),
      courseCode: 'CS301',
      courseTitle: 'Operating Systems',
      room: 'S101',
      label: 'CSE-A (Y3) • Sem 5',
    ),
  ],
  'EEE201': [
    FacultySlot(
      weekday: 2,
      start: TimeOfDay(hour: 10, minute: 0),
      end: TimeOfDay(hour: 11, minute: 0),
      courseCode: 'EE210',
      courseTitle: 'Digital Circuits',
      room: 'E202',
      label: 'EEE-A (Y2) • Sem 3',
    ),
  ],
};

/// ===================== FACULTY DIRECTORY SCREEN =====================
class FacultyDirectoryScreen extends StatefulWidget {
  const FacultyDirectoryScreen({super.key});

  @override
  State<FacultyDirectoryScreen> createState() => _FacultyDirectoryScreenState();
}

class _FacultyDirectoryScreenState extends State<FacultyDirectoryScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = kFaculty
        .where((f) =>
            f.name.toLowerCase().contains(query.toLowerCase()) ||
            f.dept.toLowerCase().contains(query.toLowerCase()) ||
            f.id.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Directory'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search by name, ID, or department',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => query = v.trim()),
            ),
          ),

          // List
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final f = filtered[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.teal),
                    title: Text(f.name),
                    subtitle: Text('${f.id} • ${f.dept}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FacultyTimetableScreen(faculty: f),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// ===================== FACULTY TIMETABLE SCREEN =====================
class FacultyTimetableScreen extends StatelessWidget {
  final Faculty faculty;

  const FacultyTimetableScreen({super.key, required this.faculty});

  @override
  Widget build(BuildContext context) {
    final slots = kSlots[faculty.id] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('${faculty.name} Timetable'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: slots.isEmpty
          ? const Center(child: Text('No classes assigned yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: slots.length,
              itemBuilder: (_, i) {
                final s = slots[i];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.schedule, color: Colors.teal),
                    title: Text('${s.courseCode} • ${s.courseTitle}'),
                    subtitle: Text('${s.room}   •   ${s.start.format(context)} - ${s.end.format(context)}'),
                  ),
                );
              },
            ),
    );
  }
}
