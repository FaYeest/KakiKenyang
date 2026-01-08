import 'package:flutter/material.dart';

class MobileAuthProvider extends ChangeNotifier {
  String? phoneNumber;
  String? verificationID;
  int? resendToken;

  void updateVerificationID(String verification) {
    verificationID = verification;
    notifyListeners();
  }

  void updateMobileNumber(String number) {
    phoneNumber = number;
    notifyListeners();
  }

  void updateResendToken(int? token) {
    resendToken = token;
    notifyListeners();
  }

  void reset() {
    phoneNumber = null;
    verificationID = null;
    resendToken = null;
    notifyListeners();
  }
}

