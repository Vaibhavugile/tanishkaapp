import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../home/home_screen.dart';
import '../../splash/widgets/luxury_background.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_textfield.dart';
import '../widgets/password_field.dart';
import 'signup_screen.dart';
import 'verification_screen.dart';
import '../../../services/login_router_service.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

 Future<void> login() async {
  FocusScope.of(context).unfocus();

  final phone = phoneController.text.trim();
  final password = passwordController.text.trim();

  if (phone.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Please enter your mobile number.",
        ),
      ),
    );
    return;
  }

  if (phone.length != 10) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Please enter a valid 10-digit mobile number.",
        ),
      ),
    );
    return;
  }

  if (password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Please enter your password.",
        ),
      ),
    );
    return;
  }

  try {
    setState(() {
      isLoading = true;
    });

    final email = "91$phone@yani.app";

    final credential =
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (!mounted) return;

    await LoginRouterService.instance.routeUser(
      context: context,
      firebaseUser: credential.user!,
    );
  } on FirebaseAuthException catch (e) {
    if (!mounted) return;

    String message = "Unable to login.";

    switch (e.code) {
      case "invalid-credential":
      case "user-not-found":
        message =
            "Invalid mobile number or password.";
        break;

      case "wrong-password":
        message = "Incorrect password.";
        break;

      case "too-many-requests":
        message =
            "Too many login attempts. Please try again later.";
        break;

      case "network-request-failed":
        message =
            "No internet connection. Please try again.";
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Something went wrong.\n$e",
        ),
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LuxuryBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 35),

                const AuthHeader(
                  title: "Welcome Back",
                  subtitle:
                      "Login with your mobile number to continue your luxury jewellery experience.",
                ),

                const SizedBox(height: 45),

                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 30,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffFFFEFD).withOpacity(.94),
                        borderRadius: BorderRadius.circular(34),
                        border: Border.all(
                          color: Colors.white.withOpacity(.85),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.withOpacity(.08),
                            blurRadius: 45,
                            spreadRadius: 2,
                            offset: const Offset(0, 20),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(.05),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff2E2E2E),
                              ),
                            ),
                          ),

                          const SizedBox(height: 6),

                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Access your jewellery business account.",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          AuthTextField(
                            controller: phoneController,
                            hint: "Mobile Number",
                            icon: Icons.phone_android_rounded,
                            keyboardType: TextInputType.phone,
                          ),

                          const SizedBox(height: 20),

                          PasswordField(
                            controller: passwordController,
                          ),
                                                    const SizedBox(height: 10),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                // TODO: Forgot Password Screen
                              },
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: Color(0xffD81B78),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 25),

                          AuthButton(
  text: "Login",
  isLoading: isLoading,
  onTap: login,
),

                          const SizedBox(height: 28),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account?",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                              TextButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const SignupScreen(),
                                          ),
                                        );
                                      },
                                child: const Text(
                                  "Create Account",
                                  style: TextStyle(
                                    color: Color(0xffD81B78),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
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
                        Icons.verified_user_rounded,
                        color: Color(0xffD81B78),
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "256-bit Secure Encryption",
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