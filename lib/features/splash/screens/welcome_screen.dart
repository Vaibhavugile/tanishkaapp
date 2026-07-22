import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../home/home_screen.dart';
import '../../auth/screens/verification_screen.dart';
import '../widgets/brand_title.dart';
import '../widgets/luxury_background.dart';
import '../widgets/luxury_button.dart';
import '../widgets/sparkle_background.dart';
import '../../auth/screens/login_screen.dart';
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
Future<void> _continue(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;

  // User is not logged in
  if (user == null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
    return;
  }

  try {
    final doc = await FirebaseFirestore.instance
        .collection("appUsers")
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      await FirebaseAuth.instance.signOut();

      if (!context.mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
      return;
    }

    final data = doc.data()!;

    final status =
        (data["verificationStatus"] ?? "pending").toString();

    if (!context.mounted) return;

    switch (status) {
      case "approved":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
        break;

      case "pending":
      case "rejected":
      case "suspended":
      default:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const VerificationScreen(),
          ),
        );
        break;
    }
  } catch (e) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Something went wrong.\n$e"),
      ),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LuxuryBackground(
        child: SafeArea(
          child: Stack(
            children: [
              const SparkleBackground(),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                child: Column(
                  children: [
                    const Spacer(),

                    // Logo Glow
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xffD79AB1).withOpacity(.25),
                            blurRadius: 80,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          "assets/logos/logo.png",
                          width: 170,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    const BrandTitle(),

                    const SizedBox(height: 30),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: const Color(0xffE3C77A),
                          ),
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Icon(
                            Icons.diamond_outlined,
                            color: Color(0xffD4AF37),
                            size: 22,
                          ),
                        ),

                        Expanded(
                          child: Container(
                            height: 1,
                            color: const Color(0xffE3C77A),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 35),

                    const Text(
                      "Discover Timeless Luxury",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 31,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff4F2C37),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        "Explore handcrafted jewellery collections inspired by elegance, tradition and everlasting beauty.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.7,
                          color: Color(0xff7E6A71),
                        ),
                      ),
                    ),

                    const Spacer(),

                   LuxuryButton(
  onTap: () => _continue(context),
),
                    const SizedBox(height: 15),

                    const Text(
                      "Experience Luxury",
                      style: TextStyle(
                        letterSpacing: 2,
                        color: Color(0xff9B7B85),
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}