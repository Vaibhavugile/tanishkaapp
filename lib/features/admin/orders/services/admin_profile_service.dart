import 'package:cloud_firestore/cloud_firestore.dart';

class AdminProfileService {
  AdminProfileService._();

  static final AdminProfileService instance =
      AdminProfileService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  /// Cache admin profiles in memory.
  final Map<String, String> _nameCache = {};

  /// Get admin name by Firebase UID.
  Future<String> getAdminName(
    String adminId,
  ) async {
    if (adminId.isEmpty) {
      return "Admin";
    }

    // Return cached name if already loaded.
    if (_nameCache.containsKey(adminId)) {
      return _nameCache[adminId]!;
    }

    final doc = await _firestore
        .collection("admins")
        .doc(adminId)
        .get();

    if (!doc.exists) {
      _nameCache[adminId] = "Admin";
      return "Admin";
    }

    final data = doc.data();

    final name =
        (data?["fullName"] ?? "").toString().trim();

    final finalName =
        name.isNotEmpty ? name : "Admin";

    _nameCache[adminId] = finalName;

    return finalName;
  }

  /// Clear cached admin profiles if needed.
  void clearCache() {
    _nameCache.clear();
  }
}