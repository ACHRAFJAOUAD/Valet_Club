// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// import 'package:valet_club/screens/landing.dart';
import 'package:valet/widgets/order_tracking.dart';

class Home extends StatelessWidget {
  const Home({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Map widget
          const OrderTracking(),
          // Center(
          //   child: ElevatedButton(
          //     child: const Text("Lougout"),
          //     onPressed: () {
          //       FirebaseAuth.instance.signOut().then((val) {
          //         print("Signed Out");
          //         Navigator.push(context,
          //             MaterialPageRoute(builder: (context) => const Landing()));
          //       });
          //     },
          //   ),
          // ),
          // Pop-up bar from the bottom

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 45),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLogo(
                    'assets/home.png',
                  ),
                  _buildLogo(
                    'assets/network.png',
                  ),
                  _buildLogo(
                    'assets/wallet.png',
                  ),
                  const Icon(Icons.person_outlined, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(String logoNamed) {
    return Image.asset(
      logoNamed,
      width: 24,
      height: 24,
    );
  }
}
