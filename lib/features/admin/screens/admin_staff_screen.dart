import 'package:flutter/material.dart';

import '../../../models/admin_model.dart';
import '../../../models/admin_role.dart';
import '../../../models/admin_permissions.dart';
import '../../../services/admin_service.dart';
import 'package:cloud_functions/cloud_functions.dart';
class AdminStaffScreen extends StatefulWidget {
  const AdminStaffScreen({
    super.key,
  });

  @override
  State<AdminStaffScreen> createState() =>
      _AdminStaffScreenState();
}

class _AdminStaffScreenState
    extends State<AdminStaffScreen> {
  final AdminService _adminService =
      AdminService.instance;

  bool _loading = true;
  String? _error;

  List<AdminModel> _admins = [];

  @override
  void initState() {
    super.initState();

    _loadAdmins();
  }

  ///////////////////////////////////////////////////////////
  /// LOAD ADMINS
  ///////////////////////////////////////////////////////////

  Future<void> _loadAdmins() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final admins =
          await _adminService.getAdmins();

      if (!mounted) return;

      setState(() {
        _admins = admins;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  ///////////////////////////////////////////////////////////
  /// ROLE LABEL
  ///////////////////////////////////////////////////////////

  String _roleLabel(AdminRole role) {
    switch (role) {
      case AdminRole.superAdmin:
        return "Super Admin";

      case AdminRole.owner:
        return "Owner";

      case AdminRole.manager:
        return "Manager";

      case AdminRole.packing:
        return "Packing";

      case AdminRole.accounts:
        return "Accounts";

      case AdminRole.sales:
        return "Sales";

      case AdminRole.support:
        return "Support";
    }
  }

  ///////////////////////////////////////////////////////////
  /// ROLE COLOR
  ///////////////////////////////////////////////////////////

  Color _roleColor(AdminRole role) {
    switch (role) {
      case AdminRole.superAdmin:
        return const Color(0xffD81B78);

      case AdminRole.owner:
        return const Color(0xff8E44AD);

      case AdminRole.manager:
        return const Color(0xff2563EB);

      case AdminRole.packing:
        return const Color(0xffF59E0B);

      case AdminRole.accounts:
        return const Color(0xff16A34A);

      case AdminRole.sales:
        return const Color(0xff0891B2);

      case AdminRole.support:
        return const Color(0xff7C3AED);
    }
  }

  ///////////////////////////////////////////////////////////
  /// ADMIN CARD
  ///////////////////////////////////////////////////////////

  Widget _buildAdminCard(
    AdminModel admin,
  ) {
    final roleColor =
        _roleColor(admin.role);

    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(.05),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          /////////////////////////////////////////////////////
          /// PHOTO
          /////////////////////////////////////////////////////

          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xffFCE4EC),
            ),
            child: admin.photo.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      admin.photo,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) {
                        return const Icon(
                          Icons.person_rounded,
                          color:
                              Color(0xffD81B78),
                          size: 27,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.person_rounded,
                    color: Color(0xffD81B78),
                    size: 27,
                  ),
          ),

          const SizedBox(width: 14),

          /////////////////////////////////////////////////////
          /// DETAILS
          /////////////////////////////////////////////////////

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  admin.fullName,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(0xff241B2F),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  admin.email,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        Colors.grey.shade600,
                  ),
                ),

                if (admin.phone.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    "+91 ${admin.phone}",
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          Colors.grey.shade600,
                    ),
                  ),
                ],

                const SizedBox(height: 7),

                Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration:
                          BoxDecoration(
                        color: roleColor
                            .withOpacity(.10),
                        borderRadius:
                            BorderRadius
                                .circular(
                          20,
                        ),
                      ),
                      child: Text(
                        _roleLabel(
                          admin.role,
                        ),
                        style: TextStyle(
                          color: roleColor,
                          fontSize: 10,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Container(
                      width: 7,
                      height: 7,
                      decoration:
                          BoxDecoration(
                        color: admin.active
                            ? Colors.green
                            : Colors.red,
                        shape:
                            BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 5),

                    Text(
                      admin.active
                          ? "Active"
                          : "Inactive",
                      style: TextStyle(
                        color: admin.active
                            ? Colors.green
                            : Colors.red,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /////////////////////////////////////////////////////
          /// MENU
          /////////////////////////////////////////////////////

          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// ADD ADMIN
  ///////////////////////////////////////////////////////////
Future<Map<String, dynamic>> _createAdmin({
  required String fullName,
  required String email,
  required String phone,
  required String password,
  required AdminRole role,
  required Map<String, bool> permissions,
}) async {
  try {
    final functions =
        FirebaseFunctions.instanceFor(
      region: 'asia-south1',
    );

    final callable =
        functions.httpsCallable(
      'createAdmin',
    );

    final result = await callable.call({
      "fullName": fullName.trim(),
      "email": email.trim().toLowerCase(),
      "phone": phone.trim(),
      "password": password,
      "role": role.name,
      "permissions": permissions,
    });

    if (result.data is Map) {
      return Map<String, dynamic>.from(
        result.data as Map,
      );
    }

    return {
      "success": true,
      "message": "Admin created successfully.",
    };
  } on FirebaseFunctionsException catch (e) {
    throw Exception(
      e.message ??
          "Unable to create admin.",
    );
  } catch (e) {
    throw Exception(
      "Unable to create admin: $e",
    );
  }
}
  Future<void> _showAddAdminDialog() async {
    final formKey =
        GlobalKey<FormState>();

    final nameController =
        TextEditingController();

    final emailController =
        TextEditingController();

    final phoneController =
        TextEditingController();

    final passwordController =
        TextEditingController();

    AdminRole selectedRole =
        AdminRole.manager;

    /////////////////////////////////////////////////////////
    /// ALL PERMISSIONS
    /////////////////////////////////////////////////////////

    final Map<String, bool> permissions = {
      "canAssignOrders": true,
      "canCancelOrders": true,
      "canChat": true,
      "canCreateAdmins": true,
      "canCreateProducts": true,
      "canDeleteAdmins": true,
      "canDeleteMessages": true,
      "canDeleteProducts": true,
      "canEditAdmins": true,
      "canEditOrders": true,
      "canEditProducts": true,
      "canGenerateLabels": true,
      "canManageAdmins": true,
      "canManageInventory": true,
      "canManageSettings": true,
      "canMarkDamaged": true,
      "canMarkMissing": true,
      "canPackOrders": true,
      "canRefundPayments": true,
      "canRequestPayment": true,
      "canShipOrders": true,
      "canVerifyPayments": true,
      "canViewAuditLogs": true,
      "canViewOrders": true,
      "canViewProducts": true,
      "canViewReports": true,
    };

   final parentContext = context;

try {
  await showDialog(
    context: parentContext,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (
              context,
              setDialogState,
            ) {
              return AlertDialog(
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    24,
                  ),
                ),
                title: const Row(
                  children: [
                    Icon(
                      Icons
                          .admin_panel_settings_rounded,
                      color:
                          Color(0xffD81B78),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Add Admin",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                content: SizedBox(
                  width: 520,
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          //////////////////////////////////////////////////
                          /// FULL NAME
                          //////////////////////////////////////////////////

                          TextFormField(
                            controller:
                                nameController,
                            textCapitalization:
                                TextCapitalization
                                    .words,
                            decoration:
                                InputDecoration(
                              labelText:
                                  "Full Name",
                              prefixIcon:
                                  const Icon(
                                Icons
                                    .person_outline,
                              ),
                              border:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  14,
                                ),
                              ),
                            ),
                            validator:
                                (value) {
                              if (value ==
                                      null ||
                                  value
                                      .trim()
                                      .isEmpty) {
                                return "Enter full name";
                              }

                              return null;
                            },
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          //////////////////////////////////////////////////
                          /// EMAIL
                          //////////////////////////////////////////////////

                          TextFormField(
                            controller:
                                emailController,
                            keyboardType:
                                TextInputType
                                    .emailAddress,
                            decoration:
                                InputDecoration(
                              labelText:
                                  "Email",
                              prefixIcon:
                                  const Icon(
                                Icons
                                    .email_outlined,
                              ),
                              border:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  14,
                                ),
                              ),
                            ),
                            validator:
                                (value) {
                              if (value ==
                                      null ||
                                  value
                                      .trim()
                                      .isEmpty) {
                                return "Enter email";
                              }

                              if (!value
                                  .contains(
                                      "@")) {
                                return "Enter a valid email";
                              }

                              return null;
                            },
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          //////////////////////////////////////////////////
                          /// PHONE
                          //////////////////////////////////////////////////

                          TextFormField(
                            controller:
                                phoneController,
                            keyboardType:
                                TextInputType
                                    .phone,
                            maxLength: 10,
                            decoration:
                                InputDecoration(
                              labelText:
                                  "Phone",
                              counterText: "",
                              prefixText:
                                  "+91 ",
                              prefixIcon:
                                  const Icon(
                                Icons
                                    .phone_outlined,
                              ),
                              border:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  14,
                                ),
                              ),
                            ),
                            validator:
                                (value) {
                              if (value ==
                                      null ||
                                  value
                                      .trim()
                                      .isEmpty) {
                                return "Enter phone number";
                              }

                              if (value
                                      .trim()
                                      .length !=
                                  10) {
                                return "Enter 10 digit phone number";
                              }

                              return null;
                            },
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          //////////////////////////////////////////////////
                          /// PASSWORD
                          //////////////////////////////////////////////////

                          TextFormField(
                            controller:
                                passwordController,
                            obscureText: true,
                            decoration:
                                InputDecoration(
                              labelText:
                                  "Temporary Password",
                              prefixIcon:
                                  const Icon(
                                Icons
                                    .lock_outline,
                              ),
                              border:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  14,
                                ),
                              ),
                            ),
                            validator:
                                (value) {
                              if (value ==
                                      null ||
                                  value.length <
                                      6) {
                                return "Minimum 6 characters";
                              }

                              return null;
                            },
                          ),

                          const SizedBox(
                            height: 18,
                          ),

                          //////////////////////////////////////////////////
                          /// ROLE
                          //////////////////////////////////////////////////

                          DropdownButtonFormField<
                              AdminRole>(
                            value:
                                selectedRole,
                            decoration:
                                InputDecoration(
                              labelText:
                                  "Admin Role",
                              prefixIcon:
                                  const Icon(
                                Icons
                                    .badge_outlined,
                              ),
                              border:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  14,
                                ),
                              ),
                            ),
                            items: AdminRole
                                .values
                                .where(
                                  (role) =>
                                      role !=
                                      AdminRole
                                          .superAdmin,
                                )
                                .map(
                                  (role) {
                                    return DropdownMenuItem<
                                        AdminRole>(
                                      value:
                                          role,
                                      child:
                                          Text(
                                        _roleLabel(
                                          role,
                                        ),
                                      ),
                                    );
                                  },
                                )
                                .toList(),
                            onChanged:
                                (role) {
                              if (role ==
                                  null) {
                                return;
                              }

                              setDialogState(
                                () {
                                  selectedRole =
                                      role;
                                },
                              );
                            },
                          ),

                          const SizedBox(
                            height: 24,
                          ),

                          //////////////////////////////////////////////////
                          /// PERMISSIONS TITLE
                          //////////////////////////////////////////////////

                          const Align(
                            alignment:
                                Alignment
                                    .centerLeft,
                            child: Text(
                              "Permissions",
                              style:
                                  TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          //////////////////////////////////////////////////
                          /// PERMISSIONS
                          //////////////////////////////////////////////////

                          ...permissions.entries
                              .map(
                            (
                              entry,
                            ) {
                              return SwitchListTile(
                                dense: true,
                                contentPadding:
                                    EdgeInsets
                                        .zero,
                                activeColor:
                                    const Color(
                                  0xffD81B78,
                                ),
                                title: Text(
                                  _permissionLabel(
                                    entry.key,
                                  ),
                                  style:
                                      const TextStyle(
                                    fontSize:
                                        13,
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                  ),
                                ),
                                value:
                                    entry.value,
                                onChanged:
                                    (value) {
                                  setDialogState(
                                    () {
                                      permissions[
                                              entry
                                                  .key] =
                                          value;
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ],
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
                    child: const Text(
                      "Cancel",
                    ),
                  ),

                  FilledButton(
  style: FilledButton.styleFrom(
    backgroundColor:
        const Color(0xffD81B78),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 14,
    ),
    shape: RoundedRectangleBorder(
      borderRadius:
          BorderRadius.circular(12),
    ),
  ),

  onPressed: () async {
    //-------------------------------------------------------
    // VALIDATE
    //-------------------------------------------------------

    if (!formKey.currentState!
        .validate()) {
      return;
    }

    //-------------------------------------------------------
    // CLOSE KEYBOARD
    //-------------------------------------------------------

    FocusScope.of(context).unfocus();

    //-------------------------------------------------------
    // SHOW LOADING
    //-------------------------------------------------------

    showDialog(
      context: dialogContext,
      barrierDismissible: false,
      builder: (_) {
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xffD81B78),
          ),
        );
      },
    );

    try {
      //-----------------------------------------------------
      // CREATE ADMIN
      //-----------------------------------------------------

      final result =
          await _createAdmin(
        fullName:
            nameController.text,
        email:
            emailController.text,
        phone:
            phoneController.text,
        password:
            passwordController.text,
        role:
            selectedRole,
        permissions:
            permissions,
      );

      //-----------------------------------------------------
      // CLOSE LOADING
      //-----------------------------------------------------

      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }

      //-----------------------------------------------------
      // CLOSE ADD ADMIN DIALOG
      //-----------------------------------------------------

      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }

      //-----------------------------------------------------
      // REFRESH ADMIN LIST
      //-----------------------------------------------------

      await _loadAdmins();

      //-----------------------------------------------------
      // SUCCESS
      //-----------------------------------------------------

      if (!mounted) return;

ScaffoldMessenger.of(parentContext)
    .showSnackBar(
  SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.green.shade600,
    content: Text(
      result["message"] ??
          "Admin created successfully.",
    ),
  ),
);
    } on Exception catch (e) {
      //-----------------------------------------------------
      // CLOSE LOADING
      //-----------------------------------------------------

      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }

      //-----------------------------------------------------
      // SHOW ERROR
      //-----------------------------------------------------

      if (!mounted) return;

      final message = e
          .toString()
          .replaceFirst(
            "Exception: ",
            "",
          );

      ScaffoldMessenger.of(parentContext)
    .showSnackBar(
        SnackBar(
          behavior:
              SnackBarBehavior.floating,
          backgroundColor:
              Colors.red.shade600,
          content: Text(message),
        ),
      );
    }
  },

  child: const Text(
    "Create Admin",
    style: TextStyle(
      fontWeight: FontWeight.w700,
    ),
  ),
),
                ],
              );
            },
          );
        },
      );
    } finally {
      nameController.dispose();
      emailController.dispose();
      phoneController.dispose();
      passwordController.dispose();
    }
  }

  ///////////////////////////////////////////////////////////
  /// PERMISSION LABEL
  ///////////////////////////////////////////////////////////

  String _permissionLabel(
    String permission,
  ) {
    const labels = {
      "canAssignOrders":
          "Assign Orders",
      "canCancelOrders":
          "Cancel Orders",
      "canChat":
          "Chat",
      "canCreateAdmins":
          "Create Admins",
      "canCreateProducts":
          "Create Products",
      "canDeleteAdmins":
          "Delete Admins",
      "canDeleteMessages":
          "Delete Messages",
      "canDeleteProducts":
          "Delete Products",
      "canEditAdmins":
          "Edit Admins",
      "canEditOrders":
          "Edit Orders",
      "canEditProducts":
          "Edit Products",
      "canGenerateLabels":
          "Generate Labels",
      "canManageAdmins":
          "Manage Admins",
      "canManageInventory":
          "Manage Inventory",
      "canManageSettings":
          "Manage Settings",
      "canMarkDamaged":
          "Mark Damaged",
      "canMarkMissing":
          "Mark Missing",
      "canPackOrders":
          "Pack Orders",
      "canRefundPayments":
          "Refund Payments",
      "canRequestPayment":
          "Request Payment",
      "canShipOrders":
          "Ship Orders",
      "canVerifyPayments":
          "Verify Payments",
      "canViewAuditLogs":
          "View Audit Logs",
      "canViewOrders":
          "View Orders",
      "canViewProducts":
          "View Products",
      "canViewReports":
          "View Reports",
    };

    return labels[permission] ??
        permission;
  }

  ///////////////////////////////////////////////////////////
  /// BUILD
  ///////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffFFF8FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor:
            Colors.transparent,

        title: const Text(
          "Staff",
          style: TextStyle(
            color: Color(0xff241B2F),
            fontWeight: FontWeight.w800,
          ),
        ),

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xffD81B78),
          ),
        ),

        actions: [
          if (_adminService
              .canCreateAdmins)
            Padding(
              padding:
                  const EdgeInsets.only(
                right: 10,
              ),
              child: TextButton.icon(
                onPressed:
                    _showAddAdminDialog,
                icon: const Icon(
                  Icons.add_rounded,
                  color:
                      Color(0xffD81B78),
                ),
                label: const Text(
                  "Add Admin",
                  style: TextStyle(
                    color:
                        Color(0xffD81B78),
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),

      body: RefreshIndicator(
        color:
            const Color(0xffD81B78),
        onRefresh: _loadAdmins,
        child: _loading
            ? const Center(
                child:
                    CircularProgressIndicator(
                  color: Color(
                    0xffD81B78,
                  ),
                ),
              )
            : _error != null
                ? Center(
                    child: Padding(
                      padding:
                          const EdgeInsets
                              .all(24),
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons
                                .error_outline_rounded,
                            size: 50,
                            color:
                                Colors.red,
                          ),

                          const SizedBox(
                            height: 12,
                          ),

                          const Text(
                            "Unable to load staff",
                            style:
                                TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Text(
                            _error!,
                            textAlign:
                                TextAlign
                                    .center,
                            style: TextStyle(
                              color: Colors
                                  .grey
                                  .shade600,
                            ),
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          ElevatedButton(
                            onPressed:
                                _loadAdmins,
                            child:
                                const Text(
                              "Retry",
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _admins.isEmpty
                    ? ListView(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(
                            height: 180,
                          ),
                          Center(
                            child: Text(
                              "No admins found",
                              style:
                                  TextStyle(
                                fontSize:
                                    17,
                                fontWeight:
                                    FontWeight
                                        .w700,
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics:
                            const AlwaysScrollableScrollPhysics(
                          parent:
                              BouncingScrollPhysics(),
                        ),
                        padding:
                            const EdgeInsets
                                .fromLTRB(
                          18,
                          18,
                          18,
                          30,
                        ),
                        itemCount:
                            _admins.length,
                        itemBuilder:
                            (
                          context,
                          index,
                        ) {
                          return _buildAdminCard(
                            _admins[index],
                          );
                        },
                      ),
      ),
    );
  }
}