// lib/screens/signup_choice_screen.dart
import 'package:flutter/material.dart';
import 'student_signup_screen.dart';
import 'teacher_signup_screen.dart';

class SignUpChoiceScreen extends StatelessWidget {
  const SignUpChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const StudentSignUpScreen()));
              },
              child: const Text("Sign up as Student"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const FacultySignUpScreen()));
              },
              child: const Text("Sign up as Faculty"),
            ),
          ],
        ),
      ),
    );
  }
}
