import 'package:firebase_auth/firebase_auth.dart';
import 'package:valet/controllers/otp.dart';
import 'package:valet/widgets/widgets.dart';
import 'package:valet/screens/landing.dart';
import 'package:valet/screens/register.dart';
import 'package:valet/screens/termesConditions.dart';
import 'package:valet/screens/verification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPhone extends StatefulWidget {
  const LoginPhone({super.key});

  @override
  State<LoginPhone> createState() => _LoginPhoneState();
}

class _LoginPhoneState extends State<LoginPhone> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isChecked = false;
  bool _isSendingOTP = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Landing(),
              ),
            );
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildLogo(),
                  const SizedBox(height: 16),
                  Center(
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.white,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 0.2,
                                vertical: 5.0,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "Se connecter",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 49),
                  const Text(
                    "Entrez votre numéro de \n téléphone",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 36),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(9),
                      ],
                      decoration: InputDecoration(
                        prefixText: "+212 \t",
                        labelText: "Enter your phone number",
                        prefixStyle: const TextStyle(color: Colors.white),
                        labelStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Please enter your phone number";
                        }
                        if (val.length != 9) {
                          return "Phone number must contain exactly 9 digits";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: isChecked,
                        onChanged: (bool? newVal) {
                          setState(() {
                            isChecked = newVal!;
                          });
                        },
                      ),
                      _termesConditionsOption(),
                    ],
                  ),
                  const SizedBox(height: 49),
                  _buildSubmitButton(),
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

  Widget _termesConditionsOption() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TermesConditions(),
          ),
        );
      },
      child: RichText(
        text: const TextSpan(
          text: 'En créant un compte, vous acceptez nos\n',
          style: TextStyle(color: Colors.white),
          children: [
            TextSpan(
              text: 'Termes et conditions',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: _isSendingOTP
          ? const CircularProgressIndicator(color: Colors.white)
          : Container(
              margin: const EdgeInsets.only(top: 10),
              child: MaterialButton(
                onPressed: () async {
                  await _sendOTP();
                },
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Suivant",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
    );
  }

  Future<void> _sendOTP() async {
    if (_formKey.currentState!.validate() && isChecked && !_isSendingOTP) {
      final phoneNumber = _phoneNumberController.text;
      setState(() {
        _isSendingOTP = true;
      });
      if (await _phoneNumberExistsInFirebase(phoneNumber)) {
        await _sendOtpAndNavigate(phoneNumber);
      } else {
        _navigateToRegister(phoneNumber);
      }
      setState(() {
        _isSendingOTP = false;
      });
    }
  }

  Future<bool> _phoneNumberExistsInFirebase(String phoneNumber) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return true;
      } else {
        QuerySnapshot<Map<String, dynamic>> querySnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .where('phoneNumber', isEqualTo: phoneNumber)
                .get();
        return querySnapshot.docs.isNotEmpty;
      }
    } catch (err) {
      print(err);
      return false;
    }
  }

  Future<void> _sendOtpAndNavigate(String phoneNumber) async {
    await Otp.sentOtp(
      phone: phoneNumber,
      errorStep: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send OTP'),
            backgroundColor: Colors.red,
          ),
        );
      },
      nextStep: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Verification(
              phoneNumber: phoneNumber,
            ),
          ),
        );
      },
    );
  }

  void _navigateToRegister(String phoneNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Register(phoneNumber: phoneNumber),
      ),
    );
  }
}
