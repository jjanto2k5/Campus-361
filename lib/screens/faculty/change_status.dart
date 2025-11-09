import 'package:flutter/material.dart';

class ChangeStatusScreen extends StatefulWidget {
  const ChangeStatusScreen({Key? key}) : super(key: key);

  @override
  State<ChangeStatusScreen> createState() => _ChangeStatusScreenState();
}

class _ChangeStatusScreenState extends State<ChangeStatusScreen> {
  String? _selectedBatch;
  String? _selectedFloor;
  String? _selectedRoom;
  String? _selectedTimeSlot;

  bool _isLoading = false;

  final List<String> batches = ['CSE-A', 'CSE-B', 'CSE-C', 'CSE-D'];
  final List<String> floors = ['Ground Floor', '1st Floor', '2nd Floor', '3rd Floor'];
  final List<String> rooms = ['S101', 'S102', 'S103', 'Lab 1', 'Lab 2'];
  final List<String> timeSlots = [
    '8:00 AM – 8:50 AM',
    '9:00 AM – 9:50 AM',
    '10:00 AM – 10:50 AM',
    '11:00 AM – 11:50 AM',
    '2:00 PM – 2:50 PM'
  ];

  bool _validateFields() {
    return _selectedBatch != null &&
        _selectedFloor != null &&
        _selectedRoom != null &&
        _selectedTimeSlot != null;
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Status Updated'),
          ],
        ),
        content: const Text(
          'Your class location has been updated successfully.',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Change Status'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Gradient Header
            Container(
              margin: const EdgeInsets.only(bottom: 25),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade600, Colors.purple.shade400],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: const [
                  Icon(Icons.update, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'Update Your Current Status',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            // Dropdowns List
            Expanded(
              child: ListView(
                children: [
                  _buildDropdown(
                    label: 'Batch',
                    value: _selectedBatch,
                    items: batches,
                    onChanged: (val) => setState(() => _selectedBatch = val),
                  ),
                  _buildDropdown(
                    label: 'Floor',
                    value: _selectedFloor,
                    items: floors,
                    onChanged: (val) => setState(() => _selectedFloor = val),
                  ),
                  _buildDropdown(
                    label: 'Room Number',
                    value: _selectedRoom,
                    items: rooms,
                    onChanged: (val) => setState(() => _selectedRoom = val),
                  ),
                  _buildDropdown(
                    label: 'Time Slot',
                    value: _selectedTimeSlot,
                    items: timeSlots,
                    onChanged: (val) => setState(() => _selectedTimeSlot = val),
                  ),
                ],
              ),
            ),

            // Animated Confirm Button (Purple)
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
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            border: InputBorder.none,
          ),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
