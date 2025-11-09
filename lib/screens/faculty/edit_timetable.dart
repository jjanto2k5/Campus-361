import 'package:flutter/material.dart';

class EditTimetableScreen extends StatefulWidget {
  const EditTimetableScreen({Key? key}) : super(key: key);

  @override
  State<EditTimetableScreen> createState() => _EditTimetableScreenState();
}

class _EditTimetableScreenState extends State<EditTimetableScreen> {
  String? selectedAcademicYear;
  String? selectedDay;
  String? selectedTimeSlot;
  String? selectedYear;
  String? selectedSchool;
  String? selectedBatch;
  String? selectedDivision;

  final List<String> academicYears = ['2024–2025', '2025–2026', '2026–2027','2027-2028'];
  final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  final List<String> timeSlots = [
  '9:00 – 9:50',
  '9:50 – 10:40',
  '10:50–11:40',
  '11:40–12:30',
    '12:30–1:20',
    ' 1:20–2:10',
    ' 2:10–3:00',
    ' 3:10-4:00',
    ' 4:00-4:50'
  ];
  final List<String> years = ['2027', '2028', '2029', ];
  final List<String> schools = ['ASC', 'ASE',];
  final List<String> batches = ['CSE', 'ECE', 'EEE', 'ME','PHYSICS',];
  final List<String> divisions = ['A', 'B', 'C','D'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Timetable'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // tighter layout
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildDropdownField(
                        label: 'Academic Year',
                        value: selectedAcademicYear,
                        items: academicYears,
                        onChanged: (val) =>
                            setState(() => selectedAcademicYear = val),
                      ),
                      _buildDropdownField(
                        label: 'Day',
                        value: selectedDay,
                        items: days,
                        onChanged: (val) =>
                            setState(() => selectedDay = val),
                      ),
                      _buildDropdownField(
                        label: 'Time Slot',
                        value: selectedTimeSlot,
                        items: timeSlots,
                        onChanged: (val) =>
                            setState(() => selectedTimeSlot = val),
                      ),
                      _buildDropdownField(
                        label: 'Year (Student Batch)',
                        value: selectedYear,
                        items: years,
                        onChanged: (val) =>
                            setState(() => selectedYear = val),
                      ),
                      _buildDropdownField(
                        label: 'School',
                        value: selectedSchool,
                        items: schools,
                        onChanged: (val) =>
                            setState(() => selectedSchool = val),
                      ),
                      _buildDropdownField(
                        label: 'Batch',
                        value: selectedBatch,
                        items: batches,
                        onChanged: (val) =>
                            setState(() => selectedBatch = val),
                      ),
                      _buildDropdownField(
                        label: 'Division',
                        value: selectedDivision,
                        items: divisions,
                        onChanged: (val) =>
                            setState(() => selectedDivision = val),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),

              // Confirm Button fixed at bottom
              SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_validateFields()) {
                    _showSuccessDialog(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill all fields before confirming.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
                child: const Text('Confirm'),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    ),
   );
  }
  

  bool _validateFields() {
    return selectedAcademicYear != null &&
        selectedDay != null &&
        selectedTimeSlot != null &&
        selectedYear != null &&
        selectedSchool != null &&
        selectedBatch != null &&
        selectedDivision != null;
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.green, size: 70),
                const SizedBox(height: 15),
                const Text(
                  'Success!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Timetable updated successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // close dialog
                    Navigator.pop(context); // back to dashboard
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0), // tighter spacing
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              value: value,
              hint: Text('Select $label'),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
