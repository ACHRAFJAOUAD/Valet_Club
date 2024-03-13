import 'package:flutter/material.dart';
import 'package:valet/widgets/widgets.dart';
import 'package:valet/screens/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Password extends StatefulWidget {
  final String email;
  final String nom;
  final String prenom;
  final String phoneNumber;

  const Password({
    super.key,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.phoneNumber,
  });

  @override
  _PasswordState createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _passwordObscure = true;
  bool _confirmPasswordObscure = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildLogo(),
                  const SizedBox(height: 36),
                  _buildPasswordForm(),
                  const SizedBox(height: 16),
                  _buildConnexionButton(_isLoading),
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

  Widget _buildPasswordForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _passwordObscure,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Mot de passe",
              labelStyle: const TextStyle(color: Colors.white),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _passwordObscure = !_passwordObscure;
                  });
                },
                icon: Icon(
                  _passwordObscure ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            validator: (val) {
              if (val!.isEmpty) {
                return "Please enter a password";
              }
              if (val.length < 8) {
                return "Password must be at least 8 characters long";
              }
              return null;
            },
          ),
          const SizedBox(height: 26),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _confirmPasswordObscure,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Confirmez le mot de passe",
              labelStyle: const TextStyle(color: Colors.white),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _confirmPasswordObscure = !_confirmPasswordObscure;
                  });
                },
                icon: Icon(
                  _confirmPasswordObscure
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.white,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            validator: (val) {
              if (val!.isEmpty) {
                return "Please confirm your password";
              }
              if (val != _passwordController.text) {
                return "Passwords do not match";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConnexionButton(bool loading) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        child: loading
            ? CircularProgressIndicator(color: Colors.white)
            : MaterialButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _saveUserDataToFirebase();
                    setState(() {
                      _isLoading = true;
                    });

                    await Future.delayed(const Duration(seconds: 4));
                    _navigateToHomeScreen();
                  }
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

  void _saveUserDataToFirebase() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: widget.email,
        password: _passwordController.text,
      );

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': widget.email,
        'nom': widget.nom,
        'prenom': widget.prenom,
        'phoneNumber': widget.phoneNumber,
      });

      print('User registered and data saved to Firebase');
      _navigateToHomeScreen();
    } catch (err) {
      print('Error registering user and saving data: $err');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToHomeScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Home(),
      ),
    );
    print('Navigating to Home screen');
  }
}
