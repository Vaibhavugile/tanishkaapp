import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrderService {
  AdminOrderService._();

  static final AdminOrderService instance =
      AdminOrderService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static const int pageSize = 25;

  ///////////////////////////////////////////////////////////
  /// Base Query
  ///////////////////////////////////////////////////////////

  Query<Map<String, dynamic>> get _baseQuery {
    return _firestore
        .collection("orderChats")
        .where(
          "orderSource",
          isEqualTo: "Flutter App",
        );
  }

  ///////////////////////////////////////////////////////////
  /// Latest Order Chats (Realtime)
  ///////////////////////////////////////////////////////////

  Stream<QuerySnapshot<Map<String, dynamic>>>
      latestOrderChats() {
    return _baseQuery
        .orderBy(
          "updatedAt",
          descending: true,
        )
        .limit(pageSize)
        .snapshots();
  }

  ///////////////////////////////////////////////////////////
  /// Load More
  ///////////////////////////////////////////////////////////

  Future<QuerySnapshot<Map<String, dynamic>>>
      loadMore({
    required DocumentSnapshot lastDocument,
  }) {
    return _baseQuery
        .orderBy(
          "updatedAt",
          descending: true,
        )
        .startAfterDocument(lastDocument)
        .limit(pageSize)
        .get();
  }

  ///////////////////////////////////////////////////////////
  /// Refresh First Page
  ///////////////////////////////////////////////////////////

  Future<QuerySnapshot<Map<String, dynamic>>>
      refresh() {
    return _baseQuery
        .orderBy(
          "updatedAt",
          descending: true,
        )
        .limit(pageSize)
        .get();
  }

  ///////////////////////////////////////////////////////////
  /// Single Order Chat
  ///////////////////////////////////////////////////////////

  Stream<DocumentSnapshot<Map<String, dynamic>>>
      orderChatStream(
    String orderId,
  ) {
    return _firestore
        .collection("orderChats")
        .doc(orderId)
        .snapshots();
  }

  ///////////////////////////////////////////////////////////
  /// Get Order Chat Once
  ///////////////////////////////////////////////////////////

  Future<DocumentSnapshot<Map<String, dynamic>>>
      getOrderChat(
    String orderId,
  ) {
    return _firestore
        .collection("orderChats")
        .doc(orderId)
        .get();
  }

  ///////////////////////////////////////////////////////////
  /// Chat Messages
  ///////////////////////////////////////////////////////////

  Stream<QuerySnapshot<Map<String, dynamic>>>
      messagesStream(
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
        .snapshots();
  }

  ///////////////////////////////////////////////////////////
  /// Search By Order ID
  ///////////////////////////////////////////////////////////

  Future<QuerySnapshot<Map<String, dynamic>>>
      searchByOrderId(
    String orderId,
  ) {
    return _baseQuery
        .where(
          "orderId",
          isEqualTo: orderId,
        )
        .limit(1)
        .get();
  }

  ///////////////////////////////////////////////////////////
  /// Search By Customer Name
  ///////////////////////////////////////////////////////////

  Future<QuerySnapshot<Map<String, dynamic>>>
      searchByCustomer(
    String customerName,
  ) {
    return _baseQuery
        .where(
          "customerName",
          isEqualTo: customerName,
        )
        .limit(pageSize)
        .get();
  }

  ///////////////////////////////////////////////////////////
  /// Search By Phone
  ///////////////////////////////////////////////////////////

  Future<QuerySnapshot<Map<String, dynamic>>>
      searchByPhone(
    String phone,
  ) {
    return _baseQuery
        .where(
          "customerPhone",
          isEqualTo: phone,
        )
        .limit(pageSize)
        .get();
  }

  ///////////////////////////////////////////////////////////
  /// Filter By Order Status
  ///////////////////////////////////////////////////////////

  Future<QuerySnapshot<Map<String, dynamic>>>
      filterByOrderStatus(
    String status,
  ) {
    return _baseQuery
        .where(
          "orderStatus",
          isEqualTo: status,
        )
        .orderBy(
          "updatedAt",
          descending: true,
        )
        .limit(pageSize)
        .get();
  }

  ///////////////////////////////////////////////////////////
  /// Filter By Payment Status
  ///////////////////////////////////////////////////////////

  Future<QuerySnapshot<Map<String, dynamic>>>
      filterByPaymentStatus(
    String status,
  ) {
    return _baseQuery
        .where(
          "paymentStatus",
          isEqualTo: status,
        )
        .orderBy(
          "updatedAt",
          descending: true,
        )
        .limit(pageSize)
        .get();
  }

  ///////////////////////////////////////////////////////////
  /// Mark Chat Read By Admin
  ///////////////////////////////////////////////////////////

  Future<void> markAdminRead(
    String orderId,
  ) async {
    await _firestore
        .collection("orderChats")
        .doc(orderId)
        .update({
      "unreadAdmin": 0,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }
}