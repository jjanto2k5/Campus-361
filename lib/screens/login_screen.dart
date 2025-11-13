// lib/screens/login_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../main.dart'; // For MainScreen
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
  String _role = 'student'; // default role
  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    // close keyboard
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      final users = FirebaseFirestore.instance.collection('users');

      final emailTrim = _emailCtl.text.trim();
      final q = await users
          .where('email', isEqualTo: emailTrim)
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
      final name = (userData['name'] as String?) ??
          (userData['username'] as String?) ??
          doc.id;
      final uid = doc.id;

      final localUser = LocalUser(uid: uid, name: name, role: role);
      await LocalUserStore.save(localUser);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainScreen(role: role)),
        (route) => false,
      );
    } on FirebaseException catch (fe) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${fe.message ?? fe.code}')),
      );
    } catch (e) {
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header image (same as Sign Up)
              SizedBox(
                height: 230,
                width: double.infinity,
                child: Image.network(
                  "https://lh3.googleusercontent.com/aida-public/AB6AXuB-7UIWcImXh-4VEHTrpiFM2e1TPI8pudAoiZGcJTyAAuRnr4a3WzO-bXe8EvskNqDknIQ0EmRE8cbz99EPmGOds3henspBmX_RHip0Rr1yGfWiFPQTJxhsmFCewh7nQ1A7cYlzfHVw9rOnCunlXzGG5gjodeiUNqR4PG0PBOLgRcdvRpccojL7OUnEwbkQLU5mN6mCGw8P-p-msAiTKhvWqxHGt9hyz-r0tyVSpSzShc9ZOEDzsGVPqkYzUYGKmd6fWQVyiv47O2Xh",
                  fit: BoxFit.cover,
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      const Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Access your Campus361 account to continue.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Role Selector
                      Text(
                        'Select Role',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                            fontSize: 14),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              value: 'student',
                              groupValue: _role,
                              title: const Text('Student'),
                              contentPadding: EdgeInsets.zero,
                              onChanged: (v) => setState(() => _role = v!),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              value: 'faculty',
                              groupValue: _role,
                              title: const Text('Faculty'),
                              contentPadding: EdgeInsets.zero,
                              onChanged: (v) => setState(() => _role = v!),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Email Field
                      TextFormField(
                        controller: _emailCtl,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email_outlined),
                          hintText: 'Email ID',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue.shade200),
                          ),
                        ),
                        validator: (v) =>
                            v == null || !v.contains('@') ? 'Enter valid email' : null,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        controller: _passwordCtl,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline),
                          hintText: 'Password',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue.shade200),
                          ),
                        ),
                        obscureText: true,
                        validator: (v) =>
                            v == null || v.length < 6 ? 'Minimum 6 characters' : null,
                        onFieldSubmitted: (_) => _login(),
                      ),
                      const SizedBox(height: 26),

                      // Login Button
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
                          onPressed: _loading ? null : _login,
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
                                  'Log In',
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
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
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
