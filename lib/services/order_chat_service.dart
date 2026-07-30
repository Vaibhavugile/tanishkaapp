import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in.");
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

    final batch = _firestore.batch();

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

    batch.update(chatRef, {
      "lastMessage": text.trim(),

      "lastMessageType": "text",

      "lastMessageTime": now,

      "updatedAt": now,

      "unreadAdmin":
          FieldValue.increment(1),
    });

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