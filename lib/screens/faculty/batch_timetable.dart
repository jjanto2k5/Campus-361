// lib/screens/faculty/batch_timetable.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/timetable_models.dart';

class BatchTimetablePage extends StatefulWidget {
  final Batch batch;
  const BatchTimetablePage({super.key, required this.batch});

  @override
  State<BatchTimetablePage> createState() => _BatchTimetablePageState();
}

class _BatchTimetablePageState extends State<BatchTimetablePage>
    with SingleTickerProviderStateMixin {
  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday'
  ];
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

  /// Build a stream that reads documents from:
  /// /batch_timetables/{batchId}/slots
  ///
  /// Each slot doc id looks like "Friday__ts_0900_0950" and contains fields:
  /// - day (optional)
  /// - timeslotId (e.g. "ts_0900_0950")
  /// - subject
  /// - roomId
  /// ... etc
 // inside _BatchTimetablePageState

Stream<List<TimetableItem>> _stream() {
  final ref = FirebaseFirestore.instance
      .collection('batch_timetables')
      .doc(widget.batch.id)
      .collection('slots');

  return ref.snapshots().map((snap) {
    return snap.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};

      // Day
      String day = (data['day'] as String?) ?? '';
      if (day.isEmpty) {
        final parts = doc.id.split('__');
        if (parts.isNotEmpty) day = parts.first;
      }

      // Parse timeslot
      String startTime = '';
      String endTime = '';
      String? timeslotId = (data['timeslotId'] as String?) ??
          _extractTimeslotFromDocId(doc.id);

      if (timeslotId != null) {
        final parsed = _parseTimesFromTimeslotId(timeslotId);
        startTime = parsed.key;
        endTime = parsed.value;
      } else {
        final parts = doc.id.split('__');
        if (parts.length >= 2) {
          final parsed = _parseTimesFromTimeslotId(parts[1]);
          startTime = parsed.key;
          endTime = parsed.value;
        }
      }

      final subject = (data['subject'] as String?) ?? '';
      final room = (data['roomId'] as String?) ?? (data['room'] as String?) ?? '';
      final id = doc.id;

      return TimetableItem(
        id: id,
        day: day.isEmpty ? 'Monday' : day,
        startTime: startTime,
        endTime: endTime,
        subject: subject,
        room: room,
        location: null,
      );
    }).toList();
  });
}


  // Helper: try to extract a timeslot token like "ts_0900_0950" from doc id
  String? _extractTimeslotFromDocId(String docId) {
    final parts = docId.split('__');
    if (parts.length >= 2) return parts[1];
    return null;
  }

  // Helper: parse "ts_0900_0950" or "0900_0950" to ("09:00","09:50")
  // Returns a tuple-like Pair using MapEntry for simplicity.
  MapEntry<String, String> _parseTimesFromTimeslotId(String ts) {
    // normalize: remove leading "ts_" if present
    final normalized = ts.startsWith('ts_') ? ts.substring(3) : ts;
    // normalized now expected "0900_0950" or "0900-0950"
    final sep = normalized.contains('_') ? '_' : (normalized.contains('-') ? '-' : null);
    if (sep == null) return const MapEntry('', '');
    final parts = normalized.split(sep);
    if (parts.length >= 2) {
      final s = _formatHHMM(parts[0]);
      final e = _formatHHMM(parts[1]);
      return MapEntry(s, e);
    }
    return const MapEntry('', '');
  }

  // Format "0900" -> "09:00", "1230" -> "12:30"
  String _formatHHMM(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 4) {
      return '${digits.substring(0, 2)}:${digits.substring(2)}';
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
    final batch = widget.batch;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        leading: const BackButton(color: Colors.black87),
        title: Text('${batch.name} • Timetable', style: const TextStyle(color: Colors.black87)),
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
            if (grouped.containsKey(dayKey)) {
              grouped[dayKey]!.add(it);
            } else {
              grouped[dayKey] = [it];
            }
          }

          // For each day sort by startTime (empty times go last)
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
