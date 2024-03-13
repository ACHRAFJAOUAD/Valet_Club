import 'package:valet/widgets/widgets.dart';
import 'package:valet/screens/password.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Register extends StatefulWidget {
  final String phoneNumber;

  const Register({super.key, required this.phoneNumber});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late FocusNode _nomFocusNode;
  late FocusNode _prenomFocusNode;
  late FocusNode _emailFocusNode;
  late FocusNode _phoneNumberFocusNode;

  @override
  void initState() {
    super.initState();
    _phoneNumberController.text = widget.phoneNumber;

    _nomFocusNode = FocusNode();
    _prenomFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _phoneNumberFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nomFocusNode.dispose();
    _prenomFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneNumberFocusNode.dispose();
    super.dispose();
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
                  const SizedBox(height: 39),
                  _buildRegisterForm(),
                  const SizedBox(height: 16),
                  _buildConnexionButton(),
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

  Widget _buildRegisterForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          TextFormField(
            controller: _nomController,
            focusNode: _nomFocusNode,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Nom",
              labelStyle: const TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
              ),
              suffixIcon: _buildClearIconButton(_nomController, _nomFocusNode),
            ),
            validator: (val) {
              if (val!.isEmpty) {
                return "Please enter your nom";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _prenomController,
            focusNode: _prenomFocusNode,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Prenom",
              labelStyle: const TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
              ),
              suffixIcon:
                  _buildClearIconButton(_prenomController, _prenomFocusNode),
            ),
            validator: (val) {
              if (val!.isEmpty) {
                return "Please enter your prenom";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Email",
              labelStyle: const TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
              ),
              suffixIcon:
                  _buildClearIconButton(_emailController, _emailFocusNode),
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
              suffixIcon: _buildClearIconButton(
                  _phoneNumberController, _phoneNumberFocusNode),
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
        ],
      ),
    );
  }

  Widget _buildClearIconButton(
      TextEditingController controller, FocusNode focusNode) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        final hasText = value.text.isNotEmpty;
        return IconButton(
          onPressed: hasText
              ? () {
                  setState(() {
                    controller.clear();
                  });
                }
              : null,
          icon: hasText
              ? const Icon(Icons.clear, color: Colors.white)
              : const SizedBox(),
        );
      },
    );
  }

  Widget _buildConnexionButton() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        child: MaterialButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Password(
                    email: _emailController.text,
                    nom: _nomController.text,
                    prenom: _prenomController.text,
                    phoneNumber: widget.phoneNumber,
                  ),
                ),
              );
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
}
