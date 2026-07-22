import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../home/home_screen.dart';
import '../../splash/widgets/luxury_background.dart';
import 'package:url_launcher/url_launcher.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() =>
      _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen>
    with SingleTickerProviderStateMixin {

  final String uid = FirebaseAuth.instance.currentUser!.uid;

  late final AnimationController animationController;

  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    if (_hasNavigated) return;

    _hasNavigated = true;

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
        (route) => false,
      );
    });
  }
Future<void> _contactSupport({
  required String firstName,
  required String shopName,
}) async {
  final phone = FirebaseAuth.instance.currentUser?.email
          ?.replaceAll("@yani.app", "") ??
      "";

  final message = Uri.encodeComponent('''
Hello YANI Jewellery Support,

I need assistance with my account verification.

Name: $firstName
Shop: $shopName
Phone: +$phone

Please help me.

Thank you.
''');

  final Uri whatsapp = Uri.parse(
    "https://wa.me/917897897441?text=$message",
  );

  if (await canLaunchUrl(whatsapp)) {
    await launchUrl(
      whatsapp,
      mode: LaunchMode.externalApplication,
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LuxuryBackground(
        child: SafeArea(
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection("appUsers")
                .doc(uid)
                .snapshots(),
            builder: (context, snapshot) {

              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    snapshot.error.toString(),
                  ),
                );
              }

              if (!snapshot.hasData ||
                  !snapshot.data!.exists) {
                return const Center(
                  child: Text(
                    "Verification data not found.",
                  ),
                );
              }

              final data = snapshot.data!.data()!;

              final status =
                  (data["verificationStatus"] ??
                          "pending")
                      .toString();

              final rejectedReason =
                  (data["rejectedReason"] ?? "")
                      .toString();

              final firstName =
                  (data["firstName"] ?? "")
                      .toString();

              final shopName =
                  (data["shopName"] ?? "")
                      .toString();

              if (status == "approved") {
                _navigateToHome();
              }

              return AnimatedSwitcher(
                duration:
                    const Duration(milliseconds: 400),
                child: _buildBody(
                  status: status,
                  rejectedReason: rejectedReason,
                  firstName: firstName,
                  shopName: shopName,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody({
    required String status,
    required String rejectedReason,
    required String firstName,
    required String shopName,
  }) {
    final isPending = status == "pending";
final isApproved = status == "approved";
final isRejected = status == "rejected";
final isSuspended = status == "suspended";

Color statusColor = Colors.orange;
IconData statusIcon = Icons.hourglass_top_rounded;

String title = "Verification In Progress";

String subtitle =
    "Hi $firstName, our team is reviewing your business information. This usually takes less than 24 hours.";

if (isApproved) {
  statusColor = Colors.green;
  statusIcon = Icons.verified_rounded;
  title = "Account Approved";
  subtitle =
      "Congratulations $firstName! Your wholesale account has been successfully verified.";
}

if (isRejected) {
  statusColor = Colors.red;
  statusIcon = Icons.cancel_rounded;
  title = "Verification Rejected";
  subtitle =
      "We couldn't verify your account at this time. Please review the reason below.";
}

if (isSuspended) {
  statusColor = Colors.deepOrange;
  statusIcon = Icons.block_rounded;
  title = "Account Suspended";
  subtitle =
      "Your account is temporarily suspended. Please contact support.";
}

return SingleChildScrollView(
  padding: const EdgeInsets.fromLTRB(22, 25, 22, 40),
  child: Column(
    children: [

      const SizedBox(height: 10),

      RotationTransition(
        turns: Tween(begin: 0.0, end: 1.0)
            .animate(animationController),
        child: Container(
          height: 110,
          width: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: statusColor.withOpacity(.08),
            border: Border.all(
              color: statusColor.withOpacity(.25),
              width: 2,
            ),
          ),
          child: Icon(
            statusIcon,
            size: 54,
            color: statusColor,
          ),
        ),
      ),

      const SizedBox(height: 28),

      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.95),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 30,
              offset: const Offset(0, 15),
            )
          ],
        ),
        child: Column(
          children: [

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                height: 1.5,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Business Details",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [

                      const Icon(
                        Icons.store,
                        size: 20,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          shopName,
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [

                      const Icon(
                        Icons.person,
                        size: 20,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(firstName),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Verification Progress",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
            ),

            const SizedBox(height: 24),

            _timelineTile(
              completed: true,
              title: "Registration Completed",
              subtitle:
                  "Your account has been created successfully.",
              icon: Icons.person_add_alt_1,
              color: Colors.green,
            ),

            _timelineTile(
              completed: true,
              title: "Phone Number Verified",
              subtitle:
                  "OTP verification completed.",
              icon: Icons.phone_android,
              color: Colors.green,
            ),

            _timelineTile(
              completed:
                  isApproved ||
                  isRejected ||
                  isSuspended,
              loading: isPending,
              title: "Business Verification",
              subtitle:
                  "Our admin team is reviewing your details.",
              icon: Icons.admin_panel_settings,
              color: statusColor,
            ),

            _timelineTile(
              completed: isApproved,
              title: "Account Activated",
              subtitle:
                  "Your wholesale account is now active.",
              icon: Icons.verified_user,
              color: Colors.green,
            ),
                        const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isApproved
                    ? Colors.green.shade50
                    : isRejected
                        ? Colors.red.shade50
                        : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isApproved
                      ? Colors.green.shade200
                      : isRejected
                          ? Colors.red.shade200
                          : Colors.orange.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isApproved
                        ? Icons.verified
                        : isRejected
                            ? Icons.error_outline
                            : Icons.schedule,
                    color: statusColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isApproved
                          ? "Your account has been successfully verified."
                          : isRejected
                              ? "Your verification requires attention."
                              : "Estimated verification time: Within 24 hours.",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (isRejected) ...[
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.red.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.report_problem_outlined,
                          color: Colors.red,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Reason for Rejection",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      rejectedReason.isEmpty
                          ? "No reason has been provided by the administrator."
                          : rejectedReason,
                      style: const TextStyle(height: 1.5),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: () {
  _contactSupport(
    firstName: firstName,
    shopName: shopName,
  );
},
                icon: const Icon(Icons.support_agent),
                label: const Text(
                  "Contact Support",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lock_outline,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Your information is securely encrypted and reviewed only by authorized YANI Jewellery administrators.",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      height: 1.5,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      const SizedBox(height: 40),
    ],
  ),
);
}
Widget _timelineTile({
  required bool completed,
  required String title,
  required String subtitle,
  required IconData icon,
  required Color color,
  bool loading = false,
}) {
  return IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Column(
          children: [

            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: completed
                    ? LinearGradient(
                        colors: [
                          color,
                          color.withOpacity(.75),
                        ],
                      )
                    : null,
                color:
                    completed ? null : Colors.grey.shade200,
                boxShadow: completed
                    ? [
                        BoxShadow(
                          color: color.withOpacity(.35),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
              ),
              child: loading
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor:
                            AlwaysStoppedAnimation(color),
                      ),
                    )
                  : Icon(
                      completed
                          ? Icons.check_rounded
                          : icon,
                      color: completed
                          ? Colors.white
                          : Colors.grey.shade600,
                    ),
            ),

            Container(
              width: 2,
              height: 48,
              color: Colors.grey.shade300,
            ),
          ],
        ),

        const SizedBox(width: 18),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
    }