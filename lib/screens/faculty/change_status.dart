// lib/screens/faculty/change_status.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/local_user.dart';

class ChangeStatusScreen extends StatefulWidget {
  const ChangeStatusScreen({Key? key}) : super(key: key);

  @override
  State<ChangeStatusScreen> createState() => _ChangeStatusScreenState();
}

class _ChangeStatusScreenState extends State<ChangeStatusScreen> {
  String? _selectedDay;
  String? _selectedTimeSlot;
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  bool _isLoading = false;
  LocalUser? _localUser;

  final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  final List<String> timeSlots = [
    '08:00 – 08:50',
    '09:00 – 09:50',
    '10:00 – 10:50',
    '11:00 – 11:50',
    '14:00 – 14:50',
    '15:10 – 16:00',
    '16:00 – 16:50',
  ];

  @override
  void initState() {
    super.initState();
    _loadLocalUser();
  }

  Future<void> _loadLocalUser() async {
    final u = await LocalUserStore.load();
    if (u == null) {
      // no local user — navigate to login (adjust route if needed)
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    if (mounted) setState(() => _localUser = u);
  }

  // robust timeslot id parser (e.g. "16:00 – 16:50" -> ts_1600_1650)
  String _timeslotIdFromLabel(String label) {
    final parts = label.replaceAll(RegExp(r'[^0-9]'), ' ').split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    String startRaw = '', endRaw = '';
    if (parts.length >= 4) {
      startRaw = parts[0] + parts[1];
      endRaw = parts[2] + parts[3];
    } else if (parts.length == 2) {
      startRaw = parts[0];
      endRaw = parts[1];
    } else if (parts.length == 3) {
      startRaw = parts[0] + parts[1];
      endRaw = parts[2];
    } else if (parts.length == 1) {
      startRaw = parts[0];
      endRaw = '';
    }
    startRaw = startRaw.padLeft(4, '0');
    endRaw = endRaw.padLeft(4, '0');
    return 'ts_${startRaw}_${endRaw}';
  }

  bool _validateFields() {
    return _selectedDay != null && _selectedTimeSlot != null && _roomController.text.trim().isNotEmpty;
  }

  Future<void> _submitStatusChange() async {
    if (_localUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No local user found')));
      return;
    }
    if (!_validateFields()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill required fields')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final facultyUid = _localUser!.uid;
      final facultyName = _localUser!.name;
      final day = _selectedDay!;
      final timeslotId = _timeslotIdFromLabel(_selectedTimeSlot!);
      final newRoom = _roomController.text.trim();
      final reason = _reasonController.text.trim();

      // find oldRoomId from faculty_timetables collection if exists
      String oldRoomId = '';
      final ftq = await FirebaseFirestore.instance
          .collection('faculty_timetables')
          .where('facultyUid', isEqualTo: facultyUid)
          .where('day', isEqualTo: day)
          .where('timeslotId', isEqualTo: timeslotId)
          .limit(1)
          .get();

      if (ftq.docs.isNotEmpty) {
        final data = ftq.docs.first.data();
        if (data.containsKey('roomId')) oldRoomId = (data['roomId'] ?? '') as String;
      }

      final statusChangeData = {
        'createdAt': FieldValue.serverTimestamp(),
        'effectiveAt': FieldValue.serverTimestamp(),
        'day': day,
        'timeslotId': timeslotId,
        'facultyName': facultyName,
        'facultyUid': facultyUid,
        'oldRoomId': oldRoomId,
        'newRoomId': newRoom,
        'reason': reason,
      };

      // write status change (auto-id)
      await FirebaseFirestore.instance.collection('status_changes').add(statusChangeData);

      // update quick lookup document active_status/{uid}
      await FirebaseFirestore.instance.collection('active_status').doc(facultyUid).set({
        'roomId': newRoom,
        'updatedAt': FieldValue.serverTimestamp(),
        'reason': reason,
        'timeslotId': timeslotId,
      }, SetOptions(merge: true));

      if (!mounted) return;
      setState(() => _isLoading = false);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(children: const [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 8), Text('Status Updated')]),
          content: Text('Status updated successfully.\n\nOld room: ${oldRoomId.isEmpty ? 'unknown' : oldRoomId}\nNew room: $newRoom'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
          ],
        ),
      );
    } catch (e, st) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint('Error saving status change: $e\n$st');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  void dispose() {
    _roomController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Change Status'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (_localUser != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Center(child: Text(_localUser!.name, style: const TextStyle(color: Colors.black87))),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // header
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.purple.shade600, Colors.purple.shade400]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.update, color: Colors.white),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Update your temporary location (status) for a class slot',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                children: [
                  // Day
                  _buildDropdown(
                    label: 'Day',
                    value: _selectedDay,
                    items: days,
                    onChanged: (v) => setState(() => _selectedDay = v),
                  ),

                  // Time slot
                  _buildDropdown(
                    label: 'Time Slot',
                    value: _selectedTimeSlot,
                    items: timeSlots,
                    onChanged: (v) => setState(() => _selectedTimeSlot = v),
                  ),

                  // Room (required)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Room Number', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextFormField(controller: _roomController, decoration: const InputDecoration(border: InputBorder.none, hintText: 'e.g. S102')),
                      )
                    ]),
                  ),

                  // Reason (optional)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Reason (optional)', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextFormField(controller: _reasonController, decoration: const InputDecoration(border: InputBorder.none, hintText: 'e.g. Meeting with HOD')),
                      ),
                    ]),
                  ),
                ],
              ),
            ),

            // Confirm
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitStatusChange,
                child: _isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Confirm'),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({required String label, required String? value, required List<String> items, required void Function(String?) onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.12), blurRadius: 4, offset: const Offset(0, 2))]),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87), border: InputBorder.none),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
