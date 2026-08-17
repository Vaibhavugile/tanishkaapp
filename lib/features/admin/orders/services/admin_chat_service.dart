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

/////////////////////////////////////////////////////////
/// APPROVE PAYMENT
///
/// Admin can approve ONLY after customer
/// has uploaded payment proof.
/////////////////////////////////////////////////////////

Future<void> approvePayment({
  required String orderId,
  required String messageId,
}) async {
  final adminId = _adminId;

  /////////////////////////////////////////////////////////
  /// REFERENCES
  /////////////////////////////////////////////////////////

  final orderRef = _firestore
      .collection("orders")
      .doc(orderId);

  final chatRef = _firestore
      .collection("orderChats")
      .doc(orderId);

  final messageRef = chatRef
      .collection("messages")
      .doc(messageId);

  /////////////////////////////////////////////////////////
  /// GET PAYMENT MESSAGE
  /////////////////////////////////////////////////////////

  final messageSnapshot =
      await messageRef.get();

  if (!messageSnapshot.exists) {
    throw Exception(
      "Payment request not found.",
    );
  }

  final data =
      messageSnapshot.data();

  if (data == null) {
    throw Exception(
      "Payment request data not found.",
    );
  }

  /////////////////////////////////////////////////////////
  /// VERIFY MESSAGE TYPE
  /////////////////////////////////////////////////////////

  if (data["type"] != "payment") {
    throw Exception(
      "This is not a payment message.",
    );
  }

  /////////////////////////////////////////////////////////
  /// PAYMENT DATA
  /////////////////////////////////////////////////////////

  final rawPaymentData =
      data["paymentData"];

  final Map<String, dynamic>
      paymentData =
      rawPaymentData is Map
          ? Map<String, dynamic>.from(
              rawPaymentData,
            )
          : {};

  /////////////////////////////////////////////////////////
  /// CURRENT STATUS
  /////////////////////////////////////////////////////////

  final currentStatus =
      (paymentData["status"] ??
              "pending")
          .toString()
          .toLowerCase();

  /////////////////////////////////////////////////////////
  /// ALREADY SUCCESSFUL
  /////////////////////////////////////////////////////////

  if (currentStatus == "successful" ||
      currentStatus == "success" ||
      currentStatus == "paid") {
    throw Exception(
      "This payment is already successful.",
    );
  }

  /////////////////////////////////////////////////////////
  /// PAYMENT PROOF REQUIRED
  /////////////////////////////////////////////////////////

  final proofImage =
      (paymentData[
                  "paymentProofImage"] ??
              "")
          .toString()
          .trim();

  if (proofImage.isEmpty) {
    throw Exception(
      "Customer payment proof has not been uploaded.",
    );
  }

  /////////////////////////////////////////////////////////
  /// UPDATE PAYMENT DATA
  /////////////////////////////////////////////////////////

  paymentData["status"] =
      "successful";

  paymentData["verifiedBy"] =
      adminId;

  paymentData["verifiedAt"] =
      FieldValue.serverTimestamp();

  /////////////////////////////////////////////////////////
  /// BATCH
  /////////////////////////////////////////////////////////

  final batch =
      _firestore.batch();

  /////////////////////////////////////////////////////////
  /// 1. UPDATE ORIGINAL PAYMENT MESSAGE
  /////////////////////////////////////////////////////////

  batch.update(
    messageRef,
    {
      "paymentData":
          paymentData,

      "text":
          "Payment verified successfully",
    },
  );

  /////////////////////////////////////////////////////////
  /// 2. UPDATE ORDER
  /////////////////////////////////////////////////////////

  batch.update(
    orderRef,
    {
      "paymentStatus":
          "Paid",

      "paymentVerifiedBy":
          adminId,

      "paymentVerifiedAt":
          FieldValue.serverTimestamp(),
    },
  );

  /////////////////////////////////////////////////////////
  /// 3. UPDATE CHAT SUMMARY
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
          FieldValue.serverTimestamp(),

      "updatedAt":
          FieldValue.serverTimestamp(),

      "unreadCustomer":
          FieldValue.increment(1),

      "unreadAdmin":
          0,
    },
  );

  /////////////////////////////////////////////////////////
  /// COMMIT
  /////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
