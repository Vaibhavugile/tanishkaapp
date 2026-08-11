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

  String get _adminId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("Admin not logged in.");
    }

    return user.uid;
  }

  /////////////////////////////////////////////////////////
  /// Messages Stream
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
  /// Send Admin Text Message
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

    final batch = _firestore.batch();

    /////////////////////////////////////////////////////////
    /// Message
    /////////////////////////////////////////////////////////

    batch.set(messageRef, {
      "senderId": _adminId,

      "senderType": "admin",

      "type": "text",

      "text": text.trim(),

      "image": "",

      "pdf": "",

      "orderId": orderId,

      "createdAt": now,
    });

    /////////////////////////////////////////////////////////
    /// Chat Summary
    /////////////////////////////////////////////////////////

    batch.update(chatRef, {
      "lastMessage": text.trim(),

      "lastMessageType": "text",

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

  /////////////////////////////////////////////////////////
  /// Mark Read
  /////////////////////////////////////////////////////////

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

  /////////////////////////////////////////////////////////
  /// Send System Message
  /////////////////////////////////////////////////////////

  Future<void> sendSystemMessage({
    required String orderId,
    required String message,
    required String type,
  }) async {
    final now =
        FieldValue.serverTimestamp();

    final chatRef = _firestore
        .collection("orderChats")
        .doc(orderId);

    final messageRef =
        chatRef.collection("messages").doc();

    final batch = _firestore.batch();

    batch.set(messageRef, {
      "senderId": "system",

      "senderType": "system",

      "type": type,

      "text": message,

      "image": "",

      "pdf": "",

      "orderId": orderId,

      "createdAt": now,
    });

    batch.update(chatRef, {
      "lastMessage": message,

      "lastMessageType": type,

      "lastSenderType": "system",

      "lastSenderId": "system",

      "lastMessageTime": now,

      "updatedAt": now,
    });

    await batch.commit();
  }
}