import 'dart:async';

import 'package:valet/widgets/widgets.dart';

import 'package:valet/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:valet/controllers/otp.dart';
import 'package:flutter/services.dart';

class Verification extends StatefulWidget {
  final String phoneNumber;

  const Verification({super.key, required this.phoneNumber});

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  final TextEditingController _otpController = TextEditingController();
  late Timer _timer;
  int _start = 30;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          timer.cancel();
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  void restartTimer() {
    setState(() {
      _start = 30;
    });
    _timer.cancel();
    startTimer();
  }

  void verifyOTP() {
    String enteredOTP = _otpController.text;
    Otp.loginWithOtp(otp: enteredOTP).then((result) {
      if (result == "Success") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid OTP. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void resendOTP() {
    Otp.sentOtp(
      phone: widget.phoneNumber,
      errorStep: () {},
      nextStep: () {
        restartTimer();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
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
                  const SizedBox(height: 69),
                  const Text(
                    "Verifiez votre téléphone",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildModifyNumber(),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          decoration: InputDecoration(
                            labelText: "Enter le code",
                            labelStyle: const TextStyle(color: Colors.white),
                            border: const OutlineInputBorder(),
                            suffixText: '00:$_start ',
                            suffixStyle: const TextStyle(color: Colors.white),
                          ),
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Please enter the OTP";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            if (value.length == 6) {
                              verifyOTP();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 46),
                  _buildClickableTextWithLine("Renvoyez le code", resendOTP),
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

  Widget _buildModifyNumber() {
    return RichText(
      text: TextSpan(
        text:
            'Vous allez recevoir un SMS avec un code de verification \n sur +212 ${widget.phoneNumber}',
        style: const TextStyle(color: Colors.white),
        children: const [
          TextSpan(
            text: '\tModifiez votre numéro',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableTextWithLine(String text, void Function()? onTap) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 1,
              width: 50,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
