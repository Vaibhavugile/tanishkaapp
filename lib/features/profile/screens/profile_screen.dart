import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color primary = Color(0xffE91E63);
  static const Color dark = Color(0xff241B2F);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text("Please login again."),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF8F7FA),

      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection("appUsers")
              .doc(user.uid)
              .snapshots(),

          builder: (context, snapshot) {
            ///////////////////////////////////////////////////////
            /// LOADING
            ///////////////////////////////////////////////////////

            if (snapshot.connectionState ==
                    ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  color: primary,
                ),
              );
            }

            ///////////////////////////////////////////////////////
            /// ERROR
            ///////////////////////////////////////////////////////

            if (snapshot.hasError) {
              return _ErrorView(
                message: "Unable to load your profile.",
                onRetry: () {
                  // StreamBuilder will reconnect automatically.
                  // This simply rebuilds the screen.
                  (context as Element).markNeedsBuild();
                },
              );
            }

            ///////////////////////////////////////////////////////
            /// DOCUMENT DOES NOT EXIST
            ///////////////////////////////////////////////////////

            if (!snapshot.hasData ||
                !snapshot.data!.exists) {
              return const Center(
                child: Text(
                  "Profile not found.",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }

            ///////////////////////////////////////////////////////
            /// DATA
            ///////////////////////////////////////////////////////

            final data =
                snapshot.data!.data() ?? {};

            return RefreshIndicator(
              color: primary,

              onRefresh: () async {
                await FirebaseFirestore.instance
                    .collection("appUsers")
                    .doc(user.uid)
                    .get(
                      const GetOptions(
                        source: Source.server,
                      ),
                    );
              },

              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),

                slivers: [
                  ///////////////////////////////////////////////////
                  /// TOP BAR
                  ///////////////////////////////////////////////////

                  SliverToBoxAdapter(
                    child: _buildTopBar(context),
                  ),

                  ///////////////////////////////////////////////////
                  /// PROFILE HEADER
                  ///////////////////////////////////////////////////

                  SliverToBoxAdapter(
                    child: _buildProfileHeader(data),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 18),
                  ),

                  ///////////////////////////////////////////////////
                  /// BUSINESS INFORMATION
                  ///////////////////////////////////////////////////

                  SliverToBoxAdapter(
                    child: _buildSection(
                      title: "Business Information",
                      icon: Icons.storefront_outlined,
                      children: [
                        _InfoTile(
                          icon: Icons.store_outlined,
                          title: "Shop Name",
                          value:
                              _value(data["shopName"]),
                        ),

                        _InfoTile(
                          icon: Icons.business_center_outlined,
                          title: "Business Type",
                          value:
                              _value(data["businessType"]),
                        ),

                        _InfoTile(
                          icon: Icons.badge_outlined,
                          title: "GST Number",
                          value:
                              _value(
                                data["gstNumber"],
                                fallback: "Not provided",
                              ),
                        ),

                        _InfoTile(
                          icon: Icons.language_outlined,
                          title: "Website",
                          value:
                              _value(
                                data["website"],
                                fallback: "Not provided",
                              ),
                        ),

                        _InfoTile(
                          icon: Icons.camera_alt_outlined,
                          title: "Instagram",
                          value:
                              _value(
                                data["instagram"],
                                fallback: "Not provided",
                              ),
                        ),
                      ],
                    ),
                  ),

                  ///////////////////////////////////////////////////
                  /// CONTACT INFORMATION
                  ///////////////////////////////////////////////////

                  SliverToBoxAdapter(
                    child: _buildSection(
                      title: "Contact Information",
                      icon: Icons.contact_phone_outlined,
                      children: [
                        _InfoTile(
                          icon: Icons.person_outline,
                          title: "Full Name",
                          value: _fullName(data),
                        ),

                        _InfoTile(
                          icon: Icons.phone_outlined,
                          title: "Phone",
                          value:
                              _value(data["phone"]),
                        ),

                        _InfoTile(
                          icon: Icons.email_outlined,
                          title: "Email",
                          value:
                              _value(data["email"]),
                        ),
                      ],
                    ),
                  ),

                  ///////////////////////////////////////////////////
                  /// ADDRESS
                  ///////////////////////////////////////////////////

                  SliverToBoxAdapter(
                    child: _buildSection(
                      title: "Business Address",
                      icon: Icons.location_on_outlined,
                      children: [
                        _InfoTile(
                          icon: Icons.location_city_outlined,
                          title: "Address",
                          value:
                              _value(
                                data["address"],
                                fallback: "Not provided",
                              ),
                        ),

                        _InfoTile(
                          icon: Icons.location_city_outlined,
                          title: "City",
                          value:
                              _value(data["city"]),
                        ),

                        _InfoTile(
                          icon: Icons.map_outlined,
                          title: "State",
                          value:
                              _value(data["state"]),
                        ),

                        _InfoTile(
                          icon: Icons.pin_drop_outlined,
                          title: "Pincode",
                          value:
                              _value(data["pincode"]),
                        ),
                      ],
                    ),
                  ),

                  ///////////////////////////////////////////////////
                  /// ACCOUNT STATUS
                  ///////////////////////////////////////////////////

                  SliverToBoxAdapter(
                    child: _buildAccountStatus(data),
                  ),

                  ///////////////////////////////////////////////////
                  /// ACTIONS
                  ///////////////////////////////////////////////////

                  SliverToBoxAdapter(
                    child: _buildActions(context),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 35),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////////
  /// TOP BAR
  ///////////////////////////////////////////////////////////////

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        8,
      ),

      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  "My Profile",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: dark,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  "Manage your account & business",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 46,
            height: 46,

            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.06),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),

            child: const Icon(
              Icons.settings_outlined,
              color: dark,
            ),
          ),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////////////
  /// PROFILE HEADER
  ///////////////////////////////////////////////////////////////

  Widget _buildProfileHeader(
    Map<String, dynamic> data,
  ) {
    final name = _fullName(data);

    final shopName =
        _value(
          data["shopName"],
          fallback: "Business Account",
        );

    final verified =
        data["isVerified"] == true;

    final adminVerified =
        data["adminVerified"] == true;

    final verificationStatus =
        _value(
          data["verificationStatus"],
          fallback: "Pending",
        );

    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        0,
      ),

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: [
            Color(0xff241B2F),
            Color(0xff3A284A),
          ],
        ),

        borderRadius:
            BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.12),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              /////////////////////////////////////////////////////
              /// AVATAR
              /////////////////////////////////////////////////////

              Container(
                width: 72,
                height: 72,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  gradient:
                      const LinearGradient(
                    colors: [
                      Color(0xffF8BBD0),
                      Color(0xffE91E63),
                    ],
                  ),

                  border: Border.all(
                    color: Colors.white
                        .withOpacity(.35),
                    width: 2,
                  ),
                ),

                child: Center(
                  child: Text(
                    _initials(data),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              /////////////////////////////////////////////////////
              /// NAME
              /////////////////////////////////////////////////////

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      shopName,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,

                      style: TextStyle(
                        color: Colors.white
                            .withOpacity(.72),
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          /////////////////////////////////////////////////////////
          /// STATUS
          /////////////////////////////////////////////////////////

          Wrap(
            spacing: 8,
            runSpacing: 8,

            children: [
              _StatusBadge(
                icon: verified
                    ? Icons.verified
                    : Icons.pending_outlined,

                label: verified
                    ? "Verified"
                    : "Verification Pending",

                color: verified
                    ? Colors.green
                    : Colors.orange,
              ),

              if (adminVerified)
                const _StatusBadge(
                  icon: Icons.verified_user_outlined,
                  label: "Admin Approved",
                  color: Colors.green,
                ),

              _StatusBadge(
                icon: Icons.storefront_outlined,
                label: _value(
                  data["role"],
                  fallback: "Customer",
                ).toUpperCase(),

                color: primary,
              ),
            ],
          ),

          const SizedBox(height: 18),

          /////////////////////////////////////////////////////////
          /// VERIFICATION STATUS
          /////////////////////////////////////////////////////////

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),

            decoration: BoxDecoration(
              color: Colors.white
                  .withOpacity(.08),

              borderRadius:
                  BorderRadius.circular(16),

              border: Border.all(
                color: Colors.white
                    .withOpacity(.10),
              ),
            ),

            child: Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: Colors.white70,
                  size: 20,
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    "Verification Status",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ),

                Text(
                  verificationStatus
                      .toUpperCase(),

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////////////
  /// SECTION
  ///////////////////////////////////////////////////////////////

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        10,
        16,
        0,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.045),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          18,
          18,
          18,
          10,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,

                  decoration: BoxDecoration(
                    color:
                        primary.withOpacity(.09),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),

                  child: Icon(
                    icon,
                    color: primary,
                    size: 21,
                  ),
                ),

                const SizedBox(width: 12),

                Text(
                  title,
                  style: const TextStyle(
                    color: dark,
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            ...children,
          ],
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////////
  /// ACCOUNT STATUS
  ///////////////////////////////////////////////////////////////

  Widget _buildAccountStatus(
    Map<String, dynamic> data,
  ) {
    final active =
        data["isActive"] == true;

    final blocked =
        data["isBlocked"] == true;

    final registrationCompleted =
        data["registrationCompleted"] == true;

    final otpVerified =
        data["otpVerified"] == true;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        10,
        16,
        0,
      ),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.045),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            "Account Status",
            style: TextStyle(
              color: dark,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 15),

          _AccountStatusRow(
            icon: Icons.power_settings_new,
            title: "Account",
            value: active
                ? "Active"
                : "Inactive",
            positive: active,
          ),

          _AccountStatusRow(
            icon: Icons.block_outlined,
            title: "Blocked",
            value: blocked
                ? "Yes"
                : "No",
            positive: !blocked,
          ),

          _AccountStatusRow(
            icon: Icons.phone_android_outlined,
            title: "OTP Verification",
            value: otpVerified
                ? "Verified"
                : "Pending",
            positive: otpVerified,
          ),

          _AccountStatusRow(
            icon: Icons.assignment_turned_in_outlined,
            title: "Registration",
            value:
                registrationCompleted
                    ? "Completed"
                    : "Incomplete",
            positive:
                registrationCompleted,
          ),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////////////
  /// ACTIONS
  ///////////////////////////////////////////////////////////////

  Widget _buildActions(
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        22,
        16,
        0,
      ),

      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,

            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,

                elevation: 0,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(18),
                ),
              ),

              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Edit Profile coming soon.",
                    ),
                  ),
                );
              },

              icon: const Icon(
                Icons.edit_outlined,
              ),

              label: const Text(
                "Edit Profile",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 54,

            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    Colors.red.shade700,

                side: BorderSide(
                  color: Colors.red.shade200,
                ),

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(18),
                ),
              ),

              onPressed: () async {
                await _signOut(context);
              },

              icon: const Icon(
                Icons.logout_rounded,
              ),

              label: const Text(
                "Sign Out",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////////////
  /// SIGN OUT
  ///////////////////////////////////////////////////////////////

  Future<void> _signOut(
    BuildContext context,
  ) async {
    final shouldLogout =
        await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(22),
          ),

          title: const Text(
            "Sign out?",
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),

          content: const Text(
            "Are you sure you want to sign out of your account?",
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },

              child: const Text(
                "Cancel",
              ),
            ),

            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor:
                    Colors.white,
              ),

              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },

              child: const Text(
                "Sign Out",
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    await FirebaseAuth.instance.signOut();

    if (!context.mounted) {
      return;
    }

    // Replace this with your actual login screen
    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );
  }

  ///////////////////////////////////////////////////////////////
  /// HELPERS
  ///////////////////////////////////////////////////////////////

  static String _value(
    dynamic value, {
    String fallback = "Not provided",
  }) {
    if (value == null) {
      return fallback;
    }

    final text =
        value.toString().trim();

    if (text.isEmpty) {
      return fallback;
    }

    return text;
  }

  static String _fullName(
    Map<String, dynamic> data,
  ) {
    final first =
        _value(
          data["firstName"],
          fallback: "",
        );

    final last =
        _value(
          data["lastName"],
          fallback: "",
        );

    final name =
        "$first $last".trim();

    return name.isEmpty
        ? "User"
        : name;
  }

  static String _initials(
    Map<String, dynamic> data,
  ) {
    final first =
        _value(
          data["firstName"],
          fallback: "",
        );

    final last =
        _value(
          data["lastName"],
          fallback: "",
        );

    String result = "";

    if (first.isNotEmpty) {
      result += first[0];
    }

    if (last.isNotEmpty) {
      result += last[0];
    }

    if (result.isEmpty) {
      return "U";
    }

    return result.toUpperCase();
  }
}

