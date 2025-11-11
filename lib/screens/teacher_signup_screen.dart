// lib/screens/faculty_signup.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart'; // for MainScreen navigation

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
  bool _loading = false;

  Future<void> _signupFaculty() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final users = FirebaseFirestore.instance.collection('users'); // use 'faculty' if you want a separate collection

    try {
      final email = _emailCtl.text.trim();
      // check duplicate email
      final existing = await users.where('email', isEqualTo: email).limit(1).get();
      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An account with that email already exists.')),
        );
        setState(() => _loading = false);
        return;
      }

      final doc = {
        'name': _nameCtl.text.trim(),
        'email': email,
        'department': _deptCtl.text.trim(),
        'password': _passwordCtl.text, // demo only - don't store plaintext in prod
        'role': 'faculty',
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await users.add(doc);
      debugPrint('Faculty added with id: ${docRef.id}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faculty registered successfully')),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen(role: 'faculty')),
      );
    } on FirebaseException catch (fe) {
      debugPrint('FirebaseException during faculty signup: ${fe.code} - ${fe.message}');
      final msg = fe.code == 'permission-denied'
          ? 'Firestore permission denied. Check your Firestore rules.'
          : 'Signup failed: ${fe.message ?? fe.code}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
    _nameCtl.dispose();
    _emailCtl.dispose();
    _deptCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Faculty Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtl,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v == null || !v.contains('@') ? 'Enter valid email' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deptCtl,
                decoration: const InputDecoration(labelText: 'Department'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter department' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtl,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) => v == null || v.length < 6 ? 'Minimum 6 chars' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _signupFaculty,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1173D4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator())
                      : const Text('Sign Up'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
