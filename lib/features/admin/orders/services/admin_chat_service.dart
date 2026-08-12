import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:tanishka/models/chat_message_model.dart';

class AdminChatService {
  AdminChatService._();

  static final AdminChatService instance =
      AdminChatService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  ///////////////////////////////////////////////////////////
  /// ADMIN ID
  ///////////////////////////////////////////////////////////

  String get _adminId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("Admin not logged in.");
    }

    return user.uid;
  }

  ///////////////////////////////////////////////////////////
  /// MESSAGES STREAM
  ///////////////////////////////////////////////////////////

  Stream<List<ChatMessageModel>> messagesStream(
    String orderId,
  ) {
    return _firestore
        .collection("orderChats")
        .doc(orderId)
        .collection("messages")
        .orderBy(
          "createdAt",
          descending: false,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                ChatMessageModel.fromFirestore,
              )
              .toList(),
        );
  }

  ///////////////////////////////////////////////////////////
  /// SEND ADMIN TEXT MESSAGE
  ///////////////////////////////////////////////////////////

  Future<void> sendMessage({
    required String orderId,
    required String text,
  }) async {
    final value = text.trim();

    if (value.isEmpty) {
      return;
    }

    await _sendAdminMessage(
      orderId: orderId,
      type: "text",
      text: value,
    );
  }

  ///////////////////////////////////////////////////////////
  /// SEND PAYMENT MESSAGE
  ///////////////////////////////////////////////////////////

  Future<void> sendPaymentMessage({
    required String orderId,
    required String text,
    required Map<String, dynamic> paymentData,
  }) async {
    await _sendAdminMessage(
      orderId: orderId,
      type: "payment",
      text: text.trim(),
      paymentData: paymentData,
    );
  }

  ///////////////////////////////////////////////////////////
  /// SEND PACKING MESSAGE
  ///////////////////////////////////////////////////////////

  Future<void> sendPackingMessage({
    required String orderId,
    required String text,
    required Map<String, dynamic> packingData,
  }) async {
    await _sendAdminMessage(
      orderId: orderId,
      type: "packing",
      text: text.trim(),
      packingData: packingData,
    );
  }

  ///////////////////////////////////////////////////////////
  /// SEND SHIPMENT MESSAGE
  ///////////////////////////////////////////////////////////

  Future<void> sendShipmentMessage({
    required String orderId,
    required String text,
    required Map<String, dynamic> shipmentData,
  }) async {
    await _sendAdminMessage(
      orderId: orderId,
      type: "shipment",
      text: text.trim(),
      shipmentData: shipmentData,
    );
  }

  ///////////////////////////////////////////////////////////
  /// SEND TRACKING MESSAGE
  ///////////////////////////////////////////////////////////

  Future<void> sendTrackingMessage({
    required String orderId,
    required String text,
    required Map<String, dynamic> trackingData,
  }) async {
    await _sendAdminMessage(
      orderId: orderId,
      type: "tracking",
      text: text.trim(),
      trackingData: trackingData,
    );
  }

  ///////////////////////////////////////////////////////////
  /// SEND INVOICE MESSAGE
  ///////////////////////////////////////////////////////////

  Future<void> sendInvoiceMessage({
    required String orderId,
    required String text,
    required Map<String, dynamic> invoiceData,
  }) async {
    await _sendAdminMessage(
      orderId: orderId,
      type: "invoice",
      text: text.trim(),
      invoiceData: invoiceData,
    );
  }

  ///////////////////////////////////////////////////////////
  /// SEND STATUS MESSAGE
  ///////////////////////////////////////////////////////////

  Future<void> sendStatusMessage({
    required String orderId,
    required String text,
    required Map<String, dynamic> statusData,
  }) async {
    await _sendAdminMessage(
      orderId: orderId,
      type: "status",
      text: text.trim(),
      statusData: statusData,
    );
  }

  ///////////////////////////////////////////////////////////
  /// INTERNAL ADMIN MESSAGE SENDER
  ///
  /// One Firestore batch:
  ///
  /// 1. Create message
  /// 2. Update orderChats summary
  ///
  ///////////////////////////////////////////////////////////

  Future<void> _sendAdminMessage({
    required String orderId,
    required String type,
    required String text,

    String image = "",
    String pdf = "",

    Map<String, dynamic>? paymentData,
    Map<String, dynamic>? packingData,
    Map<String, dynamic>? shipmentData,
    Map<String, dynamic>? trackingData,
    Map<String, dynamic>? invoiceData,
    Map<String, dynamic>? statusData,
  }) async {
    final now =
        FieldValue.serverTimestamp();

    final chatRef = _firestore
        .collection("orderChats")
        .doc(orderId);

    final messageRef =
        chatRef
            .collection("messages")
            .doc();

    /////////////////////////////////////////////////////////
    /// MESSAGE DATA
    /////////////////////////////////////////////////////////

    final Map<String, dynamic> messageData = {
      "senderId": _adminId,

      "senderType": "admin",

      "type": type,

      "text": text,

      "image": image,

      "pdf": pdf,

      "orderId": orderId,

      "createdAt": now,
    };

    /////////////////////////////////////////////////////////
    /// SPECIAL DATA
    /////////////////////////////////////////////////////////

    if (paymentData != null) {
      messageData["paymentData"] =
          paymentData;
    }

    if (packingData != null) {
      messageData["packingData"] =
          packingData;
    }

    if (shipmentData != null) {
      messageData["shipmentData"] =
          shipmentData;
    }

    if (trackingData != null) {
      messageData["trackingData"] =
          trackingData;
    }

    if (invoiceData != null) {
      messageData["invoiceData"] =
          invoiceData;
    }

    if (statusData != null) {
      messageData["statusData"] =
          statusData;
    }

    /////////////////////////////////////////////////////////
    /// BATCH
    /////////////////////////////////////////////////////////

    final batch =
        _firestore.batch();

    /////////////////////////////////////////////////////////
    /// CREATE MESSAGE
    /////////////////////////////////////////////////////////

    batch.set(
      messageRef,
      messageData,
    );

    /////////////////////////////////////////////////////////
    /// UPDATE CHAT SUMMARY
    /////////////////////////////////////////////////////////

    batch.update(
      chatRef,
      {
        "lastMessage": text,

        "lastMessageType": type,

        "lastSenderType": "admin",

        "lastSenderId": _adminId,

        "lastMessageTime": now,

        "updatedAt": now,

        "unreadCustomer":
            FieldValue.increment(1),

        "unreadAdmin": 0,
      },
    );

    /////////////////////////////////////////////////////////
    /// COMMIT
    /////////////////////////////////////////////////////////

    await batch.commit();
  }

  ///////////////////////////////////////////////////////////
  /// SEND SYSTEM MESSAGE
  ///////////////////////////////////////////////////////////

  Future<void> sendSystemMessage({
    required String orderId,
    required String message,
    required String type,

    Map<String, dynamic>? orderSummary,
    Map<String, dynamic>? paymentData,
    Map<String, dynamic>? packingData,
    Map<String, dynamic>? shipmentData,
    Map<String, dynamic>? trackingData,
    Map<String, dynamic>? invoiceData,
    Map<String, dynamic>? statusData,
  }) async {
    final text =
        message.trim();

    if (text.isEmpty) {
      return;
    }

    final now =
        FieldValue.serverTimestamp();

    final chatRef =
        _firestore
            .collection("orderChats")
            .doc(orderId);

    final messageRef =
        chatRef
            .collection("messages")
            .doc();

    /////////////////////////////////////////////////////////
    /// MESSAGE DATA
    /////////////////////////////////////////////////////////

    final Map<String, dynamic> messageData = {
      "senderId": "system",

      "senderType": "system",

      "type": type,

      "text": text,

      "image": "",

      "pdf": "",

      "orderId": orderId,

      "createdAt": now,
    };

    /////////////////////////////////////////////////////////
    /// SPECIAL DATA
    /////////////////////////////////////////////////////////

    if (orderSummary != null) {
      messageData["orderSummary"] =
          orderSummary;
    }

    if (paymentData != null) {
      messageData["paymentData"] =
          paymentData;
    }

    if (packingData != null) {
      messageData["packingData"] =
          packingData;
    }

    if (shipmentData != null) {
      messageData["shipmentData"] =
          shipmentData;
    }

    if (trackingData != null) {
      messageData["trackingData"] =
          trackingData;
    }

    if (invoiceData != null) {
      messageData["invoiceData"] =
          invoiceData;
    }

    if (statusData != null) {
      messageData["statusData"] =
          statusData;
    }

    /////////////////////////////////////////////////////////
    /// BATCH
    /////////////////////////////////////////////////////////

    final batch =
        _firestore.batch();

    /////////////////////////////////////////////////////////
    /// CREATE MESSAGE
    /////////////////////////////////////////////////////////

    batch.set(
      messageRef,
      messageData,
    );

    /////////////////////////////////////////////////////////
    /// UPDATE CHAT SUMMARY
    /////////////////////////////////////////////////////////

    batch.update(
      chatRef,
      {
        "lastMessage": text,

        "lastMessageType": type,

        "lastSenderType": "system",

        "lastSenderId": "system",

        "lastMessageTime": now,

        "updatedAt": now,
      },
    );

    /////////////////////////////////////////////////////////
    /// COMMIT
    /////////////////////////////////////////////////////////

    await batch.commit();
  }

  ///////////////////////////////////////////////////////////
  /// MARK ADMIN CHAT AS READ
  ///////////////////////////////////////////////////////////

  Future<void> markAsRead(
    String orderId,
  ) async {
    await _firestore
        .collection("orderChats")
        .doc(orderId)
        .update({
      "unreadAdmin": 0,
    });
  }
  ///////////////////////////////////////////////////////////
