import 'package:flutter/material.dart';

class StudentTimetableScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab; // callback to switch tab

  const StudentTimetableScreen({Key? key, this.onNavigateToTab})
      : super(key: key);

  @override
  State<StudentTimetableScreen> createState() => _StudentTimetableScreenState();
}

class _StudentTimetableScreenState extends State<StudentTimetableScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Student weekly timetable data
  final Map<String, List<Map<String, String>>> studentSchedule = {
    'Mon': [
      {'time': '9:00 - 9:50', 'subject': 'DSA', 'room': '201'},
      {'time': '10:00 - 10:50', 'subject': 'DBMS', 'room': '305'},
      {'time': '11:00 - 11:50', 'subject': 'Math', 'room': '112'},
    ],
    'Tue': [
      {'time': '9:00 - 9:50', 'subject': 'Physics', 'room': 'Lab B'},
      {'time': '10:00 - 10:50', 'subject': 'DSA', 'room': '201'},
      {'time': '1:00 - 1:50', 'subject': 'English', 'room': '101'},
    ],
    'Wed': [
      {'time': '9:00 - 9:50', 'subject': 'Chemistry', 'room': 'Lab A'},
      {'time': '10:00 - 10:50', 'subject': 'DBMS', 'room': '201'},
    ],
    'Thu': [
      {'time': '9:00 - 9:50', 'subject': 'DBMS', 'room': '305'},
      {'time': '10:00 - 10:50', 'subject': 'AI', 'room': '205'},
    ],
    'Fri': [
      {'time': '9:00 - 9:50', 'subject': 'DSA Lab', 'room': 'C-Block'},
      {'time': '10:00 - 10:50', 'subject': 'Physics', 'room': 'Lab B'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final days = studentSchedule.keys.toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'My Timetable',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.purple.shade700,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Colors.purple.shade700,
          indicatorWeight: 3,
          tabs: days.map((day) => Tab(text: day)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: days.map((day) {
          final classes = studentSchedule[day] ?? [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                _getFullDayName(day),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ...classes.map((entry) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time,
                          color: Colors.purple.shade700, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${entry['time']}  •  ${entry['subject']} (${entry['room']})',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // 🗺️ Map icon on right side
                      InkWell(
                        onTap: () {
                          // instead of opening new page, switch to map tab (index 0)
                          widget.onNavigateToTab?.call(0);
                        },
                        child: Icon(
                          Icons.location_on_outlined,
                          color: Colors.purple.shade700,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              if (classes.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text(
                      'No classes today 🎉',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _getFullDayName(String shortDay) {
    switch (shortDay) {
      case 'Mon':
        return 'Monday';
      case 'Tue':
        return 'Tuesday';
      case 'Wed':
        return 'Wednesday';
      case 'Thu':
        return 'Thursday';
      case 'Fri':
        return 'Friday';
      default:
        return '';
    }
  }
}
