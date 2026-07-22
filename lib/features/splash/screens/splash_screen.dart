import 'dart:async';

import 'package:flutter/material.dart';

import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _logoController.forward();

    Future.delayed(const Duration(milliseconds: 500), () {
      _fadeController.forward();
    });

    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 900),
          pageBuilder: (_, __, ___) => const WelcomeScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xffFFFDFD),
              Color(0xffFFF6F7),
              Color(0xffFFF2F5),
            ],
          ),
        ),
        child: Stack(
          children: [
            /// Top Glow
            Positioned(
              top: -120,
              right: -100,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xffF8DDE7).withOpacity(.45),
                ),
              ),
            ),

            /// Bottom Glow
            Positioned(
              bottom: -150,
              left: -120,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xffFFE7EF).withOpacity(.55),
                ),
              ),
            ),

            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: Tween<double>(
                    begin: .75,
                    end: 1,
                  ).animate(_scaleAnimation),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xffD9A4BA)
                                  .withOpacity(.35),
                              blurRadius: 60,
                              spreadRadius: 15,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          "assets/logos/logo.png",
                          width: 190,
                        ),
                      ),

                      const SizedBox(height: 35),

                      const Text(
                        "YANI JEWELLERY",
                        style: TextStyle(
                          fontSize: 42,
                          letterSpacing: 5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff632A44),
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        "FINE JEWELLERY",
                        style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 7,
                          color: Color(0xffC9A54C),
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 35),

                      Container(
                        width: 120,
                        height: 1.2,
                        color: const Color(0xffD9BC72),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}