import 'package:cloud_firestore/cloud_firestore.dart';

class TimelineEventModel {
  final String id;

  /// Action
  final String action;

  /// Heading
  final String title;

  /// Description
  final String description;

  /// Order
  final String orderId;

  /// Customer
  final String customerId;

  /// Entity
  final String entityType;

  final String entityId;

  /// Admin Snapshot
  final String adminId;

  final String adminName;

  final String adminEmail;

  final String adminRole;

  final String adminPhoto;

  /// Metadata
  final Map<String, dynamic>? metadata;

  /// Timestamp
  final Timestamp createdAt;

  const TimelineEventModel({
    required this.id,
    required this.action,
    required this.title,
    required this.description,
    required this.orderId,
    required this.customerId,
    required this.entityType,
    required this.entityId,
    required this.adminId,
    required this.adminName,
    required this.adminEmail,
    required this.adminRole,
    required this.adminPhoto,
    required this.metadata,
    required this.createdAt,
  });

  factory TimelineEventModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return TimelineEventModel(
      id: id,

      action: map["action"] ?? "",

      title: map["title"] ?? "",

      description: map["description"] ?? "",

      orderId: map["orderId"] ?? "",

      customerId: map["customerId"] ?? "",

      entityType: map["entityType"] ?? "",

      entityId: map["entityId"] ?? "",

      adminId: map["adminId"] ?? "",

      adminName: map["adminName"] ?? "",

      adminEmail: map["adminEmail"] ?? "",

      adminRole: map["adminRole"] ?? "",

      adminPhoto: map["adminPhoto"] ?? "",

      metadata: map["metadata"] != null
          ? Map<String, dynamic>.from(map["metadata"])
          : null,

      createdAt:
          map["createdAt"] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "action": action,

      "title": title,

      "description": description,

      "orderId": orderId,

      "customerId": customerId,

      "entityType": entityType,

      "entityId": entityId,

      "adminId": adminId,

      "adminName": adminName,

      "adminEmail": adminEmail,

      "adminRole": adminRole,

      "adminPhoto": adminPhoto,

      "metadata": metadata,

      "createdAt": createdAt,
    };
  }
}