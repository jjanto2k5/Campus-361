import 'package:flutter/material.dart';
import '../common/campus_map_main.dart'; // ✅ use the main map file

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Faculty Timetable'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Mon'),
              Tab(text: 'Tue'),
              Tab(text: 'Wed'),
              Tab(text: 'Thu'),
              Tab(text: 'Fri'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDay(context, 'Monday', [
              {'time': '9:00 - 9:50', 'subject': 'CSE-A', 'room': 'S103'},
              {'time': '10:00 - 10:50', 'subject': 'CSE-B', 'room': 'S104'},
            ]),
            _buildDay(context, 'Tuesday', [
              {'time': '9:00 - 9:50', 'subject': 'ECE-A', 'room': 'S101'},
              {'time': '10:00 - 10:50', 'subject': 'ECE-B', 'room': 'S106'},
            ]),
            _buildDay(context, 'Wednesday', [
              {'time': '9:00 - 9:50', 'subject': 'CSE-A', 'room': 'S105'},
              {'time': '10:00 - 10:50', 'subject': 'CSE-C', 'room': 'S102'},
            ]),
            _buildDay(context, 'Thursday', [
              {'time': '9:00 - 9:50', 'subject': 'CSE-D', 'room': 'S106'},
            ]),
            _buildDay(context, 'Friday', [
              {'time': '9:00 - 9:50', 'subject': 'CSE-A', 'room': 'S103'},
              {'time': '9:00 - 9:50', 'subject': 'CSE-B', 'room': 'S105'},
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildDay(BuildContext context, String day, List<Map<String, String>> classes) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          day,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...classes.map(
          (entry) => Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.schedule, color: Colors.blue),
              title: Text(
                '${entry['time']} • ${entry['subject']}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              subtitle: Text('Room: ${entry['room']}'),
              trailing: IconButton(
                icon: const Icon(Icons.location_on, color: Colors.blue),
                onPressed: () async {
                  // 🧭 Ask for faculty’s current location
                  String? selectedLocation = await showDialog<String>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Select your current location"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var room in ['S101', 'S102', 'S103', 'S104', 'S105', 'S106'])
                              ListTile(
                                title: Text(room),
                                onTap: () => Navigator.pop(context, room),
                              ),
                          ],
                        ),
                      );
                    },
                  );

                  // ✅ If selected, show path
                  if (selectedLocation != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CampusMapMainScreen(
                          startRoom: selectedLocation,
                          destinationRoom: entry['room']!,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
