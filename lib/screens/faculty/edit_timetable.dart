// lib/screens/faculty/edit_timetable.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditTimetableScreen extends StatefulWidget {
  const EditTimetableScreen({Key? key}) : super(key: key);

  @override
  State<EditTimetableScreen> createState() => _EditTimetableScreenState();
}

class _EditTimetableScreenState extends State<EditTimetableScreen> {
  // selections
  int? selectedPassoutYear; // 2027 or 2028
  String? selectedSchool; // 'Arts','Computing','Engineering'
  String? selectedProgram; // e.g. 'ai', 'cse', 'english'
  String? selectedDivision; // e.g. 'A'
  String? selectedDay;
  String? selectedTimeSlot;

  // faculty + payload
  String? selectedFacultyUid;
  String? selectedFacultyName;
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController roomController = TextEditingController();

  bool _isSaving = false;

  final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  final List<String> timeSlots = [
    '09:00 – 09:50',
    '09:50 – 10:40',
    '10:50 – 11:40',
    '11:40 – 12:30',
    '12:30 – 13:20',
    '13:20 – 14:10',
    '14:10 – 15:00',
    '15:10 – 16:00',
    '16:00 – 16:50'
  ];
  final List<int> passoutYears = [2027, 2028];
  final List<String> schools = ['Arts', 'Computing', 'Engineering'];

  @override
  void dispose() {
    subjectController.dispose();
    roomController.dispose();
    super.dispose();
  }

  // Convert human slot to timeslotId like ts_0900_0950
String _timeslotIdFromLabel(String label) {
  // Extract only digit groups e.g. from "16:00 – 16:50" -> ['16','00','16','50']
  final parts = label.replaceAll(RegExp(r'[^0-9]'), ' ').split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();

  String startRaw = '';
  String endRaw = '';

  if (parts.length >= 4) {
    // e.g. ['16','00','16','50'] -> startRaw='1600', endRaw='1650'
    startRaw = parts[0] + parts[1];
    endRaw = parts[2] + parts[3];
  } else if (parts.length == 2) {
    // e.g. ['0900','0950'] (less common) -> startRaw='0900', endRaw='0950'
    startRaw = parts[0];
    endRaw = parts[1];
  } else if (parts.length == 3) {
    // e.g. ['9','00','50'] -> try to join first two for start, last for end
    startRaw = parts[0] + parts[1];
    endRaw = parts[2];
  } else if (parts.length == 1) {
    // single chunk (unlikely) treat as start and leave end unknown
    startRaw = parts[0];
    endRaw = '';
  }

  // normalize to 4-digit HHMM strings
  startRaw = startRaw.padLeft(4, '0');
  endRaw = endRaw.padLeft(4, '0');

  // final id format e.g. 'ts_1600_1650'
  return 'ts_${startRaw}_${endRaw}';
}


  // compute batchId like ai_2027_A (program lowercase, year, division uppercase)
  String _computedBatchId() {
    if (selectedProgram == null || selectedPassoutYear == null || selectedDivision == null) return '';
    final prog = selectedProgram!.toLowerCase();
    final yr = selectedPassoutYear!.toString();
    final div = selectedDivision!;
    return '${prog}_${yr}_$div';
  }

  bool _validateFields() {
    return selectedPassoutYear != null &&
        selectedSchool != null &&
        selectedProgram != null &&
        selectedDivision != null &&
        selectedDay != null &&
        selectedTimeSlot != null &&
        selectedFacultyUid != null &&
        subjectController.text.trim().isNotEmpty &&
        roomController.text.trim().isNotEmpty;
  }

