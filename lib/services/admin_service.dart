import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/admin_model.dart';
import '../models/admin_permissions.dart';

class AdminService {
  AdminService._();

  static final AdminService instance =
      AdminService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  AdminModel? _currentAdmin;

  AdminModel? get currentAdmin =>
      _currentAdmin;

  bool get isLoggedIn =>
      _auth.currentUser != null;

  bool get hasAdmin =>
      _currentAdmin != null;

  String get uid =>
      _auth.currentUser?.uid ?? "";

  /// =====================================================
  /// Load Current Admin
  /// =====================================================

  Future<AdminModel?> loadCurrentAdmin() async {
    final user = _auth.currentUser;

    if (user == null) {
      _currentAdmin = null;
      return null;
    }

    final doc = await _firestore
        .collection("admins")
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      _currentAdmin = null;
      return null;
    }

    _currentAdmin = AdminModel.fromMap(
      doc.id,
      doc.data()!,
    );

    return _currentAdmin;
  }

  /// =====================================================
  /// Refresh
  /// =====================================================

  Future<void> refresh() async {
    await loadCurrentAdmin();
  }

  /// =====================================================
  /// Update Last Seen
  /// =====================================================

  Future<void> updateLastSeen() async {
    if (_currentAdmin == null) return;

    await _firestore
        .collection("admins")
        .doc(_currentAdmin!.uid)
        .update({
      "lastSeenAt": Timestamp.now(),
    });
  }

  /// =====================================================
  /// Update Last Login
  /// =====================================================

  Future<void> updateLastLogin() async {
    if (_currentAdmin == null) return;

    await _firestore
        .collection("admins")
        .doc(_currentAdmin!.uid)
        .update({
      "lastLoginAt": Timestamp.now(),
    });
  }
  /// =====================================================
/// Get All Admins
/// =====================================================

Future<List<AdminModel>> getAdmins() async {
  try {
    final snapshot = await _firestore
        .collection("admins")
        .orderBy(
          "createdAt",
          descending: true,
        )
        .get();

    return snapshot.docs
        .map(
          (doc) => AdminModel.fromMap(
            doc.id,
            doc.data(),
          ),
        )
        .toList();
  } catch (e) {
    rethrow;
  }
}

  /// =====================================================
  /// Active Check
  /// =====================================================

  bool get isActive =>
      _currentAdmin?.active ?? false;

  /// =====================================================
  /// Role Checks
  /// =====================================================

  bool get isSuperAdmin =>
      _currentAdmin?.isSuperAdmin ?? false;

  bool get isOwner =>
      _currentAdmin?.isOwner ?? false;

  bool get isManager =>
      _currentAdmin?.isManager ?? false;

  bool get isPacking =>
      _currentAdmin?.isPacking ?? false;

  bool get isAccounts =>
      _currentAdmin?.isAccounts ?? false;

  bool get isSales =>
      _currentAdmin?.isSales ?? false;

  bool get isSupport =>
      _currentAdmin?.isSupport ?? false;

  /// =====================================================
  /// Permissions
  /// =====================================================

  AdminPermissions get permissions =>
      _currentAdmin?.permissions ??
      const AdminPermissions();

  bool get canManageAdmins =>
      permissions.canManageAdmins;

  bool get canCreateAdmins =>
      permissions.canCreateAdmins;

  bool get canEditAdmins =>
      permissions.canEditAdmins;

  bool get canDeleteAdmins =>
      permissions.canDeleteAdmins;

  bool get canViewOrders =>
      permissions.canViewOrders;

  bool get canEditOrders =>
      permissions.canEditOrders;

  bool get canCancelOrders =>
      permissions.canCancelOrders;

  bool get canAssignOrders =>
      permissions.canAssignOrders;

  bool get canChat =>
      permissions.canChat;

  bool get canPackOrders =>
      permissions.canPackOrders;

  bool get canVerifyPayments =>
      permissions.canVerifyPayments;

  bool get canShipOrders =>
      permissions.canShipOrders;

  bool get canManageInventory =>
      permissions.canManageInventory;

  bool get canViewReports =>
      permissions.canViewReports;

  bool get canManageSettings =>
      permissions.canManageSettings;

  bool get canViewAuditLogs =>
      permissions.canViewAuditLogs;
}