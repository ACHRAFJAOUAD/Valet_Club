import 'package:valet/widgets/widgets.dart';
import 'package:valet/screens/login_email.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:valet/screens/login_phone.dart';

class Landing extends StatefulWidget {
  const Landing({super.key});

  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _LandingUser(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      String phoneNumber = "+212${_phoneNumberController.text.trim()}";
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPhone()),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginPhone(),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print(
              'Code Auto Retrieval Timeout. Verification ID: $verificationId');
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
              child: Column(
                children: <Widget>[
                  _buildLogo(),
                  const SizedBox(height: 99),
                  _buildTextLabel(),
                  const SizedBox(height: 16),
                  _buildPhoneNumberForm(),
                  const SizedBox(height: 220),
                  _buildLoginOption(),
                  const SizedBox(height: 26),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: logoWidget("assets/logo.png"),
    );
  }

  Widget _buildPhoneNumberForm() {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPhone()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: Colors.white),
        ),
        child: Form(
          key: _formKey,
          child: TextFormField(
            enabled: false,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.phone, color: Colors.white),
              labelText: "Continuez avec votre numéro de téléphone",
              prefixStyle: TextStyle(color: Colors.white),
              labelStyle: TextStyle(color: Colors.white),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextLabel() {
    return Row(
      children: [
        Row(
          children: [
            Column(
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'La meilleure façon de se connecter avec\n ',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: 'votre valet',
                        style: TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginOption() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Connectez-vous en utilisant\nvotre Email et votre mot de passe',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginEmail()),
              );
            },
            child: Text.rich(
              TextSpan(
                text: 'Se connecter',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginEmail()),
                    );
                  },
              ),
              style: const TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
