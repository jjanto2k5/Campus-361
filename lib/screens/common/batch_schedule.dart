import 'package:flutter/material.dart';

/// ✅ Unified Batch Timetable screen for both Faculty and Student dashboards
class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  String? _selectedSchool;
  String? _selectedYear;
  String? _selectedBatch;

  List<String> _availableYears = [];
  List<String> _availableBatches = [];
  List<ScheduleEntry>? _currentSchedule;

  // --- Removed _currentIndex variable ---

  /// Sample Data Map (School → Year → Batch → Schedule)
  static final Map<String, Map<String, Map<String, List<ScheduleEntry>>>>
      _allData = {
    'CSE': {
      'Year 1 (Sem 1)': {
        'A': [
          ScheduleEntry(
              time: '09:00-10:00', subject: 'Programming', room: 'B-101A'),
          ScheduleEntry(time: '10:15-11:15', subject: 'Math I', room: 'B-103A'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Physics', room: 'B-105A'),
        ],
        'B': [
          ScheduleEntry(time: '09:00-10:00', subject: 'Math I', room: 'B-103B'),
          ScheduleEntry(
              time: '10:15-11:15', subject: 'Physics', room: 'B-105B'),
          ScheduleEntry(
              time: '11:30-12:30', subject: 'Programming', room: 'B-101B'),
        ],
      },
      'Year 2 (Sem 3)': {
        'A': [
          ScheduleEntry(
              time: '09:00-10:00', subject: 'OS (CS301)', room: 'B-301A'),
          ScheduleEntry(
              time: '10:15-11:15', subject: 'DBMS (CS305)', room: 'B-303A'),
          ScheduleEntry(
              time: '11:30-12:30', subject: 'COA (CS307)', room: 'B-305A'),
        ],
        'B': [
          ScheduleEntry(
              time: '09:00-10:00', subject: 'DBMS (CS305)', room: 'B-303B'),
          ScheduleEntry(
              time: '10:15-11:15', subject: 'COA (CS307)', room: 'B-305B'),
          ScheduleEntry(
              time: '11:30-12:30', subject: 'OS (CS301)', room: 'B-301B'),
        ],
      },
    },
    'EEE': {
      'Year 1 (Sem 1)': {
        'A': [
          ScheduleEntry(
              time: '09:00-10:00', subject: 'Basic EE', room: 'E-101A'),
          ScheduleEntry(time: '10:15-11:15', subject: 'Math I', room: 'E-103A'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Physics', room: 'E-105A'),
        ],
      },
    },
    'ME': {
      'Year 1 (Sem 1)': {
        'A': [
          ScheduleEntry(
              time: '09:00-10:00', subject: 'Mechanics', room: 'M-101A'),
          ScheduleEntry(
              time: '10:15-11:15', subject: 'Graphics', room: 'M-102A'),
          ScheduleEntry(
              time: '11:30-12:30', subject: 'Workshop', room: 'M-103A'),
        ],
      },
    },
  };

  /// Dropdown logic
  void _onSchoolSelected(String? newSchool) {
    if (newSchool != null && newSchool != _selectedSchool) {
      setState(() {
        _selectedSchool = newSchool;
        _availableYears = _allData[newSchool]?.keys.toList() ?? [];
        _selectedYear = null;
        _availableBatches = [];
        _selectedBatch = null;
        _currentSchedule = null;
      });
    }
  }

  void _onYearSelected(String? newYear) {
    if (newYear != null && newYear != _selectedYear && _selectedSchool != null) {
      setState(() {
        _selectedYear = newYear;
        _availableBatches =
            _allData[_selectedSchool]?[newYear]?.keys.toList() ?? [];
        _selectedBatch = null;
        _currentSchedule = null;
      });
    }
  }

  void _onBatchSelected(String? newBatch) {
    if (newBatch != null && newBatch != _selectedBatch) {
      setState(() {
        _selectedBatch = newBatch;
        _currentSchedule = null;
      });
    }
  }

  void _fetchSchedule() {
    if (_selectedSchool != null &&
        _selectedYear != null &&
        _selectedBatch != null) {
      setState(() {
        _currentSchedule =
            _allData[_selectedSchool]?[_selectedYear]?[_selectedBatch];
      });
    }
  }

  /// Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Batch Timetable',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDropdown(
              hint: 'Select School',
              value: _selectedSchool,
              items: _allData.keys.toList(),
              onChanged: _onSchoolSelected,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              hint: 'Select Year',
              value: _selectedYear,
              items: _availableYears,
              onChanged: _availableYears.isEmpty ? null : _onYearSelected,
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              hint: 'Select Batch',
              value: _selectedBatch,
              items: _availableBatches,
              onChanged: _availableBatches.isEmpty ? null : _onBatchSelected,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: (_selectedSchool == null ||
                      _selectedYear == null ||
                      _selectedBatch == null)
                  ? null
                  : _fetchSchedule,
              icon: const Icon(Icons.table_chart_outlined),
              label: const Text('Show Timetable'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1.5),
            const SizedBox(height: 10),
            if (_currentSchedule != null) _buildScheduleTitle(),
            Expanded(child: _buildScheduleView()),
          ],
        ),
      ),
      // --- Removed BottomNavigationBar from here ---
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?)? onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint),
      isExpanded: true,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }

  Widget _buildScheduleTitle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        'Schedule for $_selectedSchool • $_selectedYear • Batch $_selectedBatch',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildScheduleView() {
    if (_currentSchedule == null) {
      return const Center(
        child: Text(
          'Select options above and tap "Show Timetable".',
          style: TextStyle(color: Colors.grey, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (_currentSchedule!.isEmpty) {
      return const Center(
        child: Text(
          'No data available.',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
    return SingleChildScrollView(
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.indigo.shade50),
        columns: const [
          DataColumn(label: Text('Time')),
          DataColumn(label: Text('Subject')),
          DataColumn(label:Text('Room')),
        ],
        rows: _currentSchedule!.map((e) {
          return DataRow(cells: [
            DataCell(Text(e.time)),
            DataCell(Text(e.subject)),
            DataCell(Text(e.room)),
          ]);
        }).toList(),
      ),
    );
  }
}

/// Model class for each schedule entry
class ScheduleEntry {
  final String time;
  final String subject;
  final String room;
  const ScheduleEntry({
    required this.time,
    required this.subject,
    required this.room,
  });
}