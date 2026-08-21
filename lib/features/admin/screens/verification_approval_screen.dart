import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../services/admin_service.dart';

class VerificationApprovalScreen extends StatefulWidget {
  const VerificationApprovalScreen({super.key});

  @override
  State<VerificationApprovalScreen> createState() =>
      _VerificationApprovalScreenState();
}

class _VerificationApprovalScreenState
    extends State<VerificationApprovalScreen> {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  bool _isProcessing = false;

  Stream<QuerySnapshot<Map<String, dynamic>>>
      get _pendingUsers {
    return _firestore
        .collection("appUsers")
        .where(
          "verificationStatus",
          isEqualTo: "approved",
        )
        .where(
          "adminVerified",
          isEqualTo: false,
        )
        .snapshots();
  }

  // =========================================================
  // APPROVE
  // =========================================================

  Future<void> _approveUser(
    String uid,
    String name,
  ) async {
    if (_isProcessing) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Approve User?",
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            "Approve $name for wholesale access?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text("Cancel"),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor:
                    const Color(0xffD81B78),
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text("Approve"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await _firestore
          .collection("appUsers")
          .doc(uid)
          .update({
        "adminVerified": true,
        "approvedBy":
            AdminService.instance.uid,
        "approvedAt": Timestamp.now(),
        "rejectedReason": "",
        "verificationStatus": "approved",

        // IMPORTANT
        "role": "wholesale",
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          behavior:
              SnackBarBehavior.floating,
          backgroundColor:
              Colors.green.shade600,
          content: Text(
            "$name approved successfully.",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          behavior:
              SnackBarBehavior.floating,
          backgroundColor:
              Colors.red.shade600,
          content: Text(
            "Approval failed: $e",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // =========================================================
  // REJECT
  // =========================================================

  Future<void> _rejectUser(
    String uid,
    String name,
  ) async {
    final controller =
        TextEditingController();

    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          title: const Text(
            "Reject Verification",
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration:
                InputDecoration(
              hintText:
                  "Enter rejection reason",
              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
                  const Text("Cancel"),
            ),
            FilledButton(
              style:
                  FilledButton.styleFrom(
                backgroundColor:
                    Colors.red,
              ),
              onPressed: () {
                final text =
                    controller.text.trim();

                if (text.isEmpty) {
                  return;
                }

                Navigator.pop(
                  dialogContext,
                  text,
                );
              },
              child:
                  const Text("Reject"),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (reason == null ||
        reason.trim().isEmpty) {
      return;
    }

    try {
      await _firestore
          .collection("appUsers")
          .doc(uid)
          .update({
        "adminVerified": false,
        "approvedBy": "",
        "approvedAt": null,
        "rejectedReason":
            reason.trim(),
        "verificationStatus":
            "rejected",
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          behavior:
              SnackBarBehavior.floating,
          backgroundColor:
              Colors.orange.shade700,
          content: Text(
            "$name rejected.",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          behavior:
              SnackBarBehavior.floating,
          backgroundColor:
              Colors.red.shade600,
          content: Text(
            "Rejection failed: $e",
          ),
        ),
      );
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffFFF8FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor:
            const Color(0xff2C2C2C),
        title: const Text(
          "Verification Approval",
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: _pendingUsers,
        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(
                color:
                    Color(0xffD81B78),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(24),
                child: Text(
                  "Unable to load verification requests.\n\n${snapshot.error}",
                  textAlign:
                      TextAlign.center,
                ),
              ),
            );
          }

          final docs =
              snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_rounded,
                    size: 70,
                    color:
                        Color(0xffD81B78),
                  ),
                  SizedBox(height: 18),
                  Text(
                    "No Pending Approvals",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "All verification requests are handled.",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color:
                const Color(0xffD81B78),
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.all(18),
              itemCount: docs.length,
              itemBuilder:
                  (context, index) {
                final data =
                    docs[index].data();

                final uid =
                    docs[index].id;

                final firstName =
                    data["firstName"]
                            ?.toString() ??
                        "";

                final lastName =
                    data["lastName"]
                            ?.toString() ??
                        "";

                final name =
                    "$firstName $lastName"
                        .trim();

                final phone =
                    data["phone"]
                            ?.toString() ??
                        "";

                final email =
                    data["email"]
                            ?.toString() ??
                        "";

                final shopName =
                    data["shopName"]
                            ?.toString() ??
                        "";

                final city =
                    data["city"]
                            ?.toString() ??
                        "";

                final businessType =
                    data["businessType"]
                            ?.toString() ??
                        "";

                return _ApprovalCard(
                  name: name.isEmpty
                      ? "Unknown User"
                      : name,
                  phone: phone,
                  email: email,
                  shopName: shopName,
                  city: city,
                  businessType:
                      businessType,
                  onApprove: () =>
                      _approveUser(
                    uid,
                    name.isEmpty
                        ? "User"
                        : name,
                  ),
                  onReject: () =>
                      _rejectUser(
                    uid,
                    name.isEmpty
                        ? "User"
                        : name,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ===========================================================
// APPROVAL CARD
// ===========================================================

class _ApprovalCard
    extends StatelessWidget {
  final String name;
  final String phone;
  final String email;
  final String shopName;
  final String city;
  final String businessType;

  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ApprovalCard({
    required this.name,
    required this.phone,
    required this.email,
    required this.shopName,
    required this.city,
    required this.businessType,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(.05),
            blurRadius: 18,
            offset:
                const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration:
                    BoxDecoration(
                  color: const Color(
                    0xffFCE4EC,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color:
                      Color(0xffD81B78),
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      name,
                      style:
                          const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      phone,
                      style:
                          TextStyle(
                        color: Colors
                            .grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration:
                    BoxDecoration(
                  color: Colors.orange
                      .withOpacity(.10),
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child: const Text(
                  "Pending",
                  style: TextStyle(
                    color:
                        Colors.orange,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _InfoRow(
            icon: Icons.storefront_outlined,
            label: "Shop",
            value:
                shopName.isEmpty
                    ? "-"
                    : shopName,
          ),

          _InfoRow(
            icon: Icons.business_outlined,
            label: "Business",
            value:
                businessType.isEmpty
                    ? "-"
                    : businessType,
          ),

          _InfoRow(
            icon: Icons.location_on_outlined,
            label: "Location",
            value:
                city.isEmpty
                    ? "-"
                    : city,
          ),

          _InfoRow(
            icon: Icons.email_outlined,
            label: "Email",
            value:
                email.isEmpty
                    ? "-"
                    : email,
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child:
                    OutlinedButton(
                  onPressed:
                      onReject,
                  style:
                      OutlinedButton
                          .styleFrom(
                    foregroundColor:
                        Colors.red,
                    side:
                        const BorderSide(
                      color: Colors.red,
                    ),
                    minimumSize:
                        const Size(
                      0,
                      48,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                    ),
                  ),
                  child:
                      const Text(
                    "Reject",
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child:
                    ElevatedButton(
                  onPressed:
                      onApprove,
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        const Color(
                      0xffD81B78,
                    ),
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    minimumSize:
                        const Size(
                      0,
                      48,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                    ),
                  ),
                  child:
                      const Text(
                    "Approve",
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===========================================================
// INFO ROW
// ===========================================================

class _InfoRow
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 9,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color:
                const Color(0xffD81B78),
          ),

          const SizedBox(width: 10),

          SizedBox(
            width: 75,
            child: Text(
              label,
              style:
                  TextStyle(
                color:
                    Colors.grey.shade500,
                fontSize: 13,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style:
                  const TextStyle(
                fontSize: 13,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}