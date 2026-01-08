// lib/main.dart
import 'package:kakikenyang/controller/provider/authProvider/google_auth_provider.dart';
import 'package:kakikenyang/controller/provider/authProvider/mobile_auth_provider.dart';
import 'package:kakikenyang/controller/services/userServices/user_services.dart';
import 'package:kakikenyang/utils/theme_notifier.dart';
import 'package:kakikenyang/view/authScreen/mobile_login_screen.dart';
import 'package:kakikenyang/view/map/map_state.dart';
import 'package:kakikenyang/view/navigationBar/navigation_bar.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'firebase_options.dart';

//  Global navigatorKey untuk navigasi tanpa context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Aktifkan AppCheck dengan Debug Provider (biar gak reCAPTCHA)
  await FirebaseAppCheck.instance.activate(
    providerAndroid: const AndroidDebugProvider(),
  );

  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => MobileAuthProvider()),
        ChangeNotifierProvider(create: (_) => GoogleSignInService()),
        ChangeNotifierProvider(create: (_) => MapState()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Consumer<ThemeNotifier>(
          builder: (context, themeNotifier, _) {
            return MaterialApp(
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              themeMode: themeNotifier.themeMode,
              home: StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  // loading indicator saat masih inisialisasi auth
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  // user sudah login
                  if (snapshot.hasData) {
                    // init data buyer sekali saja
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      UserServices.initBuyerProfile();
                    });
                    return const BottomNavigationBarKK();
                  }
                  // user belum login
                  return const MobileLoginScreen();
                },
              ),
            );
          },
        );
      },
    );
  }
}

