import 'package:flutter/material.dart';
import 'signup_choice_screen.dart';
import '../main_screen.dart'; // go up one folder to access main_screen.dart


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top image
          SizedBox(
            height: 250,
            width: double.infinity,
            child: Image.network(
              "https://lh3.googleusercontent.com/aida-public/AB6AXuB-7UIWcImXh-4VEHTrpiFM2e1TPI8pudAoiZGcJTyAAuRnr4a3WzO-bXe8EvskNqDknIQ0EmRE8cbz99EPmGOds3henspBmX_RHip0Rr1yGfWiFPQTJxhsmFCewh7nQ1A7cYlzfHVw9rOnCunlXzGG5gjodeiUNqR4PG0PBOLgRcdvRpccojL7OUnEwbkQLU5mN6mCGw8P-p-msAiTKhvWqxHGt9hyz-r0tyVSpSzShc9ZOEDzsGVPqkYzUYGKmd6fWQVyiv47O2Xh",
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 24),

          // Title & Subtitle
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  "Welcome to Campus 361",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Navigate your campus with ease. Find classrooms, labs, and faculty offices effortlessly.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF617589),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // TODO: Add login screen later
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: const Color(0xFF1173D4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Log In"),
                ),

                const SizedBox(height: 12),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpChoiceScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: const Color(0x331173D4),
                    foregroundColor: const Color(0xFF1173D4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text("Sign Up"),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const MainScreen(role: "student"), // ✅ Guest = Student role
                      ),
                    );
                  },
                  child: const Text(
                    "Continue as Guest",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1173D4),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          const Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Text(
              "By continuing, you agree to our Terms of Service and Privacy Policy.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF617589),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
