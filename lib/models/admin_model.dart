import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_permissions.dart';
import 'admin_role.dart';

class AdminModel {
  /// Identity
  final String uid;

  final String fullName;

  final String email;

  final String phone;

  final String photo;

  /// Role
  final AdminRole role;

  /// Permissions
  final AdminPermissions permissions;

  /// Status
  final bool active;

  /// Device Info
  final String device;

  final String appVersion;

  /// Activity
  final Timestamp? lastLoginAt;

  final Timestamp? lastSeenAt;

  /// Audit
  final String createdBy;

  final String updatedBy;

  final Timestamp createdAt;

  final Timestamp updatedAt;

  const AdminModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.photo,
    required this.role,
    required this.permissions,
    required this.active,
    required this.device,
    required this.appVersion,
    required this.lastLoginAt,
    required this.lastSeenAt,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminModel.fromMap(
    String uid,
    Map<String, dynamic> map,
  ) {
    return AdminModel(
      uid: uid,

      fullName: map["fullName"] ?? "",

      email: map["email"] ?? "",

      phone: map["phone"] ?? "",

      photo: map["photo"] ?? "",

      role: AdminRoleExtension.fromString(
        map["role"] ?? "support",
      ),

      permissions: AdminPermissions.fromMap(
        map["permissions"],
      ),

      active: map["active"] ?? true,

      device: map["device"] ?? "",

      appVersion: map["appVersion"] ?? "",

      lastLoginAt: map["lastLoginAt"],

      lastSeenAt: map["lastSeenAt"],

      createdBy: map["createdBy"] ?? "",

      updatedBy: map["updatedBy"] ?? "",

      createdAt:
          map["createdAt"] ?? Timestamp.now(),

      updatedAt:
          map["updatedAt"] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "fullName": fullName,

      "email": email,

      "phone": phone,

      "photo": photo,

      "role": role.value,

      "permissions": permissions.toMap(),

      "active": active,

      "device": device,

      "appVersion": appVersion,

      "lastLoginAt": lastLoginAt,

      "lastSeenAt": lastSeenAt,

      "createdBy": createdBy,

      "updatedBy": updatedBy,

      "createdAt": createdAt,

      "updatedAt": updatedAt,
    };
  }

  AdminModel copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? photo,
    AdminRole? role,
    AdminPermissions? permissions,
    bool? active,
    String? device,
    String? appVersion,
    Timestamp? lastLoginAt,
    Timestamp? lastSeenAt,
    String? updatedBy,
    Timestamp? updatedAt,
  }) {
    return AdminModel(
      uid: uid,

      fullName: fullName ?? this.fullName,

      email: email ?? this.email,

      phone: phone ?? this.phone,

      photo: photo ?? this.photo,

      role: role ?? this.role,

      permissions:
          permissions ?? this.permissions,

      active: active ?? this.active,

      device: device ?? this.device,

      appVersion:
          appVersion ?? this.appVersion,

      lastLoginAt:
          lastLoginAt ?? this.lastLoginAt,

      lastSeenAt:
          lastSeenAt ?? this.lastSeenAt,

      createdBy: createdBy,

      updatedBy:
          updatedBy ?? this.updatedBy,

      createdAt: createdAt,

      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  bool get isSuperAdmin =>
      role == AdminRole.superAdmin;

  bool get isOwner =>
      role == AdminRole.owner;

  bool get isManager =>
      role == AdminRole.manager;

  bool get isSales =>
      role == AdminRole.sales;

  bool get isPacking =>
      role == AdminRole.packing;

  bool get isAccounts =>
      role == AdminRole.accounts;

  bool get isSupport =>
      role == AdminRole.support;
}