import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../features/navigation/screens/main_navigation_screen.dart';
import '../features/home/home_screen.dart';
import '../features/auth/screens/verification_screen.dart';
import '../features/admin/screens/admin_dashboard_screen.dart';
// TODO
// import '../features/admin/screens/admin_dashboard_screen.dart';

import 'admin_service.dart';

class LoginRouterService {
  LoginRouterService._();

  static final LoginRouterService instance =
      LoginRouterService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> routeUser({
    required BuildContext context,
    required User firebaseUser,
  }) async {
    //----------------------------------------------------------
    // CHECK ADMINS
    //----------------------------------------------------------

    final adminDoc = await _firestore
        .collection("admins")
        .doc(firebaseUser.uid)
        .get();

    if (adminDoc.exists) {
      await AdminService.instance.loadCurrentAdmin();

      final admin =
          AdminService.instance.currentAdmin;

      if (admin == null) {
        await FirebaseAuth.instance.signOut();

        if (!context.mounted) return;

        _showError(
          context,
          "Unable to load admin account.",
        );

        return;
      }

      //----------------------------------------------------------
      // Disabled
      //----------------------------------------------------------

      if (!admin.active) {
        await FirebaseAuth.instance.signOut();

        if (!context.mounted) return;

        _showError(
          context,
          "Your admin account has been disabled.",
        );

        return;
      }

      //----------------------------------------------------------
      // Update Login
      //----------------------------------------------------------

      await AdminService.instance.updateLastLogin();

      await AdminService.instance.updateLastSeen();

      if (!context.mounted) return;

      //----------------------------------------------------------
      // TODO
      //----------------------------------------------------------

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const AdminDashboardScreen(),
        ),
        (route) => false,
      );

      return;
    }

    //----------------------------------------------------------
    // CHECK CUSTOMER
    //----------------------------------------------------------

    final customerDoc = await _firestore
        .collection("appUsers")
        .doc(firebaseUser.uid)
        .get();

    if (!customerDoc.exists) {
      await FirebaseAuth.instance.signOut();

      if (!context.mounted) return;

      _showError(
        context,
        "Account not found.",
      );

      return;
    }

    final data = customerDoc.data()!;

    final verificationStatus =
        (data["verificationStatus"] ?? "pending")
            .toString();

    if (!context.mounted) return;

    switch (verificationStatus) {
      case "approved":
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const MainNavigationScreen(),
          ),
          (route) => false,
        );
        break;

      default:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const VerificationScreen(),
          ),
          (route) => false,
        );
        break;
    }
  }

  void _showError(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        content: Text(message),
      ),
    );
  }
}