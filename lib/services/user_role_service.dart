import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRoleService {
  UserRoleService._();

  static final UserRoleService instance = UserRoleService._();

  String _role = "retail";

  String get role => _role;

  Future<void> loadUserRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      _role = "retail";
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection("appUsers")
        .doc(uid)
        .get();

    if (!doc.exists) {
      _role = "retail";
      return;
    }

    _role = (doc.data()?["role"] ?? "retail").toString().toLowerCase();
  }
}