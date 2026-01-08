import 'package:kakikenyang/controller/provider/authProvider/mobile_auth_provider.dart';
import 'package:kakikenyang/controller/services/userServices/user_services.dart';
import 'package:kakikenyang/view/authScreen/mobile_login_screen.dart';
import 'package:kakikenyang/view/authScreen/otp_screen.dart';
import 'package:kakikenyang/view/navigationBar/navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import '../../../main.dart'; // untuk akses navigatorKey

class MobileAuthServices {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 1) Cek status auth dan navigasi bersih
  static Future<void> checkAuthentication(BuildContext context) async {
    final user = _auth.currentUser;
    if (user == null) {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MobileLoginScreen()),
        (route) => false,
      );
    } else {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const BottomNavigationBarKK()),
        (route) => false,
      );
    }
  }

  /// 2) Kirim OTP ke nomor user
  static Future<void> receiveOTP({
    required BuildContext context,
    required String phoneNumber,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(minutes: 2), // Timeout diperpanjang
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        await UserServices.initBuyerProfile();
        if (!context.mounted) return;
        await checkAuthentication(context);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw Exception('Verifikasi gagal: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        context.read<MobileAuthProvider>()
          ..updateVerificationID(verificationId)
          ..updateResendToken(resendToken);

        Navigator.push(
          context,
          PageTransition(
            child: OTPScreen(phoneNumber: phoneNumber),
            type: PageTransitionType.rightToLeft,
          ),
        );
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  /// 3) Resend OTP ke nomor user jika expired
  static Future<void> resendOTP({
    required BuildContext context,
    required String phoneNumber,
  }) async {
    final resendToken = context.read<MobileAuthProvider>().resendToken;
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(minutes: 2),
      forceResendingToken: resendToken,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        await UserServices.initBuyerProfile();
        if (!context.mounted) return;
        await checkAuthentication(context);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw Exception('Verifikasi ulang gagal: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        context.read<MobileAuthProvider>()
          ..updateVerificationID(verificationId)
          ..updateResendToken(resendToken);
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  // 4) Verifikasi OTP dan login
  static Future<void> verifyOTP({
    required BuildContext context,
    required String otp,
  }) async {
    final verificationId = context.read<MobileAuthProvider>().verificationID;
    if (verificationId == null) {
      throw Exception('Verification ID belum tersedia.');
    }

    final cred = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    final res = await _auth.signInWithCredential(cred);
    final user = res.user;
    if (user == null) {
      throw Exception('Gagal sign in dengan credential ini.');
    }

    await UserServices.initBuyerProfile();

    // ⬇️ Tutup dialog loading (kalau masih terbuka)
    if (navigatorKey.currentContext != null) {
      Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop();
    }

    // ⬇️ Hentikan semua timer di OTP screen dengan popUntil
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const BottomNavigationBarKK()),
      (route) => false,
    );
  }

  /// 5) Logout (nomor HP atau Google)
  static Future<void> signOut() async {
    await _auth.signOut();
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MobileLoginScreen()),
      (route) => false,
    );
  }
}

