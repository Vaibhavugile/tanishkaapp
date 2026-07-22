import 'package:flutter/material.dart';

import '../../splash/widgets/luxury_background.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_textfield.dart';
import 'create_password_screen.dart';

class ShopDetailsScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String phone;

  const ShopDetailsScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.phone,
  });

  @override
  State<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends State<ShopDetailsScreen> {
  final shopController = TextEditingController();
  final instagramController = TextEditingController();
  final websiteController = TextEditingController();
  final gstController = TextEditingController();

  final addressController = TextEditingController();
  final pincodeController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();

  String businessType = "Retailer";

  final List<String> businessTypes = [
    "Retailer",
    "Wholesaler",
    "Manufacturer",
    "Distributor",
  ];

  @override
  void dispose() {
    shopController.dispose();
    instagramController.dispose();
    websiteController.dispose();
    gstController.dispose();

    addressController.dispose();
    pincodeController.dispose();
    cityController.dispose();
    stateController.dispose();

    super.dispose();
  }

  void continueNext() {
    if (shopController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your jewellery shop name."),
        ),
      );
      return;
    }

    if (cityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your city."),
        ),
      );
      return;
    }

    if (stateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your state."),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePasswordScreen(
          firstName: widget.firstName,
          lastName: widget.lastName,
          phone: widget.phone,

          shopName: shopController.text.trim(),
          businessType: businessType,

          instagram: instagramController.text.trim(),
          website: websiteController.text.trim(),

          gstNumber: gstController.text.trim(),

          address: addressController.text.trim(),
          pincode: pincodeController.text.trim(),

          city: cityController.text.trim(),
          state: stateController.text.trim(),
        ),
      ),
    );
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
                title: "Business Details",
                subtitle:
                    "Tell us about your jewellery business to personalize your experience.",
              ),

              const SizedBox(height: 40),

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
                            "Business Information",
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
                            "Help us personalize your business profile.",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        AuthTextField(
                          controller: shopController,
                          hint: "Jewellery Shop Name",
                          icon: Icons.storefront_outlined,
                        ),

                        const SizedBox(height: 20),

                        DropdownButtonFormField<String>(
                          value: businessType,
                          decoration: InputDecoration(
                            labelText: "Business Type",
                            prefixIcon: const Icon(
                              Icons.business_center_outlined,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: businessTypes
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              businessType = value!;
                            });
                          },
                        ),

                        const SizedBox(height: 20),

                        AuthTextField(
                          controller: instagramController,
                          hint: "Instagram Username (Optional)",
                          icon: Icons.camera_alt_outlined,
                        ),

                        const SizedBox(height: 20),

                        AuthTextField(
                          controller: websiteController,
                          hint: "Website (Optional)",
                          icon: Icons.language_outlined,
                        ),

                        const SizedBox(height: 20),

                        AuthTextField(
                          controller: gstController,
                          hint: "GST Number (Optional)",
                          icon: Icons.receipt_long_outlined,
                        ),

                        const SizedBox(height: 20),

                        AuthTextField(
                          controller: addressController,
                          hint: "Business Address",
                          icon: Icons.location_on_outlined,
                        ),

                        const SizedBox(height: 20),

                        AuthTextField(
                          controller: pincodeController,
                          hint: "Pincode",
                          icon: Icons.pin_drop_outlined,
                          keyboardType: TextInputType.number,
                        ),

                        const SizedBox(height: 20),

                        AuthTextField(
                          controller: cityController,
                          hint: "City",
                          icon: Icons.location_city_outlined,
                        ),

                        const SizedBox(height: 20),

                        AuthTextField(
                          controller: stateController,
                          hint: "State",
                          icon: Icons.map_outlined,
                        ),

                        const SizedBox(height: 30),

                        AuthButton(
                          text: "Continue",
                          onTap: continueNext,
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
                      Icons.business_center_rounded,
                      color: Color(0xffD81B78),
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Business details remain private & secure",
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