  /// ---------- CORE: apply update with correct structure & field names ----------
   /// ---------- CORE: apply update with overwrite confirmation ----------
  Future<void> _applyUpdate() async {
    if (!_validateFields()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill all fields before confirming.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final day = selectedDay!;
      final timeslotId = _timeslotIdFromLabel(selectedTimeSlot!); // ts_0900_0950
      final batchId = _computedBatchId(); // ai_2027_A
      final subject = subjectController.text.trim();
      final roomId = roomController.text.trim().toLowerCase(); // match screenshot 's105'
      final facultyUid = selectedFacultyUid!;
      final facultyName = selectedFacultyName ?? '';

      // doc ids
      final batchSlotDocId = '${day}__${timeslotId}';
      final facultyDocId = 'ftt_${batchId}_${day}_${timeslotId}';

      final now = FieldValue.serverTimestamp();

      // data maps (exact fields as required by your schema)
      final batchSlotData = <String, dynamic>{
        'id': batchSlotDocId,
        'batchId': batchId,
        'day': day,
        'timeslotId': timeslotId,
        'subject': subject,
        'roomId': roomId,
        'facultyUId': facultyUid, // note capital I in batch slot
        'facultyName': facultyName,
        'updatedAt': now,
      };

      final facultyTtData = <String, dynamic>{
        'id': facultyDocId,
        'batchId': batchId,
        'day': day,
        'timeslotId': timeslotId,
        'subject': subject,
        'roomId': roomId,
        'facultyUid': facultyUid, // lowercase uid for faculty_timetables
        'facultyName': facultyName,
        'recurrence': 'weekly',
        'updatedAt': now,
      };

      final firestore = FirebaseFirestore.instance;

      // ensure parent batch doc exists
      final batchDocRef = firestore.collection('batch_timetables').doc(batchId);
      await batchDocRef.set({'id': batchId}, SetOptions(merge: true));

      // references
      final batchSlotRef = batchDocRef.collection('slots').doc(batchSlotDocId);
      final facultyRef = firestore.collection('faculty_timetables').doc(facultyDocId);

      // check existing slot
      final existingSlotSnap = await batchSlotRef.get();

      if (existingSlotSnap.exists) {
        // existing data (to find previous batchId / timeslot / faculty doc if needed)
        final existingData = existingSlotSnap.data() as Map<String, dynamic>? ?? {};

        // show confirmation dialog to user
        final confirmed = await _confirmOverwrite(context);
        if (!confirmed) {
          setState(() => _isSaving = false);
          return; // user cancelled
        }

        // If confirmed -> delete existing slot doc first
        await batchSlotRef.delete();

        // Determine previous batchId (if the slot doc had another batchId)
        final prevBatchId = (existingData['batchId'] as String?) ?? batchId;
        final prevTimeslotId = (existingData['timeslotId'] as String?) ?? timeslotId;
        final prevDay = (existingData['day'] as String?) ?? day;

        // Construct previous faculty timetable doc id (if present)
        final prevFacultyDocId = 'ftt_${prevBatchId}_${prevDay}_${prevTimeslotId}';

        // Delete the previous faculty_timetable doc if it exists (to avoid stale assignment)
        final prevFacultyRef = firestore.collection('faculty_timetables').doc(prevFacultyDocId);
        final prevSnap = await prevFacultyRef.get();
        if (prevSnap.exists) {
          await prevFacultyRef.delete();
        }

        // Now write new batch slot and faculty tt docs
        await batchSlotRef.set(batchSlotData, SetOptions(merge: true));
        await facultyRef.set(facultyTtData, SetOptions(merge: true));
      } else {
        // not existing, just write normally
        await batchSlotRef.set(batchSlotData, SetOptions(merge: true));
        await facultyRef.set(facultyTtData, SetOptions(merge: true));
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Timetable updated successfully.'),
        backgroundColor: Colors.green,
      ));
      setState(() => _isSaving = false);
    } catch (e, st) {
      setState(() => _isSaving = false);
      debugPrint('Error updating timetable: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update timetable: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  // Helper: show confirm dialog and return true if user confirms overwrite
  Future<bool> _confirmOverwrite(BuildContext ctx) async {
    return await showDialog<bool>(
          context: ctx,
          barrierDismissible: false,
          builder: (dctx) {
            return AlertDialog(
              title: const Text('Overwrite existing slot?'),
              content: const Text('A slot already exists at this day & time. Do you want to overwrite it? This will remove the existing assignment and replace it.'),
              actions: [
                TextButton(onPressed: () => Navigator.of(dctx).pop(false), child: const Text('Cancel')),
                ElevatedButton(onPressed: () => Navigator.of(dctx).pop(true), child: const Text('Overwrite')),
              ],
            );
          },
        ) ??
        false;
  }


  // UI builder for generic dropdowns
  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            hint: Text('Select $label'),
            items: items,
            onChanged: onChanged,
          ),
        ),
      ]),
    );
  }

  // faculty dropdown (stream)
  Widget _buildFacultyDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Faculty', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'faculty').orderBy('name').snapshots(),
            builder: (context, snap) {
              if (snap.hasError) return const SizedBox(height: 56, child: Center(child: Text('Error loading faculties')));
              if (!snap.hasData) return const SizedBox(height: 56, child: Center(child: CircularProgressIndicator()));
              final docs = snap.data!.docs;
              final items = docs.map((d) {
                final data = d.data() as Map<String, dynamic>? ?? {};
                final name = (data['name'] as String?) ?? d.id;
                final uid = d.id;
                return MapEntry(uid, name);
              }).toList();
              return DropdownButton<String>(
                value: selectedFacultyUid,
                isExpanded: true,
                underline: const SizedBox(),
                hint: const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text('Select Faculty')),
                items: items.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                onChanged: (val) {
                  final name = items.firstWhere((x) => x.key == val).value;
                  setState(() {
                    selectedFacultyUid = val;
                    selectedFacultyName = name;
                  });
                },
              );
            },
          ),
        ),
      ]),
    );
  }

  // prefetch batches stream when passout year selected
  Stream<QuerySnapshot>? get _batchesStream {
    if (selectedPassoutYear == null) return null;
    return FirebaseFirestore.instance.collection('batches').where('passoutYear', isEqualTo: selectedPassoutYear).snapshots();
  }

  // map displayed school -> expected schoolId in DB (lowercase)
  String _schoolIdFromLabel(String label) => label.toLowerCase();

  // From fetched batch docs (passoutYear filtered), compute available programs for selectedSchool
  List<String> _extractProgramsFromDocs(List<QueryDocumentSnapshot> docs, String? schoolId) {
    final set = <String>{};
    for (final d in docs) {
      final data = d.data() as Map<String, dynamic>? ?? {};
      final docSchool = (data['schoolId'] as String?) ?? '';
      if (schoolId != null && docSchool.toLowerCase() != schoolId.toLowerCase()) continue;
      final id = d.id;
      final prog = id.split(RegExp(r'[_\-\s]+')).first.toLowerCase();
      if (prog.isNotEmpty) set.add(prog);
    }
    final list = set.toList()..sort();
    return list;
  }

  // Given program, produce divisions available
  List<String> _extractDivisionsForProgram(List<QueryDocumentSnapshot> docs, String program, String? schoolId) {
    final set = <String>{};
    for (final d in docs) {
      final data = d.data() as Map<String, dynamic>? ?? {};
      final docSchool = (data['schoolId'] as String?) ?? '';
      if (schoolId != null && docSchool.toLowerCase() != schoolId.toLowerCase()) continue;
      final id = d.id;
      final parts = id.split(RegExp(r'[_\-\s]+'));
      if (parts.isEmpty) continue;
      final prog = parts[0].toLowerCase();
      if (prog != program.toLowerCase()) continue;
      final divField = (data['division'] as String?) ?? (parts.length >= 3 ? parts[2] : null);
      if (divField != null && divField.isNotEmpty) set.add(divField.toUpperCase());
    }
    final list = set.toList()..sort();
    return list;
  }

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
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(children: [
                  // passout year
                  _buildDropdown<int>(
                    label: 'Passout Year',
                    value: selectedPassoutYear,
                    items: passoutYears.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
                    onChanged: (v) {
                      setState(() {
                        selectedPassoutYear = v;
                        selectedSchool = null;
                        selectedProgram = null;
                        selectedDivision = null;
                      });
                    },
                  ),

                  // school dropdown
                  _buildDropdown<String>(
                    label: 'School',
                    value: selectedSchool,
                    items: schools.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) {
                      setState(() {
                        selectedSchool = v;
                        selectedProgram = null;
                        selectedDivision = null;
                      });
                    },
                  ),

                  const SizedBox(height: 8),

                  if (_batchesStream == null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('Select Passout Year to load batches', style: TextStyle(color: Colors.grey[600])),
                    )
                  else
                    StreamBuilder<QuerySnapshot>(
                      stream: _batchesStream,
                      builder: (context, snap) {
                        if (snap.hasError) return Padding(padding: const EdgeInsets.all(8.0), child: Text('Error loading batches: ${snap.error}', style: TextStyle(color: Colors.red)));
                        if (!snap.hasData) return const Padding(padding: EdgeInsets.all(8.0), child: Center(child: CircularProgressIndicator()));
                        final docs = snap.data!.docs;

                        final schoolId = selectedSchool == null ? null : _schoolIdFromLabel(selectedSchool!);
                        final programs = _extractProgramsFromDocs(docs, schoolId);

                        final programItems = programs.map((p) => DropdownMenuItem(value: p, child: Text(p.toUpperCase()))).toList();

                        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _buildDropdown<String>(
                            label: 'Batch (program)',
                            value: selectedProgram,
                            items: programItems,
                            onChanged: (v) {
                              setState(() {
                                selectedProgram = v;
                                selectedDivision = null;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          if (selectedProgram == null)
                            Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text('Select a batch program to see divisions', style: TextStyle(color: Colors.grey[600])))
                          else
                            Builder(builder: (ctx) {
                              final divisions = _extractDivisionsForProgram(docs, selectedProgram!, schoolId);
                              final divisionItems = divisions.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList();
                              return _buildDropdown<String>(
                                label: 'Division',
                                value: selectedDivision,
                                items: divisionItems,
                                onChanged: (v) => setState(() => selectedDivision = v),
                              );
                            }),
                        ]);
                      },
                    ),

                  const SizedBox(height: 10),

                  // Day dropdown
                  _buildDropdown<String>(
                    label: 'Day',
                    value: selectedDay,
                    items: days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (v) => setState(() => selectedDay = v),
                  ),

                  // Time slot dropdown
                  _buildDropdown<String>(
                    label: 'Time Slot',
                    value: selectedTimeSlot,
                    items: timeSlots.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setState(() => selectedTimeSlot = v),
                  ),

                  const SizedBox(height: 8),

                  // Faculty selector
                  _buildFacultyDropdown(),

                  const SizedBox(height: 8),

                  // Subject and room
                  _buildTextField(label: 'Subject', controller: subjectController, hint: 'Enter subject name'),
                  const SizedBox(height: 8),
                  _buildTextField(label: 'Room', controller: roomController, hint: 'Enter room id (e.g. S105)'),

                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Computed batch id: ${_computedBatchId().isEmpty ? '(incomplete)' : _computedBatchId()}', style: TextStyle(color: Colors.grey[600])),
                  ),
                ]),
              ),
            ),

            // Confirm button fixed bottom
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _applyUpdate,
                child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('Confirm'),
              ),
            ),
            const SizedBox(height: 10),
          ]),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, String? hint}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600, fontSize: 15)),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(border: InputBorder.none, hintText: hint),
        ),
      ),
    ]);
  }
}
