import 'package:kakikenyang/controller/services/authServices/mobile_auth_services.dart';
import 'package:flutter/material.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      MobileAuthServices.checkAuthentication(context);

    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Image(image: AssetImage('assets/images/image.png')),
    );
  }
}

