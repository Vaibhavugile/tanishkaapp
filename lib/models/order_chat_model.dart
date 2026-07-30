import 'package:cloud_firestore/cloud_firestore.dart';

class OrderChatModel {
  final String id;

  final String orderId;

  final String customerId;

  final String customerName;

  final String customerPhone;

  final String customerPhoto;

  final String orderSource;

  final String orderStatus;

  final String paymentStatus;

  final String lastMessage;

  final String lastMessageType;

  final int unreadCustomer;

  final int unreadAdmin;

  final Timestamp? lastMessageTime;

  final Timestamp? createdAt;

  final Timestamp? updatedAt;

  const OrderChatModel({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerPhoto,
    required this.orderSource,
    required this.orderStatus,
    required this.paymentStatus,
    required this.lastMessage,
    required this.lastMessageType,
    required this.unreadCustomer,
    required this.unreadAdmin,
    required this.lastMessageTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderChatModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return OrderChatModel(
      id: doc.id,

      orderId: data["orderId"] ?? "",

      customerId: data["customerId"] ?? "",

      customerName: data["customerName"] ?? "",

      customerPhone: data["customerPhone"] ?? "",

      customerPhoto: data["customerPhoto"] ?? "",

      orderSource: data["orderSource"] ?? "",

      orderStatus: data["orderStatus"] ?? "Placed",

      paymentStatus:
          data["paymentStatus"] ?? "Pending",

      lastMessage:
          data["lastMessage"] ?? "",

      lastMessageType:
          data["lastMessageType"] ?? "text",

      unreadCustomer:
          data["unreadCustomer"] ?? 0,

      unreadAdmin:
          data["unreadAdmin"] ?? 0,

      lastMessageTime:
          data["lastMessageTime"],

      createdAt:
          data["createdAt"],

      updatedAt:
          data["updatedAt"],
    );
  }
}