// lib/screens/student_signup.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart'; // for MainScreen navigation

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

  bool _loading = false;

  // New field for campus dropdown
  String? _selectedCampus;

  Future<void> _registerStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final name = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final campus = _selectedCampus ?? 'Amrita Vishwa Vidyapeetham';

    final usersRef = FirebaseFirestore.instance.collection('users');

    try {
      // Check duplicate email
      final existing =
          await usersRef.where('email', isEqualTo: email).limit(1).get();
      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('An account with this email already exists')),
        );
        setState(() => _loading = false);
        return;
      }

      // Document data
      final data = {
        'name': name,
        'email': email,
        'password': password, // ⚠️ Only demo purpose
        'role': 'student',
        'campus': campus,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Write to Firestore
      final docRef = await usersRef.add(data);
      debugPrint('Student document created: ${docRef.id}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student Registered Successfully!')),
      );

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => const MainScreen(role: 'student')),
        (route) => false,
      );
    } on FirebaseException catch (fe) {
      debugPrint('FirebaseException during signup: ${fe.code} - ${fe.message}');
      final msg = fe.code == 'permission-denied'
          ? 'Firestore permission denied. Check your Firestore rules.'
          : 'Signup failed: ${fe.message ?? fe.code}';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } catch (e, st) {
      debugPrint('Unexpected error during signup: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 Header Image
            SizedBox(
              height: 250,
              width: double.infinity,
              child: Image.network(
                "https://lh3.googleusercontent.com/aida-public/AB6AXuB-7UIWcImXh-4VEHTrpiFM2e1TPI8pudAoiZGcJTyAAuRnr4a3WzO-bXe8EvskNqDknIQ0EmRE8cbz99EPmGOds3henspBmX_RHip0Rr1yGfWiFPQTJxhsmFCewh7nQ1A7cYlzfHVw9rOnCunlXzGG5gjodeiUNqR4PG0PBOLgRcdvRpccojL7OUnEwbkQLU5mN6mCGw8P-p-msAiTKhvWqxHGt9hyz-r0tyVSpSzShc9ZOEDzsGVPqkYzUYGKmd6fWQVyiv47O2Xh",
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 24),

            // 🔹 Form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Student Sign Up",
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Create your student account to access campus features.",
                      style:
                          TextStyle(fontSize: 14, color: Color(0xFF617589)),
                    ),
                    const SizedBox(height: 24),

                    // Username
                    TextFormField(
                      controller: _usernameController,
                      decoration: _inputDecoration(
                          "Username", Icons.person_outline),
                      validator: (value) => value == null || value.isEmpty
                          ? "Enter your username"
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration(
                          "Email ID", Icons.email_outlined),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter your email";
                        }
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
                      decoration: _inputDecoration(
                          "Password", Icons.lock_outline),
                      validator: (value) => value == null || value.length < 6
                          ? "Password too short"
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // 🔽 Campus Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedCampus,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.school_outlined),
                        labelText: 'Campus Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Color(0xFF1173D4)),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Amrita Vishwa Vidyapeetham',
                          child: Text('Amrita Vishwa Vidyapeetham'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedCampus = value);
                      },
                      validator: (value) =>
                          value == null ? "Please select your campus" : null,
                    ),
                    const SizedBox(height: 28),

                    // 🔹 Register Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _registerStudent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1173D4),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                "Register",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
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
}
