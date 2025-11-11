// lib/screens/faculty/batch_search.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/timetable_models.dart';
import 'batch_timetable.dart';

class BatchSearchPage extends StatefulWidget {
  const BatchSearchPage({super.key});

  @override
  State<BatchSearchPage> createState() => _BatchSearchPageState();
}

class _BatchSearchPageState extends State<BatchSearchPage> {
  String query = '';

  // Build a friendly name using fields if present:
  // department (e.g. "AI"), passoutYear (2027), division ("A") -> "AI 2027 A"
  String _friendlyNameFromData(String id, Map<String, dynamic> data) {
    final dept = (data['department'] as String?) ?? '';
    final div = (data['division'] as String?) ?? '';
    final yearField = data['passoutYear'];
    final year = yearField is int ? yearField.toString() : (yearField is String ? yearField : '');
    final parts = <String>[];
    if (dept.isNotEmpty) parts.add(dept.toUpperCase());
    if (year.isNotEmpty) parts.add(year);
    if (div.isNotEmpty) parts.add(div.toUpperCase());
    if (parts.isEmpty) {
      // fallback to id split (ai_2027_A -> AI 2027 A)
      final idParts = id.split(RegExp(r'[_\-\s]+'));
      if (idParts.isNotEmpty) {
        final prog = idParts.isNotEmpty ? idParts[0].toUpperCase() : '';
        final yr = idParts.length > 1 ? idParts[1] : '';
        final dv = idParts.length > 2 ? idParts.sublist(2).join(' ') : '';
        final fallback = [if (prog.isNotEmpty) prog, if (yr.isNotEmpty) yr, if (dv.isNotEmpty) dv].join(' ');
        return fallback.isNotEmpty ? fallback : id;
      }
      return id;
    }
    return parts.join(' ');
  }

  bool _matchesBatch(Batch b, String q) {
    if (q.isEmpty) return true;
    final tokens = q.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    final name = b.name.toLowerCase();
    final id = b.id.toLowerCase();
    final prog = b.program.toLowerCase();
    for (final t in tokens) {
      final tok = t.toLowerCase();
      if (name.contains(tok) || id.contains(tok) || prog.contains(tok)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseFirestore.instance.collection('batches').orderBy('id');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Batch'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search batch (e.g. AI 2027 A, cse_2027_A)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: (v) => setState(() => query = v.trim().toLowerCase()),
            ),
          ),

          // Live list from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ref.snapshots(),
              builder: (context, snap) {
                if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());

                final docs = snap.data!.docs;

                final batches = docs.map((d) {
                  final data = d.data() as Map<String, dynamic>? ?? {};
                  final id = d.id;
                  final name = _friendlyNameFromData(id, data);
                  final program = (data['department'] as String?) ?? (id.split('_').isNotEmpty ? id.split('_')[0] : '');
                  final yearRaw = data['passoutYear'];
                  final year = yearRaw is int ? yearRaw : (yearRaw is String ? int.tryParse(yearRaw) : null);
                  return Batch(id: id, name: name, program: program, year: year);
                }).toList()
                  ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

                final filtered = query.isEmpty ? batches : batches.where((b) => _matchesBatch(b, query)).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        query.isEmpty ? 'No batches found.' : 'No batches match "$query".',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final b = filtered[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple.shade100,
                        child: Text(
                          b.name.isNotEmpty ? b.name[0].toUpperCase() : '?',
                          style: TextStyle(color: Colors.purple.shade700),
                        ),
                      ),
                      title: Text(b.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${b.program}${b.year != null ? ' • ${b.year}' : ''}'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => BatchTimetablePage(batch: b)),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
