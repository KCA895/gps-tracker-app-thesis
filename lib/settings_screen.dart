import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final bool isNotificationEnabled;
  final ValueChanged<bool> onNotificationToggle;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.isNotificationEnabled,
    required this.onNotificationToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            value: isNotificationEnabled,
            title: const Text('Aktifkan Notifikasi'),
            onChanged: onNotificationToggle,
          ),
          SwitchListTile(
            value: isDarkMode,
            title: const Text('Mode Gelap'),
            onChanged: onThemeChanged,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Keluar'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}