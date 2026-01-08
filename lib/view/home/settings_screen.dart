import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Pengaturan akan ditampilkan di sini.',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ),
    );
  }
}
