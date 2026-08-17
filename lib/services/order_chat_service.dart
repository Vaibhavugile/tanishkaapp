import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/chat_message_model.dart';
import '../models/order_chat_model.dart';

class OrderChatService {
  OrderChatService._();

  static final OrderChatService instance =
      OrderChatService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FirebaseStorage _storage =
      FirebaseStorage.instance;

  /////////////////////////////////////////////////////////
  /// CURRENT CUSTOMER UID
  /////////////////////////////////////////////////////////

  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        "User not logged in.",
      );
    }

    return user.uid;
  }

  /////////////////////////////////////////////////////////
  /// CUSTOMER CHAT LIST
  /////////////////////////////////////////////////////////

  Stream<List<OrderChatModel>> chatsStream() {
    return _firestore
        .collection("orderChats")
        .where(
          "customerId",
          isEqualTo: _uid,
        )
        .orderBy(
          "updatedAt",
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                OrderChatModel.fromFirestore,
              )
              .toList(),
        );
  }

  /////////////////////////////////////////////////////////
  /// CHAT MESSAGES
  /////////////////////////////////////////////////////////

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

  /////////////////////////////////////////////////////////
  /// SEND TEXT MESSAGE
  /////////////////////////////////////////////////////////

  Future<void> sendMessage({
    required String orderId,
    required String text,
  }) async {
    if (text.trim().isEmpty) {
      return;
    }

    final now =
        FieldValue.serverTimestamp();

    final chatRef = _firestore
        .collection("orderChats")
        .doc(orderId);

    final messageRef =
        chatRef.collection("messages").doc();

    final batch =
        _firestore.batch();

    /////////////////////////////////////////////////////////
    /// MESSAGE
    /////////////////////////////////////////////////////////

    batch.set(messageRef, {
      "senderId": _uid,

      "senderType": "customer",

      "type": "text",

      "text": text.trim(),

      "image": "",

      "pdf": "",

      "orderId": orderId,

      "createdAt": now,
    });

    /////////////////////////////////////////////////////////
    /// CHAT SUMMARY
    /////////////////////////////////////////////////////////

    batch.update(chatRef, {
      "lastMessage":
          text.trim(),

      "lastMessageType":
          "text",

      "lastSenderType":
          "customer",

      "lastSenderId":
          _uid,

      "lastMessageTime":
          now,

      "updatedAt":
          now,

      "unreadAdmin":
          FieldValue.increment(1),
    });

    await batch.commit();
  }

  /////////////////////////////////////////////////////////
  /// SUBMIT PAYMENT PROOF
  ///
  /// This updates the EXISTING payment message.
  /////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////
/// SUBMIT PAYMENT PROOF
///
/// Customer uploads payment screenshot.
/// Updates the EXISTING payment message.
/// Does NOT mark payment as successful.
/////////////////////////////////////////////////////////


