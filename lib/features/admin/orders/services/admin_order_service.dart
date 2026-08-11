import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrderService {
  AdminOrderService._();

  static final AdminOrderService instance =
      AdminOrderService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static const int pageSize = 25;

  ///////////////////////////////////////////////////////////
  /// BASE QUERY
  ///
  /// Only Flutter App orders.
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
  /// LATEST ORDER CHATS
  ///
  /// Realtime
  /// Latest 25 only
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
  /// LOAD MORE ORDER CHATS
  ///
  /// Used for pagination after first 25.
  ///////////////////////////////////////////////////////////

  Future<QuerySnapshot<Map<String, dynamic>>>
      loadMore({
    required DocumentSnapshot<
        Map<String, dynamic>> lastDocument,
  }) {
    return _baseQuery
        .orderBy(
          "updatedAt",
          descending: true,
        )
        .startAfterDocument(
          lastDocument,
        )
        .limit(pageSize)
        .get();
  }

  ///////////////////////////////////////////////////////////
  /// REFRESH FIRST PAGE
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
  /// SINGLE ORDER CHAT - REALTIME
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
  /// SINGLE ORDER CHAT - ONCE
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
  /// CHAT MESSAGES - REALTIME
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
  /// SEARCH BY EXACT ORDER ID
  ///////////////////////////////////////////////////////////

  Future<QuerySnapshot<Map<String, dynamic>>>
      searchByOrderId(
    String orderId,
  ) {
    return _baseQuery
        .where(
          "orderId",
          isEqualTo: orderId.trim(),
        )
        .limit(1)
        .get();
  }

  ///////////////////////////////////////////////////////////
  /// SEARCH BY EXACT CUSTOMER NAME
  ///
  /// NOTE:
  /// This is exact matching.
  /// Firestore does not provide normal
  /// "contains" search here.
  ///////////////////////////////////////////////////////////

  Future<QuerySnapshot<Map<String, dynamic>>>
      searchByCustomer(
    String customerName,
  ) {
    return _baseQuery
        .where(
          "customerName",
          isEqualTo: customerName.trim(),
        )
        .limit(pageSize)
        .get();
  }

  ///////////////////////////////////////////////////////////
  /// SEARCH BY EXACT PHONE
  ///////////////////////////////////////////////////////////

  Future<QuerySnapshot<Map<String, dynamic>>>
      searchByPhone(
    String phone,
  ) {
    return _baseQuery
        .where(
          "customerPhone",
          isEqualTo: phone.trim(),
        )
        .limit(pageSize)
        .get();
  }

  ///////////////////////////////////////////////////////////
  /// FILTER BY ORDER STATUS
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
  /// FILTER BY PAYMENT STATUS
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
  /// MARK CHAT AS READ BY ADMIN
  ///
  /// IMPORTANT:
  /// Do NOT update updatedAt here.
  ///
  /// Reading a chat should not make an old order
  /// jump to the top of the order list.
  ///////////////////////////////////////////////////////////

  Future<void> markAdminRead(
    String orderId,
  ) async {
    await _firestore
        .collection("orderChats")
        .doc(orderId)
        .update({
      "unreadAdmin": 0,
    });
  }
}