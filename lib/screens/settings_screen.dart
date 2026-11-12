import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFFCFD0FC),
        foregroundColor: const Color(0xFF0B10C0),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFCFD0FC),
                child: Icon(Icons.person, color: Color(0xFF0B10C0)),
              ),
              title: const Text('Logged in as', style: TextStyle(fontSize: 12, color: Colors.grey)),
              subtitle: Text(user?.email ?? 'User', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info, color: Color(0xFF0B10C0)),
                  title: const Text('App Version'),
                  subtitle: const Text('1.0.0 (Final Project)'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () async {
              await authService.signOut();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
