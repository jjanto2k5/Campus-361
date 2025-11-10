import 'package:flutter/material.dart';

// This is the main entry point for the Flutter application.
void main() {
  runApp(const ScheduleApp());
}

// The root widget of the application.
class ScheduleApp extends StatelessWidget {
  const ScheduleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Batch Schedule Viewer',
      theme: ThemeData(
        // Using Material 3 design
        useMaterial3: true,
        primarySwatch: Colors.indigo,
        // Define the overall brightness and color scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        // Style for input fields
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        // Style for elevated buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ),
      home: const SchedulePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Represents a single class period in the schedule
class ScheduleEntry {
  final String time;
  final String subject;
  final String room;

  ScheduleEntry({required this.time, required this.subject, required this.room});
}

// The main page widget, which will hold the state
class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

// The state class for SchedulePage
class _SchedulePageState extends State<SchedulePage> {
  // --- State Variables ---

  // These variables will hold the user's current selections.
  String? _selectedSchool;
  String? _selectedYear;
  String? _selectedBatch;

  // These lists will be dynamically updated based on the user's selections.
  List<String> _availableYears = [];
  List<String> _availableBatches = [];

  // This will hold the final schedule to be displayed.
  List<ScheduleEntry>? _currentSchedule;

  // Add state for the bottom navigation bar
  int _currentIndex = 0;

  // This map holds all the timetable data parsed from the PDF.
  // It's structured as: School -> Year -> Batch -> List<ScheduleEntry>
  static final Map<String, Map<String, Map<String, List<ScheduleEntry>>>>
      _allData = {
    'CSE': {
      'Year 1 (Sem 1)': {
        'A': [
          ScheduleEntry(time: '09:00-10:00', subject: 'Programming', room: 'B-101A'),
          ScheduleEntry(time: '10:15-11:15', subject: 'Discrete Math', room: 'B-103A'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Physics (PH101)', room: 'B-105A'),
        ],
        'B': [
          ScheduleEntry(time: '09:00-10:00', subject: 'Discrete Math', room: 'B-103B'),
          ScheduleEntry(time: '10:15-11:15', subject: 'Physics (PH101)', room: 'B-105B'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Programming', room: 'B-101B'),
        ],
        'C': [
          ScheduleEntry(time: '09:00-10:00', subject: 'Physics (PH101)', room: 'B-105C'),
          ScheduleEntry(time: '10:15-11:15', subject: 'Programming', room: 'B-101C'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Discrete Math', room: 'B-103C'),
        ],
        'D': [
          ScheduleEntry(time: '09:00-10:00', subject: 'Programming', room: 'B-101D'),
          ScheduleEntry(time: '10:15-11:15', subject: 'Discrete Math', room: 'B-103D'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Physics (PH101)', room: 'B-105D'),
        ],
      },
      'Year 2 (Sem 3)': {
        'A': [
          ScheduleEntry(time: '09:00-10:00', subject: 'OS (CS301)', room: 'B-301A'),
          ScheduleEntry(time: '10:15-11:15', subject: 'DBMS (CS305)', room: 'B-303A'),
          ScheduleEntry(time: '11:30-12:30', subject: 'COA (CS307)', room: 'B-305A'),
        ],
        'B': [
          ScheduleEntry(time: '09:00-10:00', subject: 'DBMS (CS305)', room: 'B-303B'),
          ScheduleEntry(time: '10:15-11:15', subject: 'COA (CS307)', room: 'B-305B'),
          ScheduleEntry(time: '11:30-12:30', subject: 'OS (CS301)', room: 'B-301B'),
        ],
        'C': [
          ScheduleEntry(time: '09:00-10:00', subject: 'COA (CS307)', room: 'B-305C'),
          ScheduleEntry(time: '10:15-11:15', subject: 'OS (CS301)', room: 'B-301C'),
          ScheduleEntry(time: '11:30-12:30', subject: 'DBMS (CS305)', room: 'B-303C'),
        ],
        'D': [
          ScheduleEntry(time: '09:00-10:00', subject: 'OS (CS301)', room: 'B-301D'),
          ScheduleEntry(time: '10:15-11:15', subject: 'DBMS (CS305)', room: 'B-303D'),
          ScheduleEntry(time: '11:30-12:30', subject: 'COA (CS307)', room: 'B-305D'),
        ],
      },
      'Year 3 (Sem 5)': {
        'A': [
          ScheduleEntry(time: '09:00-10:00', subject: 'AI Basics (CS501)', room: 'B-501A'),
          ScheduleEntry(time: '10:15-11:15', subject: 'TOC (CS505)', room: 'B-503A'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Compiler Design', room: 'B-505A'),
        ],
        'B': [
          ScheduleEntry(time: '09:00-10:00', subject: 'TOC (CS505)', room: 'B-503B'),
          ScheduleEntry(time: '10:15-11:15', subject: 'Compiler Design', room: 'B-505B'),
          ScheduleEntry(time: '11:30-12:30', subject: 'AI Basics (CS501)', room: 'B-501B'),
        ],
        'C': [
          ScheduleEntry(time: '09:00-10:00', subject: 'Compiler Design', room: 'B-505C'),
          ScheduleEntry(time: '10:15-11:15', subject: 'AI Basics (CS501)', room: 'B-501C'),
          ScheduleEntry(time: '11:30-12:30', subject: 'TOC (CS505)', room: 'B-503C'),
        ],
        'D': [
          ScheduleEntry(time: '09:00-10:00', subject: 'AI Basics (CS501)', room: 'B-501D'),
          ScheduleEntry(time: '10:15-11:15', subject: 'TOC (CS505)', room: 'B-503D'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Compiler Design', room: 'B-505D'),
        ],
      },
      'Year 4 (Sem 7)': {
        'A': [
          ScheduleEntry(time: '09:00-10:00', subject: 'Cloud (CS701)', room: 'B-701A'),
          ScheduleEntry(time: '10:15-11:15', subject: 'Security (CS703)', room: 'B-703A'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Elective I (EL705)', room: 'B-705A'),
        ],
        'B': [
          ScheduleEntry(time: '09:00-10:00', subject: 'Security (CS703)', room: 'B-703B'),
          ScheduleEntry(time: '10:15-11:15', subject: 'Elective I (EL705)', room: 'B-705B'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Cloud (CS701)', room: 'B-701B'),
        ],
        'C': [
          ScheduleEntry(time: '09:00-10:00', subject: 'Elective I (EL705)', room: 'B-705C'),
          ScheduleEntry(time: '10:15-11:15', subject: 'Cloud (CS701)', room: 'B-701C'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Security (CS703)', room: 'B-703C'),
        ],
        'D': [
          ScheduleEntry(time: '09:00-10:00', subject: 'Cloud (CS701)', room: 'B-701D'),
          ScheduleEntry(time: '10:15-11:15', subject: 'Security (CS703)', room: 'B-703D'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Elective I (EL705)', room: 'B-705D'),
        ],
      },
    },
    'EEE': {
      'Year 1 (Sem 1)': {
        'A': [
          ScheduleEntry(time: '09:00-10:00', subject: 'Basic EE (EE101)', room: 'E-101A'),
          ScheduleEntry(time: '10:15-11:15', subject: 'Math I (MA101)', room: 'E-103A'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Physics (PH101)', room: 'E-105A'),
        ],
        'B': [
          ScheduleEntry(time: '09:00-10:00', subject: 'Math I (MA101)', room: 'E-103B'),
          ScheduleEntry(time: '10:15-11:15', subject: 'Physics (PH101)', room: 'E-105B'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Basic EE (EE101)', room: 'E-101B'),
        ],
      },
      'Year 2 (Sem 3)': {
        'A': [
          ScheduleEntry(time: '09:00-10:00', subject: 'Power Sys I (EE301)', room: 'E-301A'),
          ScheduleEntry(time: '10:15-11:15', subject: 'Control Systems (EE305)', room: 'E-303A'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Analog Electronics (EE310)', room: 'E-305A'),
        ],
        'B': [
          ScheduleEntry(time: '09:00-10:00', subject: 'Control Systems (EE305)', room: 'E-303B'),
          ScheduleEntry(time: '10:15-11:15', subject: 'Analog Electronics (EE310)', room: 'E-305B'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Power Sys I (EE301)', room: 'E-301B'),
        ],
      },
      'Year 3 (Sem 5)': {
        'A': [
          ScheduleEntry(time: '09:00-10:00', subject: 'Embedded (EE501)', room: 'E-501A'),
          ScheduleEntry(time: '10:15-11:15', subject: 'Networks (EE505)', room: 'E-503A'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Mini Project (EE510)', room: 'ELab-1A'),
        ],
        'B': [
          ScheduleEntry(time: '09:00-10:00', subject: 'Networks (EE505)', room: 'E-503B'),
          ScheduleEntry(time: '10:15-11:15', subject: 'Mini Project (EE510)', room: 'ELab-1B'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Embedded (EE501)', room: 'E-501B'),
        ],
      },
      'Year 4 (Sem 7)': {
        'A': [
          ScheduleEntry(time: '09:00-10:00', subject: 'Major Project (EE701)', room: 'ELab-2A'),
          ScheduleEntry(time: '10:15-11:15', subject: 'Renewable Energy (EE705)', room: 'E-705A'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Viva (EE710)', room: 'Hall-FA'),
        ],
        'B': [
          ScheduleEntry(time: '09:00-10:00', subject: 'Renewable Energy (EE705)', room: 'E-705B'),
          ScheduleEntry(time: '10:15-11:15', subject: 'Viva (EE710)', room: 'Hall-FB'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Major Project (EE701)', room: 'ELab-2B'),
        ],
      },
    },
    'ME': {
      'Year 1 (Sem 1)': {
        'A': [
          ScheduleEntry(time: '09:00-10:00', subject: 'Mechanics (ME101)', room: 'M-101A'),
          ScheduleEntry(time: '10:15-11:15', subject: 'Graphics (ME102)', room: 'M-102A'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Workshop (ME103)', room: 'M-103A'),
        ],
        'B': [
          ScheduleEntry(time: '09:00-10:00', subject: 'Graphics (ME102)', room: 'M-102B'),
          ScheduleEntry(time: '10:15-11:15', subject: 'Workshop (ME103)', room: 'M-103B'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Mechanics (ME101)', room: 'M-101B'),
        ],
      },
      'Year 2 (Sem 3)': {
        'A': [
          ScheduleEntry(time: '09:00-10:00', subject: 'Fluid Mech (ME301)', room: 'M-301A'),
          ScheduleEntry(time: '10:15-11:15', subject: 'Machine Design (ME305)', room: 'M-305A'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Metrology (ME310)', room: 'M-310A'),
        ],
        'B': [
          ScheduleEntry(time: '09:00-10:00', subject: 'Machine Design (ME305)', room: 'M-305B'),
          ScheduleEntry(time: '10:15-11:15', subject: 'Metrology (ME310)', room: 'M-310B'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Fluid Mech (ME301)', room: 'M-301B'),
        ],
      },
      'Year 3 (Sem 5)': {
        'A': [
          ScheduleEntry(time: '09:00-10:00', subject: 'Automation (ME501)', room: 'M-501A'),
          ScheduleEntry(time: '10:15-11:15', subject: 'Elective (ME505)', room: 'M-505A'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Seminar (ME510)', room: 'M-510A'),
        ],
        'B': [
          ScheduleEntry(time: '09:00-10:00', subject: 'Elective (ME505)', room: 'M-505B'),
          ScheduleEntry(time: '10:15-11:15', subject: 'Seminar (ME510)', room: 'M-510B'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Automation (ME501)', room: 'M-501B'),
        ],
      },
      'Year 4 (Sem 7)': {
        'A': [
          ScheduleEntry(time: '09:00-10:00', subject: 'Major Project (ME701)', room: 'M-701A'),
          ScheduleEntry(time: '10:15-11:15', subject: 'Research (ME705)', room: 'M-705A'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Review (ME710)', room: 'Hall-MA'),
        ],
        'B': [
          ScheduleEntry(time: '09:00-10:00', subject: 'Research (ME705)', room: 'M-705B'),
          ScheduleEntry(time: '10:15-11:15', subject: 'Review (ME710)', room: 'Hall-MB'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Major Project (ME701)', room: 'M-701B'),
        ],
      },
    },
    'MATH': {
      'Year 1 (Sem 1)': {
        'Single': [
          ScheduleEntry(time: '09:00-10:00', subject: 'Calculus I (MA101)', room: 'Sci-101'),
          ScheduleEntry(time: '10:15-11:15', subject: 'Linear Algebra I (MA115)', room: 'Sci-115'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Tutorial (TUT101)', room: 'Sci-T1'),
        ],
      },
      'Year 2 (Sem 3)': {
        'Single': [
          ScheduleEntry(time: '09:00-10:00', subject: 'Real Analysis (MA305)', room: 'Sci-305'),
          ScheduleEntry(time: '10:15-11:15', subject: 'Numerical (MA310)', room: 'Sci-310'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Tutorial (MA315)', room: 'Sci-315'),
        ],
      },
      'Year 3 (Sem 5)': {
        'Single': [
          ScheduleEntry(time: '09:00-10:00', subject: 'Operations Research (MA505)', room: 'Sci-505'),
          ScheduleEntry(time: '10:15-11:15', subject: 'Optimization (MA510)', room: 'Sci-510'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Tutorial (MA515)', room: 'Sci-515'),
        ],
      },
      'Year 4 (Sem 7)': {
        'Single': [
          ScheduleEntry(time: '09:00-10:00', subject: 'Seminar (MA705)', room: 'Sci-705'),
          ScheduleEntry(time: '10:15-11:15', subject: 'Research (MA710)', room: 'Sci-710'),
          ScheduleEntry(time: '11:30-12:30', subject: 'Presentation (MA715)', room: 'Sci-715'),
        ],
      },
    },
  };

  // --- State Update Functions ---

  /// Updates the list of available years when a school is selected.
  /// Resets the year, batch, and schedule.
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

  /// Updates the list of available batches when a year is selected.
  /// Resets the batch and schedule.
  void _onYearSelected(String? newYear) {
    if (newYear != null &&
        newYear != _selectedYear &&
        _selectedSchool != null) {
      setState(() {
        _selectedYear = newYear;
        _availableBatches =
            _allData[_selectedSchool]?[newYear]?.keys.toList() ?? [];
        _selectedBatch = null;
        _currentSchedule = null;
      });
    }
  }

  /// Updates the selected batch.
  /// Reses the schedule.
  void _onBatchSelected(String? newBatch) {
    if (newBatch != null && newBatch != _selectedBatch) {
      setState(() {
        _selectedBatch = newBatch;
        _currentSchedule = null;
      });
    }
  }

  /// Called when the "Go" button is pressed.
  /// Fetches the schedule based on the current selections.
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

  // --- Build Method ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Schedule Viewer'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Dropdown for School ---
            _buildDropdown(
              hint: 'Select School',
              value: _selectedSchool,
              items: _allData.keys.toList(),
              onChanged: _onSchoolSelected,
            ),
            const SizedBox(height: 16),

            // --- Dropdown for Year ---
            _buildDropdown(
              hint: 'Select Year',
              value: _selectedYear,
              // Disable if no school is selected
              items: _availableYears,
              onChanged: _availableYears.isEmpty ? null : _onYearSelected,
            ),
            const SizedBox(height: 16),

            // --- Dropdown for Batch ---
            _buildDropdown(
              hint: 'Select Batch/Division',
              value: _selectedBatch,
              // Disable if no year is selected
              items: _availableBatches,
              onChanged: _availableBatches.isEmpty ? null : _onBatchSelected,
            ),
            const SizedBox(height: 24),

            // --- "Go" Button ---
            ElevatedButton(
              // Disable if any selection is missing
              onPressed: (_selectedSchool == null ||
                      _selectedYear == null ||
                      _selectedBatch == null)
                  ? null
                  : _fetchSchedule,
              child: const Text('Go'),
            ),
            const SizedBox(height: 24),
            
            // --- Divider ---
            const Divider(thickness: 1.5),
            const SizedBox(height: 16),
            
            // --- Schedule Display Area ---
            if (_currentSchedule != null)
              _buildScheduleTitle(),
              
            Expanded(
              child: _buildScheduleView(),
            ),
          ],
        ),
      ),
      // --- Add Bottom Navigation Bar ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Handle navigation logic here
          // For now, just show a snackbar for Map and SOS
          if (index == 1) {
            // Placeholder for Map page navigation
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Map page not implemented yet.'),
                duration: Duration(seconds: 1),
              ),
            );
          } else if (index == 2) {
            // Placeholder for SOS page navigation
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('SOS page not implemented yet.'),
                duration: Duration(seconds: 1),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sos),
            label: 'SOS',
          ),
        ],
        // Optional: style the navigation bar
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
      ),
    );
  }

  /// A helper widget to build the dropdown buttons consistently.
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
        // Disable the field visually if onChanged is null
        filled: onChanged == null,
        fillColor: onChanged == null ? Colors.grey[200] : Colors.grey[50],
      ),
      // Disable the dropdown functionality if onChanged is null
      disabledHint: Text(onChanged == null ? 'Please make a prior selection' : hint),
    );
  }

  /// Builds the title for the displayed schedule.
  Widget _buildScheduleTitle() {
    // This widget only shows if _currentSchedule is not null.
    // The "!" (null assertion) is safe here.
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        'Schedule for $_selectedSchool - $_selectedYear - Batch $_selectedBatch',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Builds the view to display the schedule (or a placeholder message).
  Widget _buildScheduleView() {
    if (_currentSchedule == null) {
      // Show this message if the "Go" button hasn't been pressed yet.
      return const Center(
        child: Text(
          'Please make your selections and press "Go" to see the schedule.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_currentSchedule!.isEmpty) {
      // Show this if data is missing (shouldn't happen with current data)
      return const Center(
        child: Text(
          'No schedule found for this selection.',
          style: TextStyle(fontSize: 16, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Display the schedule in a clean DataTable
    return SingleChildScrollView(
      child: DataTable(
        // Style the header
        headingRowColor: MaterialStateProperty.all(Colors.indigo[50]),
        headingTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        border: TableBorder.all(
          color: Colors.grey[300]!,
          borderRadius: BorderRadius.circular(8),
        ),
        columns: const [
          DataColumn(label: Text('Time')),
          DataColumn(label: Text('Subject')),
          DataColumn(label: Text('Room')),
        ],
        rows: _currentSchedule!.map((entry) {
          // Create a row for each entry in the schedule
          return DataRow(cells: [
            DataCell(Text(entry.time)),
            DataCell(Text(entry.subject)),
            DataCell(Text(entry.room)),
          ]);
        }).toList(),
      ),
    );
  }
}
