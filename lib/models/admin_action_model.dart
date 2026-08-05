import 'package:cloud_firestore/cloud_firestore.dart';

class AdminActionModel {
  /// Document ID
  final String id;

  /// Action
  final String action;

  /// Entity
  final String entityType;

  final String entityId;

  /// Order
  final String orderId;

  /// Customer
  final String customerId;

  /// Admin Snapshot
  final String adminId;

  final String adminName;

  final String adminEmail;

  final String adminRole;

  final String adminPhoto;

  /// Description
  final String title;

  final String description;

  /// Before & After
  final Map<String, dynamic>? before;

  final Map<String, dynamic>? after;

  /// Extra Metadata
  final Map<String, dynamic>? metadata;

  /// Device
  final String device;

  final String appVersion;

  /// Timestamp
  final Timestamp createdAt;

  const AdminActionModel({
    required this.id,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.orderId,
    required this.customerId,
    required this.adminId,
    required this.adminName,
    required this.adminEmail,
    required this.adminRole,
    required this.adminPhoto,
    required this.title,
    required this.description,
    required this.before,
    required this.after,
    required this.metadata,
    required this.device,
    required this.appVersion,
    required this.createdAt,
  });

  factory AdminActionModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return AdminActionModel(
      id: id,

      action: map["action"] ?? "",

      entityType: map["entityType"] ?? "",

      entityId: map["entityId"] ?? "",

      orderId: map["orderId"] ?? "",

      customerId: map["customerId"] ?? "",

      adminId: map["adminId"] ?? "",

      adminName: map["adminName"] ?? "",

      adminEmail: map["adminEmail"] ?? "",

      adminRole: map["adminRole"] ?? "",

      adminPhoto: map["adminPhoto"] ?? "",

      title: map["title"] ?? "",

      description: map["description"] ?? "",

      before: map["before"] != null
          ? Map<String, dynamic>.from(map["before"])
          : null,

      after: map["after"] != null
          ? Map<String, dynamic>.from(map["after"])
          : null,

      metadata: map["metadata"] != null
          ? Map<String, dynamic>.from(map["metadata"])
          : null,

      device: map["device"] ?? "",

      appVersion: map["appVersion"] ?? "",

      createdAt:
          map["createdAt"] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "action": action,

      "entityType": entityType,

      "entityId": entityId,

      "orderId": orderId,

      "customerId": customerId,

      "adminId": adminId,

      "adminName": adminName,

      "adminEmail": adminEmail,

      "adminRole": adminRole,

      "adminPhoto": adminPhoto,

      "title": title,

      "description": description,

      "before": before,

      "after": after,

      "metadata": metadata,

      "device": device,

      "appVersion": appVersion,

      "createdAt": createdAt,
    };
  }
}