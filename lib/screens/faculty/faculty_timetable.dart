// lib/screens/faculty/faculty_timetable.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/timetable_models.dart';

class FacultyTimetablePage extends StatefulWidget {
  final Faculty faculty;
  const FacultyTimetablePage({super.key, required this.faculty});

  @override
  State<FacultyTimetablePage> createState() => _FacultyTimetablePageState();
}

class _FacultyTimetablePageState extends State<FacultyTimetablePage>
    with SingleTickerProviderStateMixin {
  final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: days.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Build stream that reads all docs in `faculty_timetables` where facultyUid == current faculty id.
  Stream<List<TimetableItem>> _stream() {
    final ref = FirebaseFirestore.instance
        .collection('faculty_timetables')
        .where('facultyUid', isEqualTo: widget.faculty.id);

    return ref.snapshots().map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};

        // Day: prefer stored field, else try to extract from doc.id (doc id contains day)
        String day = (data['day'] as String?) ?? '';
        if (day.isEmpty) {
          final parts = doc.id.split(RegExp(r'[_\-\s]+'));
          // Try to find a weekday token inside doc id parts
          for (final p in parts) {
            final lower = p.toLowerCase();
            if (['monday','tuesday','wednesday','thursday','friday','saturday','sunday'].contains(lower)) {
              day = p;
              break;
            }
          }
        }

        // timeslotId: prefer field, else try to parse from doc id (last token often 'ts_0900_0950' or similar)
        String? timeslotId = (data['timeslotId'] as String?) ?? _extractTimeslotFromDocId(doc.id);

        final parsed = _parseTimesFromTimeslotId(timeslotId ?? '');
        final startTime = parsed.key;
        final endTime = parsed.value;

        final subject = (data['subject'] as String?) ?? (data['subjectName'] as String?) ?? '';
        final room = (data['roomId'] as String?) ?? (data['room'] as String?) ?? '';
        final batchId = (data['batchId'] as String?) ?? '';
        final id = doc.id;

        // We store subject as primary label; if you want to show batch also, you can combine them.
        final displaySubject = subject.isNotEmpty ? subject : (batchId.isNotEmpty ? batchId : 'Class');

        return TimetableItem(
          id: id,
          day: day.isNotEmpty ? day : 'Monday',
          startTime: startTime,
          endTime: endTime,
          subject: displaySubject,
          room: room,
          location: null,
        );
      }).toList();
    });
  }

  // Try to extract a timeslot token like "ts_0900_0950" from doc id
  String? _extractTimeslotFromDocId(String docId) {
    // docId examples: "ftt_ai_2027_A_Friday_ts_0900_0950"
    final parts = docId.split(RegExp(r'[_\-\s]+'));
    for (final p in parts) {
      if (p.startsWith('ts') || p.startsWith('ts_') || RegExp(r'^\d{4}_\d{4}$').hasMatch(p)) {
        return p;
      }
      // sometimes appears as "ts09000950" etc; try a loose match
      if (RegExp(r'ts[_]?\d{4}[_-]?\d{4}').hasMatch(p)) {
        return p;
      }
    }
    // if nothing found, maybe last two tokens indicate times; attempt to find pattern like "0900_0950"
    final maybe = parts.isNotEmpty ? parts.last : null;
    if (maybe != null && RegExp(r'^\d{4}_\d{4}$').hasMatch(maybe)) return maybe;
    return null;
  }

  // Parse timeslot token like "ts_0900_0950" or "0900_0950" -> MapEntry("09:00","09:50")
  MapEntry<String, String> _parseTimesFromTimeslotId(String ts) {
    if (ts.isEmpty) return const MapEntry('', '');
    var normalized = ts;
    // remove leading 'ts' or 'ts_'
    if (normalized.startsWith('ts_')) normalized = normalized.substring(3);
    else if (normalized.startsWith('ts')) normalized = normalized.substring(2);
    // replace '-' with '_' to standardize
    normalized = normalized.replaceAll('-', '_');

    // normalized expected like '0900_0950' or '0900_0950_more'
    // take first two groups of digits
    final match = RegExp(r'(\d{3,4})[_]?(\d{3,4})').firstMatch(normalized);
    if (match != null && match.groupCount >= 2) {
      final a = _formatHHMM(match.group(1) ?? '');
      final b = _formatHHMM(match.group(2) ?? '');
      return MapEntry(a, b);
    }

    // fallback: try splitting by underscore
    final parts = normalized.split('_');
    if (parts.length >= 2) {
      final s = _formatHHMM(parts[0]);
      final e = _formatHHMM(parts[1]);
      return MapEntry(s, e);
    }

    return const MapEntry('', '');
  }

  // Format "0900" -> "09:00"
  String _formatHHMM(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 4) {
      return '${digits.substring(0, 2)}:${digits.substring(2)}';
    }
    if (digits.length == 3) {
      // e.g. "900" -> "09:00"
      return '0${digits.substring(0, 1)}:${digits.substring(1)}';
    }
    return raw;
  }

  Widget _buildCard(TimetableItem t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.blueAccent)),
          child: const Icon(Icons.access_time, color: Colors.blueAccent),
        ),
        title: Text(
          '${t.startTime.isNotEmpty ? t.startTime : '--:--'} - ${t.endTime.isNotEmpty ? t.endTime : '--:--'} • ${t.subject}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text('Room: ${t.room.isNotEmpty ? t.room : 'TBA'}', style: const TextStyle(color: Colors.black54)),
        ),
        trailing: const Icon(Icons.location_on, color: Colors.blueAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final faculty = widget.faculty;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        leading: BackButton(color: Colors.black87),
        title: Text('${faculty.name} • Timetable', style: const TextStyle(color: Colors.black87)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.black54,
          tabs: days.map((d) => Tab(child: Text(d.substring(0, 3)))).toList(),
        ),
      ),
      body: StreamBuilder<List<TimetableItem>>(
        stream: _stream(),
        builder: (context, snap) {
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final items = snap.data!;

          // group by day
          final Map<String, List<TimetableItem>> grouped = {for (var d in days) d: []};
          for (var it in items) {
            final dayKey = (it.day.isNotEmpty ? it.day : 'Monday');
            if (grouped.containsKey(dayKey)) grouped[dayKey]!.add(it);
            else grouped[dayKey] = [it];
          }

          // sort each day's items by startTime (empty times go last)
          for (var d in grouped.keys) {
            grouped[d]!.sort((a, b) {
              if (a.startTime.isEmpty && b.startTime.isEmpty) return 0;
              if (a.startTime.isEmpty) return 1;
              if (b.startTime.isEmpty) return -1;
              return a.startTime.compareTo(b.startTime);
            });
          }

          return TabBarView(
            controller: _tabController,
            children: days.map((day) {
              final dayItems = grouped[day] ?? [];
              if (dayItems.isEmpty) {
                return Center(child: Text('No classes for $day', style: TextStyle(color: Colors.black54)));
              }
              return ListView(padding: const EdgeInsets.all(12), children: dayItems.map(_buildCard).toList());
            }).toList(),
          );
        },
      ),
    );
  }
}
