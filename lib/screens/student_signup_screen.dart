import 'package:flutter/material.dart';
import '../main.dart'; // ✅ for MainScreen navigation

class StudentSignUpScreen extends StatefulWidget {
  const StudentSignUpScreen({super.key});

  @override
  State<StudentSignUpScreen> createState() => _StudentSignUpScreenState();
}

class _StudentSignUpScreenState extends State<StudentSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 250,
              width: double.infinity,
              child: Image.network(
                "https://lh3.googleusercontent.com/aida-public/AB6AXuB-7UIWcImXh-4VEHTrpiFM2e1TPI8pudAoiZGcJTyAAuRnr4a3WzO-bXe8EvskNqDknIQ0EmRE8cbz99EPmGOds3henspBmX_RHip0Rr1yGfWiFPQTJxhsmFCewh7nQ1A7cYlzfHVw9rOnCunlXzGG5gjodeiUNqR4PG0PBOLgRcdvRpccojL7OUnEwbkQLU5mN6mCGw8P-p-msAiTKhvWqxHGt9hyz-r0tyVSpSzShc9ZOEDzsGVPqkYzUYGKmd6fWQVyiv47O2Xh",
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Student Sign Up",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Create your student account to access campus features.",
                      style: TextStyle(fontSize: 14, color: Color(0xFF617589)),
                    ),
                    const SizedBox(height: 24),

                    // Username
                    TextFormField(
                      controller: _usernameController,
                      decoration: _inputDecoration("Username", Icons.person_outline),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Enter your username" : null,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration("Email ID", Icons.email_outlined),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Enter your email";
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: _inputDecoration("Password", Icons.lock_outline),
                      validator: (value) =>
                          value == null || value.length < 6 ? "Password too short" : null,
                    ),
                    const SizedBox(height: 28),

                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Student Registered Successfully!"),
                                backgroundColor: Color(0xFF1173D4),
                              ),
                            );

                            // 🧭 Navigate to MainScreen (Student Dashboard)
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MainScreen(role: 'student'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1173D4),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Register",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1173D4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1173D4), width: 2),
      ),
    );
  }
}
