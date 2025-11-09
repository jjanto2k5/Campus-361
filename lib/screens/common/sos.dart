import 'package:flutter/material.dart';
import '../../../main.dart'; // To access userRole if needed

class SOSScreen extends StatelessWidget {
  const SOSScreen({Key? key}) : super(key: key);

  void _showSOSDialog(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Confirm $type Alert'),
        content: Text('Are you sure you want to send a $type alert?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$type alert sent successfully!'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          userRole == 'faculty'
              ? 'Faculty Emergency Assistance'
              : 'Student Emergency Assistance',
          style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              "Campus Emergency Assistance",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "If you're in danger or require urgent help, use the SOS buttons below to alert campus authorities immediately.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 40),

            // 🔴 SOS Buttons
            _buildSOSButton(
              context,
              icon: Icons.local_police,
              label: "Campus Security",
              color: Colors.redAccent,
              onPressed: () => _showSOSDialog(context, "Security"),
            ),
            const SizedBox(height: 20),
            _buildSOSButton(
              context,
              icon: Icons.local_hospital,
              label: "Medical Emergency",
              color: Colors.orangeAccent,
              onPressed: () => _showSOSDialog(context, "Medical"),
            ),
            const SizedBox(height: 20),
            _buildSOSButton(
              context,
              icon: Icons.fire_truck_rounded,
              label: "Fire Alert",
              color: Colors.deepOrange,
              onPressed: () => _showSOSDialog(context, "Fire"),
            ),

            const Spacer(),
            Text(
              "Campus361 Safety Network © 2025",
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSOSButton(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 3,
      ),
      icon: Icon(icon, size: 28, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: onPressed,
    );
  }
}
