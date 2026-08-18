import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class AdminOrderService {
  AdminOrderService._();

  static final AdminOrderService instance =
      AdminOrderService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;
      final FirebaseAuth _auth =
    FirebaseAuth.instance;
String get _adminId {
  final user = _auth.currentUser;

  if (user == null) {
    throw Exception(
      "Admin not logged in.",
    );
  }

  return user.uid;
}
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
    ///////////////////////////////////////////////////////////
  /// GET PACKING DATA - ONCE
  ///////////////////////////////////////////////////////////

  Future<Map<String, dynamic>> getPackingData(
    String orderId,
  ) async {
    final doc = await _firestore
        .collection("orderChats")
        .doc(orderId)
        .get();

    if (!doc.exists) {
      return {};
    }

    final data = doc.data();

    if (data == null) {
      return {};
    }

    final packing = data["packing"];

    if (packing is Map<String, dynamic>) {
      return packing;
    }

    return {};
  }

  ///////////////////////////////////////////////////////////
  /// UPDATE PACKING DATA
  ///////////////////////////////////////////////////////////

  Future<void> updatePackingData({
    required String orderId,
    required Map<String, dynamic> packingData,
  }) async {
    await _firestore
        .collection("orderChats")
        .doc(orderId)
        .update({
      "packing": packingData,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  ///////////////////////////////////////////////////////////
  /// UPDATE PACKING STATUS
  ///////////////////////////////////////////////////////////

  Future<void> updatePackingStatus({
    required String orderId,
    required String status,
  }) async {
    await _firestore
        .collection("orderChats")
        .doc(orderId)
        .update({
      "packingStatus": status,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }
    ///////////////////////////////////////////////////////////
  /// GET ORDER ITEMS
  ///
  /// Reads the original order document:
  /// orders/{orderId}
  ///////////////////////////////////////////////////////////

  Future<List<Map<String, dynamic>>> getOrderItems(
    String orderId,
  ) async {
    final orderDoc = await _firestore
        .collection("orders")
        .doc(orderId)
        .get();

    if (!orderDoc.exists) {
      throw Exception(
        "Order not found.",
      );
    }

    final data = orderDoc.data();

    if (data == null) {
      return [];
    }

    final rawItems = data["items"];

    if (rawItems is! List) {
      return [];
    }

    return rawItems
        .whereType<Map>()
        .map(
          (item) =>
              Map<String, dynamic>.from(item),
        )
        .toList();
  }
    ///////////////////////////////////////////////////////////
  /// SAVE PACKING ITEM STATUS
  ///////////////////////////////////////////////////////////

  Future<void> savePackingItemStatus({
    required String orderId,
    required int itemIndex,
    required String status,
  }) async {
    final chatRef = _firestore
        .collection("orderChats")
        .doc(orderId);

    final snapshot =
        await chatRef.get();

    if (!snapshot.exists) {
      throw Exception(
        "Order chat not found.",
      );
    }

    final data =
        snapshot.data() ?? {};

    /////////////////////////////////////////////////////////
    /// EXISTING PACKING DATA
    /////////////////////////////////////////////////////////

    final rawPacking =
        data["packing"];

    final Map<String, dynamic>
        packingData =
        rawPacking is Map
            ? Map<String, dynamic>.from(
                rawPacking,
              )
            : {};

    /////////////////////////////////////////////////////////
    /// EXISTING PACKING ITEMS
    /////////////////////////////////////////////////////////

    final rawItems =
        packingData["items"];

    final List<dynamic>
        packingItems =
        rawItems is List
            ? List<dynamic>.from(
                rawItems,
              )
            : [];

    /////////////////////////////////////////////////////////
    /// MAKE SURE INDEX EXISTS
    /////////////////////////////////////////////////////////

    while (packingItems.length <=
        itemIndex) {
      packingItems.add({});
    }

    /////////////////////////////////////////////////////////
    /// EXISTING ITEM
    /////////////////////////////////////////////////////////

    final rawItem =
        packingItems[itemIndex];

    final Map<String, dynamic>
        itemData =
        rawItem is Map
            ? Map<String, dynamic>.from(
                rawItem,
              )
            : {};

    /////////////////////////////////////////////////////////
    /// UPDATE STATUS
    /////////////////////////////////////////////////////////

    itemData["status"] =
        status;

    itemData["checkedAt"] =
    Timestamp.now();
    packingItems[itemIndex] =
        itemData;

    /////////////////////////////////////////////////////////
    /// CALCULATE COUNTS
    /////////////////////////////////////////////////////////

    int correct = 0;
    int wrong = 0;
    int missing = 0;
    int pending = 0;

    for (final rawItem
        in packingItems) {
      if (rawItem is! Map) {
        pending++;
        continue;
      }

      final itemStatus =
          (rawItem["status"] ?? "")
              .toString();

      switch (itemStatus) {
        case "correct":
          correct++;
          break;

        case "wrong":
          wrong++;
          break;

        case "missing":
          missing++;
          break;

        default:
          pending++;
      }
    }

    /////////////////////////////////////////////////////////
    /// SAVE PACKING DATA
    /////////////////////////////////////////////////////////

    packingData["items"] =
        packingItems;

    packingData["correctCount"] =
        correct;

    packingData["wrongCount"] =
        wrong;

    packingData["missingCount"] =
        missing;

    packingData["pendingCount"] =
        pending;

    packingData["updatedAt"] =
        FieldValue.serverTimestamp();

    /////////////////////////////////////////////////////////
    /// SAVE
    /////////////////////////////////////////////////////////

    await chatRef.update({
      "packing":
          packingData,

      "packingStatus":
          "In Progress",

      "updatedAt":
          FieldValue.serverTimestamp(),
    });
  }
  ///////////////////////////////////////////////////////////
/// UPDATE PACKING ITEM DETAILS
///////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////
/// UPDATE PACKING ITEM DETAILS
///////////////////////////////////////////////////////////

Future<void> updatePackingItemDetails({
  required String orderId,
  required int itemIndex,
  String? productCode,
  String? variant,
  int? quantity,
  int? missingQuantity,
  String? adminNote,
  
}) async {
  final adminId = _adminId;
  final chatRef = _firestore
      .collection("orderChats")
      .doc(orderId);

  final snapshot =
      await chatRef.get();

  if (!snapshot.exists) {
    throw Exception(
      "Order chat not found.",
    );
  }

  final data =
      snapshot.data() ?? {};

  /////////////////////////////////////////////////////////
  /// EXISTING PACKING DATA
  /////////////////////////////////////////////////////////

  final rawPacking =
      data["packing"];

  final Map<String, dynamic>
      packingData =
      rawPacking is Map
          ? Map<String, dynamic>.from(
              rawPacking,
            )
          : {};

  /////////////////////////////////////////////////////////
  /// EXISTING ITEMS
  /////////////////////////////////////////////////////////

  final rawItems =
      packingData["items"];

  final List<dynamic>
      packingItems =
      rawItems is List
          ? List<dynamic>.from(
              rawItems,
            )
          : [];

  /////////////////////////////////////////////////////////
  /// MAKE SURE ITEM EXISTS
  /////////////////////////////////////////////////////////

  while (packingItems.length <=
      itemIndex) {
    packingItems.add({});
  }

  /////////////////////////////////////////////////////////
  /// EXISTING ITEM
  /////////////////////////////////////////////////////////

  final rawItem =
      packingItems[itemIndex];

  final Map<String, dynamic>
      itemData =
      rawItem is Map
          ? Map<String, dynamic>.from(
              rawItem,
            )
          : {};

  /////////////////////////////////////////////////////////
  /// UPDATE ONLY PROVIDED VALUES
  /////////////////////////////////////////////////////////

  if (productCode != null) {
    itemData["productCode"] =
        productCode.trim();
  }

  if (variant != null) {
    itemData["variant"] =
        variant.trim();
  }

  if (quantity != null) {
    itemData["quantity"] =
        quantity;
  }

  if (missingQuantity != null) {
    itemData["missingQuantity"] =
        missingQuantity;
  }

  if (adminNote != null) {
    itemData["adminNote"] =
        adminNote.trim();
  }

  /////////////////////////////////////////////////////////
  /// UPDATED TIME
  ///
  /// IMPORTANT:
  /// This item is inside an ARRAY.
  /// FieldValue.serverTimestamp() is NOT allowed here.
  /////////////////////////////////////////////////////////

  itemData["updatedBy"] =
    adminId;

itemData["updatedAt"] =
    Timestamp.now();
  /////////////////////////////////////////////////////////
  /// SAVE ITEM BACK TO ARRAY
  /////////////////////////////////////////////////////////

  packingItems[itemIndex] =
      itemData;

  /////////////////////////////////////////////////////////
  /// SAVE PACKING ITEMS
  /////////////////////////////////////////////////////////

  packingData["items"] =
      packingItems;

  /////////////////////////////////////////////////////////
  /// TOP LEVEL TIMESTAMP
  ///
  /// This IS allowed because packingData is a map,
  /// not an array element.
  /////////////////////////////////////////////////////////

  packingData["updatedAt"] =
      FieldValue.serverTimestamp();

  /////////////////////////////////////////////////////////
  /// SAVE TO FIRESTORE
  /////////////////////////////////////////////////////////

  await chatRef.update({
    "packing":
        packingData,

    "updatedAt":
        FieldValue.serverTimestamp(),
  });
}
///////////////////////////////////////////////////////////
/// CONFIRM PACKING ITEM
///////////////////////////////////////////////////////////

Future<void> confirmPackingItem({
  required String orderId,
  required int itemIndex,
}) async {
  final adminId = _adminId;

  final chatRef = _firestore
      .collection("orderChats")
      .doc(orderId);

  final snapshot =
      await chatRef.get();

  if (!snapshot.exists) {
    throw Exception(
      "Order chat not found.",
    );
  }

  final data =
      snapshot.data() ?? {};

  /////////////////////////////////////////////////////////
  /// PACKING
  /////////////////////////////////////////////////////////

  final rawPacking =
      data["packing"];

  final Map<String, dynamic>
      packingData =
      rawPacking is Map
          ? Map<String, dynamic>.from(
              rawPacking,
            )
          : {};

  /////////////////////////////////////////////////////////
  /// ITEMS
  /////////////////////////////////////////////////////////

  final rawItems =
      packingData["items"];

  final List<dynamic>
      packingItems =
      rawItems is List
          ? List<dynamic>.from(
              rawItems,
            )
          : [];

  if (itemIndex < 0 ||
      itemIndex >= packingItems.length) {
    throw Exception(
      "Packing item not found.",
    );
  }

  /////////////////////////////////////////////////////////
  /// ITEM
  /////////////////////////////////////////////////////////

  final rawItem =
      packingItems[itemIndex];

  final Map<String, dynamic>
      itemData =
      rawItem is Map
          ? Map<String, dynamic>.from(
              rawItem,
            )
          : {};

  /////////////////////////////////////////////////////////
  /// QUANTITIES
  /////////////////////////////////////////////////////////

  final ordered =
      int.tryParse(
            "${itemData["orderedQuantity"] ?? itemData["quantity"] ?? 0}",
          ) ??
          0;

  final received =
      int.tryParse(
            "${itemData["receivedQuantity"] ?? itemData["quantity"] ?? 0}",
          ) ??
          0;

  final missing =
      int.tryParse(
            "${itemData["missingQuantity"] ?? 0}",
          ) ??
          0;

  /////////////////////////////////////////////////////////
  /// VALIDATE
  /////////////////////////////////////////////////////////

  if (received + missing !=
      ordered) {
    throw Exception(
      "Cannot confirm. Received ($received) + Missing ($missing) must equal Ordered ($ordered).",
    );
  }

  /////////////////////////////////////////////////////////
  /// CONFIRM
  /////////////////////////////////////////////////////////

  itemData["status"] =
      "confirmed";

  itemData["confirmedBy"] =
      adminId;

  itemData["confirmedAt"] =
      Timestamp.now();

  /////////////////////////////////////////////////////////
  /// SAVE ITEM
  /////////////////////////////////////////////////////////

  packingItems[itemIndex] =
      itemData;

  /////////////////////////////////////////////////////////
  /// CALCULATE REPORT
  /////////////////////////////////////////////////////////

  int confirmedCount = 0;
  int pendingCount = 0;

  int totalOrdered = 0;
  int totalReceived = 0;
  int totalMissing = 0;

  for (final raw
      in packingItems) {
    if (raw is! Map) {
      pendingCount++;
      continue;
    }

    final map =
        Map<String, dynamic>.from(
      raw,
    );

    final itemOrdered =
        int.tryParse(
              "${map["orderedQuantity"] ?? map["quantity"] ?? 0}",
            ) ??
            0;

    final itemReceived =
        int.tryParse(
              "${map["receivedQuantity"] ?? map["quantity"] ?? 0}",
            ) ??
            0;

    final itemMissing =
        int.tryParse(
              "${map["missingQuantity"] ?? 0}",
            ) ??
            0;

    totalOrdered +=
        itemOrdered;

    totalReceived +=
        itemReceived;

    totalMissing +=
        itemMissing;

    if (map["status"] ==
        "confirmed") {
      confirmedCount++;
    } else {
      pendingCount++;
    }
  }

  /////////////////////////////////////////////////////////
  /// OVERALL STATUS
  /////////////////////////////////////////////////////////

  final allConfirmed =
      packingItems.isNotEmpty &&
          pendingCount == 0;

  packingData["items"] =
      packingItems;

  packingData["totalItems"] =
      packingItems.length;

  packingData[
          "totalOrderedQuantity"] =
      totalOrdered;

  packingData[
          "totalReceivedQuantity"] =
      totalReceived;

  packingData[
          "totalMissingQuantity"] =
      totalMissing;

  packingData["confirmedCount"] =
      confirmedCount;

  packingData["pendingCount"] =
      pendingCount;

  packingData["status"] =
      allConfirmed
          ? "Confirmed"
          : "In Progress";

  /////////////////////////////////////////////////////////
  /// LAST UPDATE
  /////////////////////////////////////////////////////////

  packingData["lastUpdatedBy"] =
      adminId;

  packingData["lastUpdatedAt"] =
      FieldValue.serverTimestamp();

  /////////////////////////////////////////////////////////
  /// FINAL CONFIRMATION
  /////////////////////////////////////////////////////////

  if (allConfirmed) {
    packingData["confirmedBy"] =
        adminId;

    packingData["confirmedAt"] =
        FieldValue.serverTimestamp();
  }

  /////////////////////////////////////////////////////////
  /// SAVE
  /////////////////////////////////////////////////////////

  await chatRef.update({
    "packing":
        packingData,

    "packingStatus":
        allConfirmed
            ? "Confirmed"
            : "In Progress",

    "updatedAt":
        FieldValue.serverTimestamp(),
  });
}
///////////////////////////////////////////////////////////
/// GET ADMIN NAME
///////////////////////////////////////////////////////////

Future<String> getAdminName(
  String adminId,
) async {
  if (adminId.trim().isEmpty) {
    return "Unknown Admin";
  }

  try {
    final doc = await _firestore
        .collection("admins")
        .doc(adminId)
        .get();

    if (doc.exists) {
      final data =
          doc.data() ?? {};

      final fullName =
          (data["fullName"] ?? "")
              .toString()
              .trim();

      if (fullName.isNotEmpty) {
        return fullName;
      }

      final email =
          (data["email"] ?? "")
              .toString()
              .trim();

      if (email.isNotEmpty) {
        return email;
      }
    }
  } catch (_) {}

  return adminId;
}
}