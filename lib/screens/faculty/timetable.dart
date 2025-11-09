import 'package:flutter/material.dart';

class TimetableScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab; // callback to switch navbar tab

  const TimetableScreen({Key? key, this.onNavigateToTab}) : super(key: key);

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Faculty's weekly schedule (day-wise)
  final Map<String, List<Map<String, String>>> facultySchedule = {
    'Mon': [
      {'time': '9:00 - 9:50', 'batch': 'CSE-A', 'room': 'S102'},
      {'time': '11:00 - 11:50', 'batch': 'CSE-B', 'room': 'S105'},
      {'time': '2:00 - 2:50', 'batch': 'CSE-C', 'room': 'Lab-1'},
    ],
    'Tue': [
      {'time': '8:00 - 8:50', 'batch': 'CSE-A', 'room': 'S202'},
      {'time': '10:00 - 10:50', 'batch': 'CSE-D', 'room': 'Lab-3'},
    ],
    'Wed': [
      {'time': '9:00 - 9:50', 'batch': 'CSE-B', 'room': 'S105'},
      {'time': '11:00 - 11:50', 'batch': 'CSE-A', 'room': 'S102'},
    ],
    'Thu': [
      {'time': '10:00 - 10:50', 'batch': 'CSE-C', 'room': 'S110'},
      {'time': '2:00 - 2:50', 'batch': 'CSE-A', 'room': 'Lab-1'},
    ],
    'Fri': [
      {'time': '9:00 - 9:50', 'batch': 'CSE-D', 'room': 'S202'},
      {'time': '11:00 - 11:50', 'batch': 'CSE-B', 'room': 'S105'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final days = facultySchedule.keys.toList();

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
          labelColor: Colors.blue.shade700,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Colors.blue.shade700,
          indicatorWeight: 3,
          tabs: days.map((day) => Tab(text: day)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: days.map((day) {
          final sessions = facultySchedule[day] ?? [];
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
              ...sessions.map((session) {
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
                          color: Colors.blue.shade700, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${session['time']}  •  ${session['batch']} (${session['room']})',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // 🗺️ Map icon → go to Map tab
                      InkWell(
                        onTap: () {
                          widget.onNavigateToTab?.call(0); // switch to Map tab
                        },
                        child: Icon(
                          Icons.location_on_outlined,
                          color: Colors.blue.shade700,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              if (sessions.isEmpty)
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
