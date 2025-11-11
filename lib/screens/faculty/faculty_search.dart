// lib/screens/faculty/faculty_search.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/timetable_models.dart';
import 'faculty_timetable.dart';

class FacultySearchPage extends StatefulWidget {
  const FacultySearchPage({super.key});

  @override
  State<FacultySearchPage> createState() => _FacultySearchPageState();
}

class _FacultySearchPageState extends State<FacultySearchPage> {
  String query = '';

  bool _matchesName(String name, String q) {
    if (q.isEmpty) return true;
    final tokens = q.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    final lowerName = name.toLowerCase();
    for (final token in tokens) {
      if (lowerName.contains(token)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 now fetching from "users" collection, only faculty role
    final ref = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'faculty')
        .orderBy('name');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Faculty'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 🔍 Search field
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search faculty by name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: (v) => setState(() => query = v.trim().toLowerCase()),
            ),
          ),

          // 🔹 Live Firestore list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ref.snapshots(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Map Firestore docs into Faculty objects
                final docs = snap.data!.docs;
                final faculties = docs.map((d) {
                  final data = d.data() as Map<String, dynamic>? ?? {};
                  return Faculty(
                    id: d.id,
                    name: data['name'] ?? 'Unknown',
                    department: data['department'] ?? '',
                    photoUrl: null, // you can add profile photo later
                  );
                }).toList()
                  ..sort((a, b) =>
                      a.name.toLowerCase().compareTo(b.name.toLowerCase()));

                // 🔸 Filter based on search text
                final filtered = query.isEmpty
                    ? faculties
                    : faculties
                        .where((f) => _matchesName(f.name, query))
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      query.isEmpty
                          ? 'No faculty found.'
                          : 'No faculty matches "$query".',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  );
                }

                // 🔹 Display all faculty
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final f = filtered[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          f.name.isNotEmpty ? f.name[0].toUpperCase() : '?',
                          style: TextStyle(color: Colors.blue.shade700),
                        ),
                      ),
                      title: Text(
                        f.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(f.department),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FacultyTimetablePage(faculty: f),
                          ),
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