Future<void> submitPaymentProof({
  required String orderId,
  required String messageId,
  required File imageFile,
}) async {
  /////////////////////////////////////////////////////////
  /// CUSTOMER
  /////////////////////////////////////////////////////////

  final customerId = _uid;

  /////////////////////////////////////////////////////////
  /// VALIDATE IMAGE
  /////////////////////////////////////////////////////////

  if (!imageFile.existsSync()) {
    throw Exception(
      "Payment proof image not found.",
    );
  }

  /////////////////////////////////////////////////////////
  /// PAYMENT MESSAGE
  /////////////////////////////////////////////////////////

  final messageRef = _firestore
      .collection("orderChats")
      .doc(orderId)
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

  final messageData =
      messageSnapshot.data();

  if (messageData == null) {
    throw Exception(
      "Payment request data not found.",
    );
  }

  /////////////////////////////////////////////////////////
  /// VERIFY PAYMENT MESSAGE
  /////////////////////////////////////////////////////////

  if (messageData["type"] != "payment") {
    throw Exception(
      "This is not a payment request.",
    );
  }

  /////////////////////////////////////////////////////////
  /// PAYMENT DATA
  /////////////////////////////////////////////////////////

  final rawPaymentData =
      messageData["paymentData"];

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
  /// ALREADY PAID
  /////////////////////////////////////////////////////////

  if (currentStatus == "successful" ||
      currentStatus == "success" ||
      currentStatus == "paid") {
    throw Exception(
      "This payment is already successful.",
    );
  }

  /////////////////////////////////////////////////////////
  /// DON'T ALLOW DUPLICATE PROOF
  /////////////////////////////////////////////////////////

  if (currentStatus ==
      "proof_submitted") {
    throw Exception(
      "Payment proof has already been submitted.",
    );
  }

  /////////////////////////////////////////////////////////
  /// STORAGE PATH
  /////////////////////////////////////////////////////////

  final storageRef = _storage
      .ref()
      .child(
        "paymentProofs"
        "/$orderId"
        "/$messageId"
        "/payment_proof.jpg",
      );

  /////////////////////////////////////////////////////////
  /// UPLOAD PAYMENT SCREENSHOT
  /////////////////////////////////////////////////////////

  await storageRef.putFile(
    imageFile,
    SettableMetadata(
      contentType:
          "image/jpeg",
      customMetadata: {
        "orderId": orderId,
        "messageId": messageId,
        "customerId": customerId,
        "type": "payment_proof",
      },
    ),
  );

  /////////////////////////////////////////////////////////
  /// GET DOWNLOAD URL
  /////////////////////////////////////////////////////////

  final proofImageUrl =
      await storageRef.getDownloadURL();

  /////////////////////////////////////////////////////////
  /// UPDATE PAYMENT DATA
  /////////////////////////////////////////////////////////

  paymentData["status"] =
      "proof_submitted";

  paymentData[
          "paymentProofImage"] =
      proofImageUrl;

  paymentData[
          "paymentProofUploadedBy"] =
      customerId;

  paymentData[
          "paymentProofUploadedAt"] =
      FieldValue.serverTimestamp();

  /////////////////////////////////////////////////////////
  /// CHAT
  /////////////////////////////////////////////////////////

  final chatRef = _firestore
      .collection("orderChats")
      .doc(orderId);

  /////////////////////////////////////////////////////////
  /// ORDER
  /////////////////////////////////////////////////////////

  final orderRef = _firestore
      .collection("orders")
      .doc(orderId);

  /////////////////////////////////////////////////////////
  /// GET ORIGINAL ORDER MESSAGE
  ///
  /// This is the message containing
  /// orderSummary.
  /////////////////////////////////////////////////////////

  final orderMessagesSnapshot =
      await chatRef
          .collection("messages")
          .where(
            "type",
            isEqualTo: "order",
          )
          .limit(1)
          .get();

  /////////////////////////////////////////////////////////
  /// BATCH
  /////////////////////////////////////////////////////////

  final batch =
      _firestore.batch();

  /////////////////////////////////////////////////////////
  /// 1. UPDATE PAYMENT MESSAGE
  /////////////////////////////////////////////////////////

  batch.update(
    messageRef,
    {
      "paymentData":
          paymentData,
    },
  );

  /////////////////////////////////////////////////////////
  /// 2. UPDATE ORDERS/{ORDER ID}
  ///
  /// Pending
  ///     ↓
  /// Confirmation Pending
  /////////////////////////////////////////////////////////

  batch.update(
    orderRef,
    {
      "paymentStatus":
          "Confirmation Pending",
    },
  );

  /////////////////////////////////////////////////////////
  /// 3. UPDATE ORDER CHAT
  ///
  /// OrderCard reads paymentStatus
  /// from orderChats/{orderId}.
  /////////////////////////////////////////////////////////

  batch.update(
    chatRef,
    {
      "paymentStatus":
          "Confirmation Pending",

      "lastMessage":
          "Payment proof submitted",

      "lastMessageType":
          "payment",

      "lastSenderType":
          "customer",

      "lastSenderId":
          customerId,

      "lastMessageTime":
          FieldValue.serverTimestamp(),

      "updatedAt":
          FieldValue.serverTimestamp(),

      "unreadAdmin":
          FieldValue.increment(1),
    },
  );

  /////////////////////////////////////////////////////////
  /// 4. UPDATE ORDER SUMMARY
  ///
  /// OrderSummaryCard reads paymentStatus
  /// from orderSummary.
  /////////////////////////////////////////////////////////

  if (orderMessagesSnapshot
      .docs
      .isNotEmpty) {
    final orderMessage =
        orderMessagesSnapshot
            .docs
            .first;

    final orderMessageData =
        orderMessage.data();

    final rawOrderSummary =
        orderMessageData[
            "orderSummary"];

    if (rawOrderSummary is Map) {
      final orderSummary =
          Map<String, dynamic>.from(
        rawOrderSummary,
      );

      orderSummary[
              "paymentStatus"] =
          "Confirmation Pending";

      batch.update(
        orderMessage.reference,
        {
          "orderSummary":
              orderSummary,
        },
      );
    }
  }

  /////////////////////////////////////////////////////////
  /// COMMIT EVERYTHING
  /////////////////////////////////////////////////////////

  await batch.commit();
}
  /////////////////////////////////////////////////////////
  /// MARK AS READ
  /////////////////////////////////////////////////////////

  Future<void> markAsRead(
    String orderId,
  ) async {
    await _firestore
        .collection("orderChats")
        .doc(orderId)
        .update({
      "unreadCustomer": 0,
    });
  }
}