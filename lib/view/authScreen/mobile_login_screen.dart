import 'package:kakikenyang/controller/provider/authProvider/google_auth_provider.dart';
import 'package:kakikenyang/controller/provider/authProvider/mobile_auth_provider.dart';
import 'package:kakikenyang/controller/services/authServices/mobile_auth_services.dart';
import 'package:kakikenyang/utils/colors.dart';
import 'package:kakikenyang/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:country_picker/country_picker.dart';

class MobileLoginScreen extends StatefulWidget {
  const MobileLoginScreen({super.key});

  @override
  State<MobileLoginScreen> createState() => _MobileLoginScreenState();
}

class _MobileLoginScreenState extends State<MobileLoginScreen> {
  Country _selectedCountry = Country(
    phoneCode: '62',
    countryCode: 'ID',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'Indonesia',
    example: '812345678',
    displayName: 'Indonesia',
    displayNameNoCountryCode: 'Indonesia',
    e164Key: '',
  );
  final TextEditingController mobileController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    mobileController.dispose();
    super.dispose();
  }

  Future<void> _onReceiveOtp() async {
    setState(() => _loading = true);

    try {
      String input = mobileController.text.trim();

      if (input.isEmpty) {
        throw 'Nomor HP tidak boleh kosong.';
      }
      if (!RegExp(r'^[0-9]{9,13}$').hasMatch(input)) {
        throw 'Nomor HP tidak valid. Masukkan 9-13 digit angka.';
      }

      if (input.startsWith('0')) input = input.substring(1);
      final phoneNumber = '+${_selectedCountry.phoneCode}$input';

      // Simpan ke provider
      context.read<MobileAuthProvider>().updateMobileNumber(phoneNumber);

      await MobileAuthServices.receiveOTP(
        context: context,
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      debugPrint('OTP Error: $e');
      final msg = e.toString().replaceAll('Exception:', '').trim();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            msg.isEmpty ? 'Terjadi kesalahan saat mengirim OTP.' : msg,
          ),
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _onGoogleSignIn() async {
    setState(() => _loading = true);
    final ggl = context.read<GoogleSignInService>();
    try {
      await ggl.signIn();
    } catch (err) {
      debugPrint('Google SignIn Error: $err');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login gagal: ${err.toString()}')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            _buildMainContent(context),
            if (_loading)
              Container(
                color: Colors.black.withValues(alpha: 0.4),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4.h),
          Text(
            'Masuk',
            style: AppTextStyles.body20.copyWith(
              fontWeight: FontWeight.bold,
              color: black,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Masukkan nomor HP kamu untuk melanjutkan',
            style: AppTextStyles.body14.copyWith(color: grey),
          ),
          SizedBox(height: 4.h),

          // Input nomor HP
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => showCountryPicker(
                      context: context,
                      showPhoneCode: true,
                      onSelect: (Country country) {
                        setState(() => _selectedCountry = country);
                      },
                    ),
                    child: Row(
                      children: [
                        Text(
                          '+${_selectedCountry.phoneCode}',
                          style: AppTextStyles.body16.copyWith(
                            fontWeight: FontWeight.bold,
                            color: black,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                        SizedBox(width: 2.w),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: mobileController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Nomor HP',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 5.h),
          ElevatedButton(
            onPressed: _loading ? null : _onReceiveOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              minimumSize: Size(double.infinity, 6.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Next',
                  style: AppTextStyles.body16.copyWith(color: white),
                ),
                SizedBox(width: 2.w),
                Icon(Icons.arrow_forward, color: white, size: 4.h),
              ],
            ),
          ),

          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(child: Divider(thickness: 1, color: Colors.grey[300])),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: Text(
                  "atau masuk dengan",
                  style: AppTextStyles.body14.copyWith(color: grey),
                ),
              ),
              Expanded(child: Divider(thickness: 1, color: Colors.grey[300])),
            ],
          ),

          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: _loading ? null : _onGoogleSignIn,
            icon: FaIcon(FontAwesomeIcons.google, color: red),
            label: Text(
              "Masuk dengan Google",
              style: AppTextStyles.body16.copyWith(color: black),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: black,
              minimumSize: Size(double.infinity, 6.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              elevation: 1,
            ),
          ),
        ],
      ),
    );
  }
}

