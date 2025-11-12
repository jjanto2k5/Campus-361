import 'package:flutter/material.dart';
import 'event_reg.dart';


class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> events = [
      {
        'title': 'Tech Fusion 2025',
        'date': 'Nov 18, 2025',
        'location': 'Annapoorneshwari Hall',
        'image': 'https://images.unsplash.com/photo-1556761175-5973dc0f32e7',
        'description': 'A celebration of innovation, technology, and creativity.'
      },
      {
        'title': 'Cultural Fest',
        'date': 'Dec 2, 2025',
        'location': 'Aacharya Hall',
        'image': 'https://images.unsplash.com/photo-1531058020387-3be344556be6',
        'description': 'Experience art, music, and dance in a vibrant atmosphere.'
      },
      {
        'title': 'Hackathon 24-Hour Sprint',
        'date': 'Dec 12-13, 2025',
        'location': 'Amriteshwari Hall',
        'image': 'https://images.unsplash.com/photo-1521737604893-d14cc237f11d',
        'description': 'Collaborate and build cutting-edge solutions overnight!'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Events'),
        backgroundColor: const Color(0xFF1173D4),
        centerTitle: true,
        elevation: 2,
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final e = events[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
                  child: Image.network(
                    e['image']!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e['title']!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 15, color: Colors.blueAccent),
                          const SizedBox(width: 6),
                          Text(e['date']!,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black54)),
                          const SizedBox(width: 12),
                          const Icon(Icons.location_on,
                              size: 15, color: Colors.redAccent),
                          const SizedBox(width: 4),
                          Text(e['location']!,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black54)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        e['description']!,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EventRegistrationPage(
                                  eventTitle: e['title']!,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward_ios_rounded,
                              size: 14, color: Color(0xFF1173D4)),
                          label: const Text(
                            'View Details',
                            style: TextStyle(color: Color(0xFF1173D4)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