/// UPDATE ORDER SUMMARY PAYMENT STATUS
/////////////////////////////////////////////////////////

final orderMessagesSnapshot = await chatRef
    .collection("messages")
    .where(
      "type",
      isEqualTo: "order",
    )
    .limit(1)
    .get();

if (orderMessagesSnapshot.docs.isNotEmpty) {
  final orderMessage =
      orderMessagesSnapshot.docs.first;

  final orderMessageData =
      orderMessage.data();

  final rawOrderSummary =
      orderMessageData["orderSummary"];

  if (rawOrderSummary is Map) {
    final orderSummary =
        Map<String, dynamic>.from(
      rawOrderSummary,
    );

    orderSummary["paymentStatus"] =
        "Paid";

    batch.update(
      orderMessage.reference,
      {
        "orderSummary":
            orderSummary,
      },
    );
  }
}
  await batch.commit();
}
/////////////////////////////////////////////////////////
/// REJECT PAYMENT
///
/// Customer must upload a new proof.
/////////////////////////////////////////////////////////

Future<void> rejectPayment({
  required String orderId,
  required String messageId,
  String reason = "",
}) async {
  final adminId = _adminId;

  /////////////////////////////////////////////////////////
  /// REFERENCES
  /////////////////////////////////////////////////////////

  final chatRef = _firestore
      .collection("orderChats")
      .doc(orderId);

  final messageRef = chatRef
      .collection("messages")
      .doc(messageId);

  /////////////////////////////////////////////////////////
  /// GET PAYMENT MESSAGE
  /////////////////////////////////////////////////////////

  final messageSnapshot =
      await messageRef.get();

  if (!messageSnapshot.exists) {
    throw Exception(
      "Payment request not found.",
    );
  }

  final data =
      messageSnapshot.data();

  if (data == null) {
    throw Exception(
      "Payment request data not found.",
    );
  }

  /////////////////////////////////////////////////////////
  /// VERIFY MESSAGE TYPE
  /////////////////////////////////////////////////////////

  if (data["type"] != "payment") {
    throw Exception(
      "This is not a payment message.",
    );
  }

  /////////////////////////////////////////////////////////
  /// PAYMENT DATA
  /////////////////////////////////////////////////////////

  final rawPaymentData =
      data["paymentData"];

  final Map<String, dynamic>
      paymentData =
      rawPaymentData is Map
          ? Map<String, dynamic>.from(
              rawPaymentData,
            )
          : {};

  /////////////////////////////////////////////////////////
  /// UPDATE STATUS
  /////////////////////////////////////////////////////////

  paymentData["status"] =
      "rejected";

  paymentData["rejectedBy"] =
      adminId;

  paymentData["rejectedAt"] =
      FieldValue.serverTimestamp();

  paymentData["rejectionReason"] =
      reason.trim();

  /////////////////////////////////////////////////////////
  /// BATCH
  /////////////////////////////////////////////////////////

  final batch =
      _firestore.batch();

  /////////////////////////////////////////////////////////
  /// UPDATE ORIGINAL PAYMENT MESSAGE
  /////////////////////////////////////////////////////////

  batch.update(
    messageRef,
    {
      "paymentData":
          paymentData,

      "text":
          "Payment proof rejected",
    },
  );

  /////////////////////////////////////////////////////////
  /// UPDATE CHAT
  /////////////////////////////////////////////////////////

  batch.update(
    chatRef,
    {
      "lastMessage":
          "Payment proof rejected",

      "lastMessageType":
          "payment",

      "lastSenderType":
          "admin",

      "lastSenderId":
          adminId,

      "lastMessageTime":
          FieldValue.serverTimestamp(),

      "updatedAt":
          FieldValue.serverTimestamp(),

      "unreadCustomer":
          FieldValue.increment(1),

      "unreadAdmin":
          0,
    },
  );

  /////////////////////////////////////////////////////////
  /// COMMIT
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