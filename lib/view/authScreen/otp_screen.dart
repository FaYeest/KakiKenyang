// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../../controller/provider/authProvider/mobile_auth_provider.dart';
import '../../../controller/services/authServices/mobile_auth_services.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  const OTPScreen({super.key, required this.phoneNumber});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Timer? _timer;
  int _secondsRemaining = 60;
  bool _canResend = false;
  bool _isVerifying = false;
  bool _isDisposed = false; // ✅ new

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsRemaining = 60;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed) return; // ✅ prevent update after dispose

      if (_secondsRemaining == 0) {
        setState(() => _canResend = true);
        timer.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    // _otpController.dispose();
    super.dispose();
  }

  /* ------------  RESEND  ------------ */
  Future<void> _resendCode() async {
    _startTimer();
    await MobileAuthServices.receiveOTP(
      context: context,
      phoneNumber: widget.phoneNumber,
    );
  }

  /* ------------  VERIFY  ------------ */
  Future<void> _verifyOTP() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final otp = _otpController.text.trim();

    setState(() => _isVerifying = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await MobileAuthServices.verifyOTP(context: context, otp: otp);
    } catch (e) {
      if (!_isDisposed && mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // tutup dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal verifikasi OTP: $e')),
        );
      }
    } finally {
      if (!_isDisposed && mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone =
        context.watch<MobileAuthProvider>().phoneNumber ?? widget.phoneNumber;

    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi OTP'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 32),
              Text('Kode OTP dikirim ke', style: Theme.of(context).textTheme.bodyMedium),
              Text(phone, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              PinCodeTextField(
                // enabled: !_isDisposed,
                controller: _otpController,
                appContext: context,
                length: 6,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeColor: Colors.amber,
                  selectedColor: Colors.orange,
                  inactiveColor: Colors.grey,
                ),
                validator: (v) => v!.length < 6 ? 'Harus 6 digit' : null,
                onChanged: (value) {
                  if (_isDisposed) return;
                  // bisa ditambahkan logika lain jika diperlukan
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Verifikasi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _canResend
                  ? TextButton(
                      onPressed: _resendCode,
                      child: const Text('Kirim ulang kode'),
                    )
                  : Text('Kirim ulang dalam $_secondsRemaining detik',
                      style: TextStyle(color: Colors.grey[700])),
            ],
          ),
        ),
      ),
    );
  }
}

