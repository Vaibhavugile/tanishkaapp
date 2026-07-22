import 'dart:async';

import 'package:flutter/material.dart';

import '../../splash/widgets/luxury_background.dart';
import '../widgets/auth_button.dart';
import 'shop_details_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String otp;
  final String firstName;
  final String lastName;

  const OtpScreen({
    super.key,
    required this.phone,
    required this.otp,
    required this.firstName,
    required this.lastName,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());

  int seconds = 60;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer?.cancel();

    seconds = 60;

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (seconds == 0) {
          timer.cancel();
        } else {
          setState(() {
            seconds--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();

    for (final c in controllers) {
      c.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LuxuryBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                Image.asset(
                  "assets/logos/logo.png",
                  width: 100,
                ),

                const SizedBox(height: 25),

                const Text(
                  "Verify Mobile Number",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  "We've sent a 6-digit verification code to\n${widget.phone}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 50),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    6,
                    (index) => SizedBox(
                      width: 48,
                      child: TextField(
                        controller: controllers[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        decoration: InputDecoration(
                          counterText: "",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            FocusScope.of(context).nextFocus();
                          } else if (value.isEmpty && index > 0) {
                            FocusScope.of(context).previousFocus();
                          }
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                Text(
                  "00:${seconds.toString().padLeft(2, '0')}",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xffD81B78),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: seconds == 0
                      ? () async {
                          startTimer();

                          // TODO:
                          // Call AuthService.instance.sendOtp(...)
                          // when implementing resend OTP.
                        }
                      : null,
                  child: const Text("Resend OTP"),
                ),

                const Spacer(),

                AuthButton(
                  text: "Verify OTP",
                  onTap: () {
                    final enteredOtp =
                        controllers.map((e) => e.text).join();

                    if (enteredOtp.length != 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter the 6-digit OTP."),
                        ),
                      );
                      return;
                    }

                    if (enteredOtp != widget.otp) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Invalid OTP. Please try again."),
                        ),
                      );
                      return;
                    }

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ShopDetailsScreen(
                          firstName: widget.firstName,
                          lastName: widget.lastName,
                          phone: widget.phone,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 35),
              ],
            ),
          ),
        ),
      ),
    );
  }
}