import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class FacultySignUpScreen extends StatefulWidget {
  const FacultySignUpScreen({super.key});

  @override
  State<FacultySignUpScreen> createState() => _FacultySignUpScreenState();
}

class _FacultySignUpScreenState extends State<FacultySignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _deptCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  String? _selectedCampus;
  bool _loading = false;

  Future<void> _registerFaculty() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance.collection('users').add({
        'name': _nameCtl.text.trim(),
        'email': _emailCtl.text.trim(),
        'department': _deptCtl.text.trim(),
        'password': _passwordCtl.text,
        'role': 'faculty',
        'campus': _selectedCampus ?? 'Amrita Vishwa Vidyapeetham',
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faculty registered successfully!')),
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const MainScreen(role: 'faculty')),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _emailCtl.dispose();
    _deptCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header image (same as student signup)
              SizedBox(
                height: 230,
                width: double.infinity,
                child: Image.network(
                  "https://lh3.googleusercontent.com/aida-public/AB6AXuB-7UIWcImXh-4VEHTrpiFM2e1TPI8pudAoiZGcJTyAAuRnr4a3WzO-bXe8EvskNqDknIQ0EmRE8cbz99EPmGOds3henspBmX_RHip0Rr1yGfWiFPQTJxhsmFCewh7nQ1A7cYlzfHVw9rOnCunlXzGG5gjodeiUNqR4PG0PBOLgRcdvRpccojL7OUnEwbkQLU5mN6mCGw8P-p-msAiTKhvWqxHGt9hyz-r0tyVSpSzShc9ZOEDzsGVPqkYzUYGKmd6fWQVyiv47O2Xh",
                  fit: BoxFit.cover,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Faculty Sign Up',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your faculty account to access Campus361 features.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Full Name
                      TextFormField(
                        controller: _nameCtl,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person_outline),
                          hintText: 'Full Name',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue.shade200),
                          ),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Enter your name' : null,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _emailCtl,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email_outlined),
                          hintText: 'Email ID',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue.shade200),
                          ),
                        ),
                        validator: (v) =>
                            v == null || !v.contains('@') ? 'Enter valid email' : null,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // Department
                      TextFormField(
                        controller: _deptCtl,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.account_tree_outlined),
                          hintText: 'Department',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue.shade200),
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Enter your department'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: _passwordCtl,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline),
                          hintText: 'Password',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue.shade200),
                          ),
                        ),
                        validator: (v) => v == null || v.length < 6
                            ? 'Minimum 6 characters'
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
                            borderRadius: BorderRadius.circular(12),
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
                      const SizedBox(height: 26),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _loading ? null : _registerFaculty,
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Center(
                        child: Text(
                          'Campus361 © 2025',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
