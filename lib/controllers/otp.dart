import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Otp {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  static String verifyId = "";

  // to send an OTP to the user
  static Future<void> sentOtp({
    required String phone,
    required Function errorStep,
    required Function nextStep,
  }) async {
    try {
      // Check if the phone number already exists in Firestore
      bool phoneNumberExists = await _phoneNumberExistsInFirestore(phone);
      if (phoneNumberExists) {
        // If the phone number exists, proceed to send OTP
        await _firebaseAuth.verifyPhoneNumber(
          timeout: const Duration(seconds: 30),
          phoneNumber: "+212$phone",
          verificationCompleted: (phoneAuthCredential) async {
            return;
          },
          verificationFailed: (error) async {
            return;
          },
          codeSent: (verificationId, forceResendingToken) async {
            verifyId = verificationId;
            nextStep();
          },
          codeAutoRetrievalTimeout: (verificationId) async {
            return;
          },
        );
      } else {
        // If the phone number does not exist, show an error message
        errorStep("Phone number not found");
      }
    } catch (e) {
      // Handle any errors that occur during the process
      errorStep(e.toString());
    }
  }

  // Verify the OTP code and login
  static Future<String> loginWithOtp({required String otp}) async {
    final cred =
        PhoneAuthProvider.credential(verificationId: verifyId, smsCode: otp);

    try {
      final user = await _firebaseAuth.signInWithCredential(cred);
      if (user.user != null) {
        return "Success";
      } else {
        return "Error in Otp login";
      }
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    } catch (e) {
      return e.toString();
    }
  }

  // Logout the user
  static Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // Check whether the user is logged in or not
  static Future<bool> isLoggedIn() async {
    var user = _firebaseAuth.currentUser;
    return user != null;
  }

  // Check if the phone number exists in Firestore
  static Future<bool> _phoneNumberExistsInFirestore(String phoneNumber) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('phoneNumber', isEqualTo: phoneNumber)
              .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception("Error checking phone number in Firestore: $e");
    }
  }
}
