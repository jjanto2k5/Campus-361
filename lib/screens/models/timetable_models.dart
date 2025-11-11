// lib/models/timetable_models.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Faculty {
  final String id;
  final String name;
  final String department;
  final String? photoUrl;

  Faculty({
    required this.id,
    required this.name,
    required this.department,
    this.photoUrl,
  });

  factory Faculty.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Faculty(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      department: data['department'] ?? '',
      photoUrl: data['photoUrl'],
    );
  }
}

class Batch {
  final String id;
  final String name; // e.g. "CSE-A (2027)"
  final String program; // e.g. "CSE"
  final int? year;

  Batch({
    required this.id,
    required this.name,
    required this.program,
    this.year,
  });

  factory Batch.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Batch(
      id: doc.id,
      name: data['name'] ?? doc.id,
      program: data['program'] ?? '',
      year: data['year'] is int ? data['year'] : null,
    );
  }
}

class TimetableItem {
  final String id;
  final String day; // "Monday"
  final String startTime;
  final String endTime;
  final String subject; // subject name or batch name
  final String room;
  final String? location;

  TimetableItem({
    required this.id,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.subject,
    required this.room,
    this.location,
  });

  factory TimetableItem.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TimetableItem(
      id: doc.id,
      day: data['day'] ?? 'Monday',
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      subject: data['subject'] ?? data['batch'] ?? '',
      room: data['room'] ?? '',
      location: data['location'],
    );
  }
}
