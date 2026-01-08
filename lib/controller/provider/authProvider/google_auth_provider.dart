import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
// class GoogleSignInProvider with ChangeNotifier {
//   final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
//   GoogleSignInAccount? _user;
//   GoogleSignInAccount? get user => _user;

//   Future<void> googleLogin() async {
//     try {
//       final googleUser = await _googleSignIn.authenticate();
//       if (googleUser == null) return; // User canceled

//       _user = googleUser;

//       final googleAuth = googleUser.authentication;

//       final credential = GoogleAuthProvider.credential(
//         idToken: googleAuth.idToken,
//       );

//       await FirebaseAuth.instance.signInWithCredential(credential);
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Google login error: $e');
//     }
//   }

//   Future<void> logout() async {
//     await _googleSignIn.disconnect();
//     await FirebaseAuth.instance.signOut();
//     notifyListeners();
//   }
// }

class GoogleSignInService with ChangeNotifier {
  final GoogleSignIn _gsi = GoogleSignIn.instance;
  final fb_auth.FirebaseAuth _fa = fb_auth.FirebaseAuth.instance;

  fb_auth.User? _user;
  bool _loading = false;
  String? _error;

  GoogleSignInService() {
    _init();
  }

  // GETTERS untuk UI
  fb_auth.User? get user      => _user;
  bool          get loading   => _loading;
  String?       get error     => _error;
  bool          get isSignedIn=> _user != null;

  // INIT & lightweight restore
  Future<void> _init() async {
    try {
      await _gsi.initialize(); // wajib await sebelum auth apapun
      final acct = await _gsi.attemptLightweightAuthentication();
      if (acct != null) await _signInFirebase(acct);
    } catch (e) {
      _setError('Init gagal: $e');
    }
  }

  // INTERACTIVE SIGN‑IN
  Future<void> signIn() async {
    _setLoading(true);
    try {
      final acct = await _gsi.authenticate(); // UI popup/web flow
      await _signInFirebase(acct);
    } catch (e) {
      _setError('Sign‑in gagal: $e');
    } finally {
      _setLoading(false);
    }
  }

  // PRIVATE: convert Google → Firebase
  Future<void> _signInFirebase(GoogleSignInAccount acct) async {
    final auth = acct.authentication;
    // Cuma pakai idToken, karena v7.x gak ada accessToken
    final cred = fb_auth.GoogleAuthProvider.credential(
      idToken: auth.idToken,
    );
    final res = await _fa.signInWithCredential(cred);
    _user = res.user;
    notifyListeners();
  }

  // SIGN‑OUT
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _fa.signOut();
      await _gsi.disconnect();
      await _gsi.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      _setError('Sign‑out gagal: $e');
    } finally {
      _setLoading(false);
    }
  }

  // HELPERS
  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _setError(String msg) {
    _error   = msg;
    _loading = false;
    notifyListeners();
  }
}

