import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  final String role; // e.g. "student", "teacher", or "guest"

  const MainScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Campus 361 - $role"),
        backgroundColor: const Color(0xFF1173D4),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school, size: 80, color: Color(0xFF1173D4)),
              const SizedBox(height: 24),
              Text(
                "Welcome to Campus 361!",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "You are logged in as a $role.",
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF617589),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1173D4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Back to Welcome Screen"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
