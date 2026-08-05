import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/admin_action_model.dart';
import '../models/admin_model.dart';
import '../models/timeline_event_model.dart';
class AuditService {
  AuditService._();

  static final AuditService instance = AuditService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  /// ============================================================
  /// Log Action
  /// ============================================================
  Future<void> logAction({
    required AdminModel admin,

    required String action,

    required String entityType,

    required String entityId,

    required String orderId,

    required String customerId,

    required String title,

    required String description,

    Map<String, dynamic>? before,

    Map<String, dynamic>? after,

    Map<String, dynamic>? metadata,
  }) async {
    final batch = _firestore.batch();

    final actionRef =
        _firestore.collection("adminActions").doc();

    final orderActionRef = _firestore
        .collection("orders")
        .doc(orderId)
        .collection("actions")
        .doc(actionRef.id);

    final timelineRef = _firestore
        .collection("orders")
        .doc(orderId)
        .collection("timeline")
        .doc(actionRef.id);

    final actionModel = AdminActionModel(
      id: actionRef.id,

      action: action,

      entityType: entityType,

      entityId: entityId,

      orderId: orderId,

      customerId: customerId,

      adminId: admin.uid,

      adminName: admin.fullName,

      adminEmail: admin.email,

      adminRole: admin.role.value,

      adminPhoto: admin.photo,

      title: title,

      description: description,

      before: before,

      after: after,

      metadata: metadata,

      device: admin.device,

      appVersion: admin.appVersion,

      createdAt: Timestamp.now(),
    );

    //----------------------------------------------------------
    // Global Audit
    //----------------------------------------------------------

    batch.set(
      actionRef,
      actionModel.toMap(),
    );

    //----------------------------------------------------------
    // Order Audit
    //----------------------------------------------------------

    batch.set(
      orderActionRef,
      actionModel.toMap(),
    );

    //----------------------------------------------------------
    // Timeline
    //----------------------------------------------------------

    final timeline = TimelineEventModel(
  id: timelineRef.id,

  action: action,

  title: title,

  description: description,

  orderId: orderId,

  customerId: customerId,

  entityType: entityType,

  entityId: entityId,

  adminId: admin.uid,

  adminName: admin.fullName,

  adminEmail: admin.email,

  adminRole: admin.role.value,

  adminPhoto: admin.photo,

  metadata: metadata,

  createdAt: Timestamp.now(),
);

batch.set(
  timelineRef,
  timeline.toMap(),
);
    //----------------------------------------------------------
    // Update Order
    //----------------------------------------------------------

    batch.update(
      _firestore.collection("orders").doc(orderId),
      {
        "updatedAt": Timestamp.now(),

        "updatedBy": {
          "uid": admin.uid,
          "name": admin.fullName,
          "role": admin.role.value,
        },

        "lastAction": action,

        "lastActionTitle": title,

        "lastActionTime": Timestamp.now(),
      },
    );

    await batch.commit();
  }

  /// ============================================================
  /// Timeline Stream
  /// ============================================================
  Stream<QuerySnapshot<Map<String, dynamic>>> timelineStream(
    String orderId,
  ) {
    return _firestore
        .collection("orders")
        .doc(orderId)
        .collection("timeline")
        .orderBy(
          "createdAt",
          descending: true,
        )
        .snapshots();
  }

  /// ============================================================
  /// Order Audit Stream
  /// ============================================================
  Stream<QuerySnapshot<Map<String, dynamic>>> orderAuditStream(
    String orderId,
  ) {
    return _firestore
        .collection("orders")
        .doc(orderId)
        .collection("actions")
        .orderBy(
          "createdAt",
          descending: true,
        )
        .snapshots();
  }

  /// ============================================================
  /// Global Audit Stream
  /// ============================================================
  Stream<QuerySnapshot<Map<String, dynamic>>> globalAuditStream() {
    return _firestore
        .collection("adminActions")
        .orderBy(
          "createdAt",
          descending: true,
        )
        .snapshots();
  }

  /// ============================================================
  /// Delete Audit
  /// (Only Super Admin should call this)
  /// ============================================================
  Future<void> deleteAudit({
    required String actionId,
    required String orderId,
  }) async {
    final batch = _firestore.batch();

    batch.delete(
      _firestore.collection("adminActions").doc(actionId),
    );

    batch.delete(
      _firestore
          .collection("orders")
          .doc(orderId)
          .collection("actions")
          .doc(actionId),
    );

    batch.delete(
      _firestore
          .collection("orders")
          .doc(orderId)
          .collection("timeline")
          .doc(actionId),
    );

    await batch.commit();
  }
}