///////////////////////////////////////////////////////////////
/// INFO TILE
///////////////////////////////////////////////////////////////

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Container(
            width: 38,
            height: 38,

            decoration: BoxDecoration(
              color: const Color(
                0xffF7F4F8,
              ),

              borderRadius:
                  BorderRadius.circular(11),
            ),

            child: Icon(
              icon,
              size: 19,
              color: const Color(
                0xff62566C,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(
                      0xff241B2F,
                    ),
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////////
/// STATUS BADGE
///////////////////////////////////////////////////////////////

class _StatusBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),

      decoration: BoxDecoration(
        color: color.withOpacity(.16),
        borderRadius:
            BorderRadius.circular(30),

        border: Border.all(
          color: color.withOpacity(.25),
        ),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: Colors.white,
          ),

          const SizedBox(width: 6),

          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////////
/// ACCOUNT STATUS ROW
///////////////////////////////////////////////////////////////

class _AccountStatusRow
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool positive;

  const _AccountStatusRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    final color = positive
        ? Colors.green
        : Colors.red;

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 7,
      ),

      child: Row(
        children: [
          Icon(
            icon,
            size: 19,
            color: Colors.black45,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),

            decoration: BoxDecoration(
              color:
                  color.withOpacity(.09),
              borderRadius:
                  BorderRadius.circular(20),
            ),

            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////////
/// ERROR VIEW
///////////////////////////////////////////////////////////////

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 55,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 15),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: onRetry,
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}