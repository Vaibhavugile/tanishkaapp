import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';

import '../../../services/auth_service.dart';
import '../../../utils/otp_generator.dart';

import '../../splash/widgets/luxury_background.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_textfield.dart';
import '../widgets/phone_number_field.dart';
import 'otp_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();

  Country selectedCountry = Country.parse('IN');

  bool agree = false;
  bool isLoading = false;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> sendOtp() async {
    if (firstNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your first name."),
        ),
      );
      return;
    }

    if (lastNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your last name."),
        ),
      );
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your mobile number."),
        ),
      );
      return;
    }

    if (!agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please accept Terms & Conditions."),
        ),
      );
      return;
    }

    final completePhone =
        "+${selectedCountry.phoneCode}${phoneController.text.trim()}";

    final otp = OtpGenerator.generate();

    try {
      setState(() {
        isLoading = true;
      });

      await AuthService.instance.sendOtp(
        phoneNumber: completePhone,
        otp: otp,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(
            phone: completePhone,
            otp: otp,
            firstName: firstNameController.text.trim(),
            lastName: lastNameController.text.trim(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst("Exception: ", ""),
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 25),

              const AuthHeader(
                title: "Create Account",
                subtitle:
                    "Join YANI Jewellery and discover timeless elegance.",
              ),

              const SizedBox(height: 40),

              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 520,
                  ),
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
                            "Personal Information",
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
                            "Create your jewellery business account.",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        Row(
                          children: [
                            Expanded(
                              child: AuthTextField(
                                controller: firstNameController,
                                hint: "First Name",
                                icon: Icons.person_outline_rounded,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AuthTextField(
                                controller: lastNameController,
                                hint: "Last Name",
                                icon: Icons.person_outline_rounded,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        PhoneNumberField(
                          controller: phoneController,
                          onCountryChanged: (country) {
                            selectedCountry = country;
                          },
                        ),

                        const SizedBox(height: 22),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: agree,
                              activeColor: const Color(0xffD81B78),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  agree = value ?? false;
                                });
                              },
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "I agree to the ",
                                      ),
                                      TextSpan(
                                        text: "Terms & Conditions",
                                        style: TextStyle(
                                          color: Color(0xffD81B78),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: " and ",
                                      ),
                                      TextSpan(
                                        text: "Privacy Policy",
                                        style: TextStyle(
                                          color: Color(0xffD81B78),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 26),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: isLoading
                              ? ElevatedButton(
                                  onPressed: null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xffD81B78),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  ),
                                )
                              : AuthButton(
                                  text: "Send OTP",
                                  onTap: sendOtp,
                                ),
                        ),

                        const SizedBox(height: 26),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already have an account?",
                              style: TextStyle(fontSize: 15),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Login",
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

              const SizedBox(height: 35),

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
                      "Your information is encrypted & secure",
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