import 'package:flutter/material.dart';
import 'student_signup_screen.dart';

import 'teacher_signup_screen.dart';

class SignUpChoiceScreen extends StatelessWidget {
  const SignUpChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 🏫 Header Image (same as other screens)
              SizedBox(
                height: 250,
                width: double.infinity,
                child: Image.network(
                  "https://lh3.googleusercontent.com/aida-public/AB6AXuB-7UIWcImXh-4VEHTrpiFM2e1TPI8pudAoiZGcJTyAAuRnr4a3WzO-bXe8EvskNqDknIQ0EmRE8cbz99EPmGOds3henspBmX_RHip0Rr1yGfWiFPQTJxhsmFCewh7nQ1A7cYlzfHVw9rOnCunlXzGG5gjodeiUNqR4PG0PBOLgRcdvRpccojL7OUnEwbkQLU5mN6mCGw8P-p-msAiTKhvWqxHGt9hyz-r0tyVSpSzShc9ZOEDzsGVPqkYzUYGKmd6fWQVyiv47O2Xh",
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 30),

              // 🧭 Title
              const Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Choose your role to continue registration.",
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              ),

              const SizedBox(height: 40),

              // 🧩 Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const StudentSignUpScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1173D4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Sign up as Student",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FacultySignUpScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF1173D4), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Sign up as Faculty",
                          style: TextStyle(
                            color: Color(0xFF1173D4),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // 🏫 Footer
              Text(
                'Campus361 © 2025',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
