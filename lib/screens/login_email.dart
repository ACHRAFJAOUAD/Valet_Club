import 'package:firebase_auth/firebase_auth.dart';
import 'package:valet/screens/home.dart';

import 'package:flutter/material.dart';
import 'package:valet/screens/landing.dart';
import 'package:valet/widgets/widgets.dart';

class LoginEmail extends StatefulWidget {
  const LoginEmail({super.key});

  @override
  State<LoginEmail> createState() => _LoginEmailState();
}

class _LoginEmailState extends State<LoginEmail> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;
  String _error = '';

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
                                  horizontal: 0.2, vertical: 5.0),
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
                  const SizedBox(height: 39),
                  _buildLoginEmailForm(),
                  const SizedBox(height: 16),
                  _buildConnexionButton(),
                  const SizedBox(height: 10),
                  const Center(
                      child: Text("Ou connectez-vous avec",
                          style: TextStyle(color: Colors.white))),
                  const SizedBox(height: 18),
                  _buildNumberConnexionButton(),
                  if (_error.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        _error,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
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

  Widget _buildLoginEmailForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Email",
              labelStyle: const TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            validator: (val) {
              if (val!.isEmpty) {
                return "Please enter your email";
              }
              if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                  .hasMatch(val)) {
                return "Please enter a valid email address";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _isObscure,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Mot de passe",
              labelStyle: const TextStyle(color: Colors.white),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure;
                  });
                },
                icon: Icon(
                  _isObscure ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnexionButton() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        child: MaterialButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              try {
                await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: _emailController.text,
                    password: _passwordController.text);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Home(),
                  ),
                );
              } on FirebaseAuthException catch (e) {
                if (e.code == 'user-not-found' || e.code == 'wrong-password') {
                  setState(() {
                    _error = 'Invalid email or password';
                  });
                } else {
                  setState(() {
                    _error = 'An error . Please try again .';
                  });
                }
              } catch (e) {
                print(e);
                setState(() {
                  _error = 'An unexpected error . Please try again .';
                });
              }
            } else {
              setState(() {
                _error = 'Please fill in both email and password fields';
              });
            }
          },
          color: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            "Connexion",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberConnexionButton() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        child: MaterialButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Landing(),
              ),
            );
          },
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: const SizedBox(
            width: 271,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  "Poursuivre avec votre Numéro de télé",
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