/// MARK PAYMENT SUCCESSFUL
///////////////////////////////////////////////////////////

Future<void> markPaymentSuccessful({
  required String orderId,
  required double amount,
  required String paymentMethodId,
  required String paymentMethodName,
}) async {
  final adminId = _adminId;

  final now =
      FieldValue.serverTimestamp();

  final orderRef = _firestore
      .collection("orders")
      .doc(orderId);

  final chatRef = _firestore
      .collection("orderChats")
      .doc(orderId);

  final messageRef = chatRef
      .collection("messages")
      .doc();

  final batch = _firestore.batch();

  /////////////////////////////////////////////////////////
  /// 1. UPDATE ORDER PAYMENT STATUS
  /////////////////////////////////////////////////////////

  batch.update(
    orderRef,
    {
      "paymentStatus": "Paid",
      "paymentVerifiedBy": adminId,
      "paymentVerifiedAt": now,
    },
  );

  /////////////////////////////////////////////////////////
  /// 2. CREATE PAYMENT CHAT MESSAGE
  /////////////////////////////////////////////////////////

  batch.set(
    messageRef,
    {
      "senderId": adminId,

      "senderType": "admin",

      "type": "payment",

      "text":
          "Payment verified successfully",

      "image": "",

      "pdf": "",

      "orderId": orderId,

      "paymentData": {
        "status": "Paid",

        "amount": amount,

        "paymentMethodId":
            paymentMethodId,

        "paymentMethodName":
            paymentMethodName,

        "verifiedBy": adminId,

        "verifiedAt": now,
      },

      "createdAt": now,
    },
  );

  /////////////////////////////////////////////////////////
  /// 3. UPDATE ORDER CHAT SUMMARY
  /////////////////////////////////////////////////////////

  batch.update(
    chatRef,
    {
      "lastMessage":
          "Payment verified successfully",

      "lastMessageType":
          "payment",

      "lastSenderType":
          "admin",

      "lastSenderId":
          adminId,

      "lastMessageTime":
          now,

      "updatedAt":
          now,

      "unreadCustomer":
          FieldValue.increment(1),

      "unreadAdmin": 0,
    },
  );

  /////////////////////////////////////////////////////////
  /// 4. COMMIT EVERYTHING TOGETHER
  /////////////////////////////////////////////////////////

  await batch.commit();
}
/////////////////////////////////////////////////////////
/// SEND PAYMENT REQUEST
/////////////////////////////////////////////////////////

