import 'package:flutter/material.dart';

class EventRegistrationPage extends StatefulWidget {
  final String eventTitle;
  const EventRegistrationPage({super.key, required this.eventTitle});

  @override
  State<EventRegistrationPage> createState() => _EventRegistrationPageState();
}

class _EventRegistrationPageState extends State<EventRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _deptController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _deptController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You have successfully registered for ${widget.eventTitle}! 🎉',
          ),
          backgroundColor: Colors.green.shade600,
        ),
      );
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register for ${widget.eventTitle}'),
        backgroundColor: const Color(0xFF1173D4),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Fill out the form below to register:",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 20),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF1173D4)),
                  ),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email ID',
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF1173D4)),
                  ),
                ),
                validator: (v) => v == null || !v.contains('@')
                    ? 'Enter a valid email'
                    : null,
              ),
              const SizedBox(height: 16),

              // Department
              TextFormField(
                controller: _deptController,
                decoration: InputDecoration(
                  labelText: 'Department',
                  prefixIcon: const Icon(Icons.account_tree_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF1173D4)),
                  ),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter your department' : null,
              ),
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _submitting ? null : _submitForm,
                  icon: _submitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded, color: Colors.white),
                  label: Text(
                    _submitting ? "Submitting..." : "Register",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1173D4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
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
    );
  }
}
