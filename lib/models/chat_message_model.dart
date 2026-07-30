import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String id;

  final String senderId;

  /// customer
  /// admin
  /// system
  final String senderType;

  /// text
  /// image
  /// order
  /// payment
  /// tracking
  /// invoice
  /// status
  final String type;

  final String text;

  final String image;

  final String pdf;

  final String orderId;

  final Map<String, dynamic>? orderSummary;

  final Timestamp? createdAt;

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderType,
    required this.type,
    required this.text,
    required this.image,
    required this.pdf,
    required this.orderId,
    required this.orderSummary,
    required this.createdAt,
  });

  factory ChatMessageModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return ChatMessageModel(
      id: doc.id,
      senderId: data["senderId"] ?? "",
      senderType: data["senderType"] ?? "",
      type: data["type"] ?? "text",
      text: data["text"] ?? "",
      image: data["image"] ?? "",
      pdf: data["pdf"] ?? "",
      orderId: data["orderId"] ?? "",
      orderSummary:
          data["orderSummary"] != null
              ? Map<String, dynamic>.from(
                  data["orderSummary"],
                )
              : null,
      createdAt: data["createdAt"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "senderId": senderId,
      "senderType": senderType,
      "type": type,
      "text": text,
      "image": image,
      "pdf": pdf,
      "orderId": orderId,
      "orderSummary": orderSummary,
      "createdAt": createdAt,
    };
  }

  bool get isCustomer => senderType == "customer";

  bool get isAdmin => senderType == "admin";

  bool get isSystem => senderType == "system";

  bool get isText => type == "text";

  bool get isImage => type == "image";

  bool get isOrder => type == "order";

  bool get isPayment => type == "payment";

  bool get isTracking => type == "tracking";

  bool get isInvoice => type == "invoice";

  bool get isStatus => type == "status";
}