// lib/screens/login_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../main.dart'; // MainScreen
import 'services/local_user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  String _role = 'student'; // default role selector
  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final users = FirebaseFirestore.instance.collection('users');

      // Query for a document matching email + password + role
      final q = await users
          .where('email', isEqualTo: _emailCtl.text.trim())
          .where('password', isEqualTo: _passwordCtl.text)
          .where('role', isEqualTo: _role)
          .limit(1)
          .get();

      if (q.docs.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid credentials or role.')),
        );
        setState(() => _loading = false);
        return;
      }

      final doc = q.docs.first;
      final userData = doc.data();

      final role = (userData['role'] as String?) ?? _role;
      final name = (userData['name'] as String?) ?? (userData['username'] as String?) ?? doc.id;
      final uid = doc.id;

      // Save locally so other screens can read current user (no FirebaseAuth used)
      final localUser = LocalUser(uid: uid, name: name, role: role);
      await LocalUserStore.save(localUser);

      // Navigate to MainScreen (pass role so MainScreen chooses faculty/student)
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen(role: role)),
      );
    } on FirebaseException catch (fe) {
      debugPrint('FirebaseException during login: ${fe.code} - ${fe.message}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${fe.message ?? fe.code}')),
      );
    } catch (e, st) {
      debugPrint('Unexpected login error: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Log In")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Role selector
              Row(
                children: [
                  const Text('Role: '),
                  Radio<String>(
                    value: 'student',
                    groupValue: _role,
                    onChanged: (v) => setState(() => _role = v!),
                  ),
                  const Text('Student'),
                  Radio<String>(
                    value: 'faculty',
                    groupValue: _role,
                    onChanged: (v) => setState(() => _role = v!),
                  ),
                  const Text('Faculty'),
                ],
              ),

              TextFormField(
                controller: _emailCtl,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v == null || !v.contains('@') ? 'Enter valid email' : null,
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _passwordCtl,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) => v == null || v.length < 6 ? 'Minimum 6 chars' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Log In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