Future<void> sendPaymentRequest({
  required String orderId,
  required double amount,
  required String paymentMethodId,
  required String paymentMethodName,
  required String qrImage,
}) async {
  final now = FieldValue.serverTimestamp();

  final chatRef = _firestore
      .collection("orderChats")
      .doc(orderId);

  final messageRef = chatRef
      .collection("messages")
      .doc();

  final paymentData = {
    "amount": amount,
    "paymentMethodId": paymentMethodId,
    "paymentMethodName": paymentMethodName,
    "qrImage": qrImage,
    "status": "pending",
  };

  final batch = _firestore.batch();

  /////////////////////////////////////////////////////////
  /// PAYMENT MESSAGE
  /////////////////////////////////////////////////////////

  batch.set(messageRef, {
    "senderId": _adminId,
    "senderType": "admin",
    "type": "payment",

    "text": "Payment request",

    "image": "",
    "pdf": "",

    "orderId": orderId,

    "orderSummary": null,

    "paymentData": paymentData,

    "packingData": null,
    "shipmentData": null,
    "trackingData": null,
    "invoiceData": null,
    "statusData": null,

    "createdAt": now,
  });

  /////////////////////////////////////////////////////////
  /// CHAT SUMMARY
  /////////////////////////////////////////////////////////

  batch.update(chatRef, {
    "lastMessage": "Payment request",

    "lastMessageType": "payment",

    "lastSenderType": "admin",

    "lastSenderId": _adminId,

    "lastMessageTime": now,

    "updatedAt": now,

    "unreadCustomer":
        FieldValue.increment(1),

    "unreadAdmin": 0,
  });

  await batch.commit();
}
}