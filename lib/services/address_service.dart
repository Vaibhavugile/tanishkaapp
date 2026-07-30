import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/address_model.dart';

class AddressService {
  AddressService._();

  static final AddressService instance =
      AddressService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  User get _user {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in.");
    }

    return user;
  }

  CollectionReference<Map<String, dynamic>>
      get _addressCollection {
    return _firestore
        .collection("appUsers")
        .doc(_user.uid)
        .collection("addresses");
  }

  /// ===============================
  /// Add Address
  /// ===============================

  Future<void> addAddress(
    AddressModel address,
  ) async {
    final doc = _addressCollection.doc();

    await doc.set({
      ...address.toMap(),
      "createdAt": Timestamp.now(),
    });

    if (address.isDefault) {
      await setDefaultAddress(doc.id);
    }
  }

  /// ===============================
  /// Update Address
  /// ===============================

  Future<void> updateAddress(
    AddressModel address,
  ) async {
    await _addressCollection
        .doc(address.id)
        .update(address.toMap());

    if (address.isDefault) {
      await setDefaultAddress(address.id);
    }
  }

  /// ===============================
  /// Delete Address
  /// ===============================

  Future<void> deleteAddress(
    String id,
  ) async {
    await _addressCollection.doc(id).delete();
  }

  /// ===============================
  /// Set Default Address
  /// ===============================

  Future<void> setDefaultAddress(
    String id,
  ) async {
    final snapshot =
        await _addressCollection.get();

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.update(
        doc.reference,
        {
          "isDefault": doc.id == id,
        },
      );
    }

    await batch.commit();
  }

  /// ===============================
  /// Stream Addresses
  /// ===============================

  Stream<List<AddressModel>>
      addressStream() {
    return _addressCollection
        .orderBy(
          "createdAt",
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => AddressModel.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  /// ===============================
  /// Default Address
  /// ===============================

  Future<AddressModel?> getDefaultAddress()
      async {
    final snapshot =
        await _addressCollection
            .where(
              "isDefault",
              isEqualTo: true,
            )
            .limit(1)
            .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return AddressModel.fromMap(
      snapshot.docs.first.id,
      snapshot.docs.first.data(),
    );
  }
}