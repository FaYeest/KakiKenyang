import 'package:kakikenyang/controller/services/authServices/mobile_auth_services.dart';
import 'package:kakikenyang/controller/services/userServices/user_services.dart';
import 'package:kakikenyang/utils/text_styles.dart';
import 'package:kakikenyang/utils/theme_notifier.dart';
import 'package:kakikenyang/view/account/edit_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _initUserData();
  }

  Future<void> _initUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      await UserServices.initBuyerProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDark = themeNotifier.themeMode == ThemeMode.dark;
    final user = _auth.currentUser;

    if (user == null) {
      // jika sudah logout, tampilkan loading singkat
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // cek apakah user login via Google
    final isGoogle = user.providerData.any((p) => p.providerId == 'google.com');

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Avatar
            CircleAvatar(
              radius: 48,
              backgroundColor: Colors.amber.shade700,
              backgroundImage:
                  user.photoURL != null ? NetworkImage(user.photoURL!) : null,
              child: user.photoURL == null
                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 16),
            // Nama
            Text(
              user.displayName ?? 'Nama belum diatur',
              style: AppTextStyles.body16.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            // Email
            Text(
              user.email ?? '',
              style: AppTextStyles.body16.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            // No Telp
            if (user.phoneNumber != null)
              Text(
                user.phoneNumber!,
                style: AppTextStyles.body16.copyWith(
                  color: isDark ? Colors.green[400] : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 8),
            // Switch Theme
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.light_mode, size: 20),
                Switch(
                  value: isDark,
                  onChanged: (val) => themeNotifier.toggleTheme(val),
                ),
                const Icon(Icons.dark_mode, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            // Menu
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView(
                  children: [
                    // Edit Profile
                    ListTile(
                      leading: const Icon(Icons.edit, color: Colors.amber),
                      title: const Text('Edit Profile'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    // Logout
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text(
                        'Keluar',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () async {
                        if (isGoogle) {
                          await FirebaseAuth.instance.signOut();
                        } else {
                          await MobileAuthServices.signOut();
                        }
                        // semua navigasi sudah ditangani di dalam service
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

