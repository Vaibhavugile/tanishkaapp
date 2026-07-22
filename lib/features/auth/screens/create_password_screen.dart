import 'package:flutter/material.dart';

import '../../splash/widgets/luxury_background.dart';
import '../widgets/auth_button.dart';
import '../widgets/password_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'verification_screen.dart';
class CreatePasswordScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String phone;

  final String shopName;
  final String businessType;

  final String instagram;
  final String website;

  final String gstNumber;

  final String address;
  final String pincode;

  final String city;
  final String state;

  const CreatePasswordScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.phone,

    required this.shopName,
    required this.businessType,

    required this.instagram,
    required this.website,

    required this.gstNumber,

    required this.address,
    required this.pincode,

    required this.city,
    required this.state,
  });

  @override
  State<CreatePasswordScreen> createState() =>
      _CreatePasswordScreenState();
}

class _CreatePasswordScreenState
    extends State<CreatePasswordScreen> {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
bool isLoading = false;
  @override
  void dispose() {
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> createAccount() async {
  final password = passwordController.text.trim();
  final confirm = confirmController.text.trim();

  if (password.length < 6) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Password should be at least 6 characters."),
      ),
    );
    return;
  }

  if (password != confirm) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Passwords do not match."),
      ),
    );
    return;
  }

  try {
    setState(() {
      isLoading = true;
    });

    final phone = widget.phone.replaceAll("+", "");
    final email = "$phone@yani.app";

    final credential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    await FirebaseFirestore.instance
        .collection("appUsers")
        .doc(uid)
        .set({
      // ===========================
      // USER
      // ===========================

      "uid": uid,
      "firstName": widget.firstName,
      "lastName": widget.lastName,
      "phone": widget.phone,
      "email": email,

      // ===========================
      // BUSINESS
      // ===========================

      "shopName": widget.shopName,
      "businessType": widget.businessType,
      "instagram": widget.instagram,
      "website": widget.website,
      "gstNumber": widget.gstNumber,
      "address": widget.address,
      "pincode": widget.pincode,
      "city": widget.city,
      "state": widget.state,

      // ===========================
      // ROLE
      // ===========================

      "role": "seller",

      // ===========================
      // VERIFICATION
      // ===========================

      "verificationStatus": "pending",

      "registrationCompleted": true,
      "otpVerified": true,
      "adminVerified": false,

      // ===========================
      // ACCOUNT
      // ===========================

      "isVerified": false,
      "isActive": false,
      "isBlocked": false,

      // ===========================
      // ADMIN
      // ===========================

      "approvedBy": "",
      "approvedAt": null,
      "rejectedReason": "",

      // ===========================
      // TIMESTAMPS
      // ===========================

      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    showDialog(
  context: context,
  barrierDismissible: false,
  builder: (_) => AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    content: const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.verified_rounded,
          color: Colors.green,
          size: 70,
        ),
        SizedBox(height: 20),
        Text(
          "Account Created Successfully!",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "Your account has been submitted for admin verification.",
          textAlign: TextAlign.center,
        ),
      ],
    ),
  ),
);

await Future.delayed(const Duration(seconds: 2));

if (!mounted) return;

Navigator.pop(context);

Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => const VerificationScreen(),
  ),
);
    if (!mounted) return;

    // TODO:
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => const VerificationScreen(),
    //   ),
    // );

  } on FirebaseAuthException catch (e) {
    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    String message = "Unable to create account.";

    switch (e.code) {
      case "email-already-in-use":
        message = "An account already exists with this mobile number.";
        break;

      case "weak-password":
        message = "Please choose a stronger password.";
        break;

      case "invalid-email":
        message = "Invalid account information.";
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  } catch (e) {
    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Something went wrong.\n$e",
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
      return Scaffold(
    body: LuxuryBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 30),

              Image.asset(
                "assets/logos/logo.png",
                width: 120,
              ),

              const SizedBox(height: 25),

              const Text(
                "Create Password",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff2E2E2E),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Your mobile number has been verified.\nCreate a secure password to complete your account.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 45),

              PasswordField(
                controller: passwordController,
                hint: "Create Password",
              ),

              const SizedBox(height: 20),

              PasswordField(
                controller: confirmController,
                hint: "Confirm Password",
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xffF8F8F8),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Password Requirements",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text("✓ Minimum 6 characters"),
                    SizedBox(height: 6),
                    Text("✓ Use a strong password"),
                    SizedBox(height: 6),
                    Text("✓ Don't share your password"),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              AuthButton(
                text: "Create Account",
                onTap: createAccount,
              ),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.70),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      color: Color(0xffD81B78),
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Your password is securely encrypted",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    ),
  );
}
    }