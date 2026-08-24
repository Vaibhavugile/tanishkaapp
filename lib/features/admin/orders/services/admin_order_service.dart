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
int confirmedCount = 0;
int pendingCount = 0;

for (final rawItem in packingItems) {
  if (rawItem is! Map) {
    pendingCount++;
    continue;
  }

  final itemStatus =
      (rawItem["status"] ?? "")
          .toString()
          .trim()
          .toLowerCase();

  if (itemStatus == "confirmed") {
    confirmedCount++;
  } else {
    pendingCount++;
  }
}

    /////////////////////////////////////////////////////////
    /// SAVE PACKING DATA
    /////////////////////////////////////////////////////////

    packingData["items"] =
        packingItems;

    packingData["confirmedCount"] =
    confirmedCount;

packingData["pendingCount"] =
    pendingCount;

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
  int? receivedQuantity,
  int? missingQuantity,
  String? adminNote,
}) async {
  final adminId = _adminId;

  final chatRef = _firestore
      .collection("orderChats")
      .doc(orderId);

  /////////////////////////////////////////////////////////
  /// GET ORDER CHAT
  /////////////////////////////////////////////////////////

  final snapshot = await chatRef.get();

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

  final Map<String, dynamic> packingData =
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

  final List<dynamic> packingItems =
      rawItems is List
          ? List<dynamic>.from(
              rawItems,
            )
          : [];

  /////////////////////////////////////////////////////////
  /// MAKE SURE ITEM EXISTS
  /////////////////////////////////////////////////////////

  while (packingItems.length <= itemIndex) {
    packingItems.add({});
  }

  /////////////////////////////////////////////////////////
  /// EXISTING ITEM
  /////////////////////////////////////////////////////////

  final rawItem =
      packingItems[itemIndex];

  final Map<String, dynamic> itemData =
      rawItem is Map
          ? Map<String, dynamic>.from(
              rawItem,
            )
          : {};

  /////////////////////////////////////////////////////////
  /// ALWAYS GET ORIGINAL ORDERED QUANTITY
  ///
  /// IMPORTANT:
  /// The authoritative ordered quantity comes from:
  ///
  /// orders/{orderId}
  ///    items[itemIndex]
  ///       quantity
  ///
  /// This prevents orderedQuantity from becoming 0
  /// inside packing.items.
  /////////////////////////////////////////////////////////

  if (itemData["orderedQuantity"] == null) {
    final orderRef = _firestore
        .collection("orders")
        .doc(orderId);

    final orderSnapshot =
        await orderRef.get();

    if (!orderSnapshot.exists) {
      throw Exception(
        "Original order not found.",
      );
    }

    final orderData =
        orderSnapshot.data() ?? {};

    final rawOrderItems =
        orderData["items"];

    if (rawOrderItems is! List ||
        itemIndex < 0 ||
        itemIndex >= rawOrderItems.length) {
      throw Exception(
        "Original order item not found.",
      );
    }

    final originalItem =
        rawOrderItems[itemIndex];

    if (originalItem is Map) {
      itemData["orderedQuantity"] =
          int.tryParse(
                "${originalItem["quantity"] ?? 0}",
              ) ??
              0;
    } else {
      itemData["orderedQuantity"] = 0;
    }
  }

  /////////////////////////////////////////////////////////
  /// UPDATE PRODUCT CODE
  /////////////////////////////////////////////////////////

  if (productCode != null) {
    itemData["productCode"] =
        productCode.trim();
  }

  /////////////////////////////////////////////////////////
  /// UPDATE VARIANT
  /////////////////////////////////////////////////////////

  if (variant != null) {
    itemData["variant"] =
        variant.trim();
  }

  /////////////////////////////////////////////////////////
  /// UPDATE RECEIVED QUANTITY
  /////////////////////////////////////////////////////////

  if (receivedQuantity != null) {
    itemData["receivedQuantity"] =
        receivedQuantity;
  }

  /////////////////////////////////////////////////////////
  /// UPDATE MISSING QUANTITY
  /////////////////////////////////////////////////////////

  if (missingQuantity != null) {
    itemData["missingQuantity"] =
        missingQuantity;
  }

  /////////////////////////////////////////////////////////
  /// UPDATE ADMIN NOTE
  /////////////////////////////////////////////////////////

  if (adminNote != null) {
    itemData["adminNote"] =
        adminNote.trim();
  }

  /////////////////////////////////////////////////////////
  /// UPDATE ITEM METADATA
  /////////////////////////////////////////////////////////

  itemData["updatedBy"] =
      adminId;

  itemData["updatedAt"] =
      Timestamp.now();

  /////////////////////////////////////////////////////////
  /// SAVE ITEM BACK INTO ARRAY
  /////////////////////////////////////////////////////////

  packingItems[itemIndex] =
      itemData;

  /////////////////////////////////////////////////////////
  /// SAVE PACKING DATA
  /////////////////////////////////////////////////////////

  packingData["items"] =
      packingItems;

  packingData["updatedAt"] =
      FieldValue.serverTimestamp();

  /////////////////////////////////////////////////////////
  /// FIRESTORE UPDATE
  /////////////////////////////////////////////////////////

  await chatRef.update({
    "packing": packingData,
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

  /////////////////////////////////////////////////////////
  /// GET ORDER CHAT
  /////////////////////////////////////////////////////////

  final snapshot = await chatRef.get();

  if (!snapshot.exists) {
    throw Exception(
      "Order chat not found.",
    );
  }

  final data =
      snapshot.data() ?? {};

  /////////////////////////////////////////////////////////
  /// PACKING DATA
  /////////////////////////////////////////////////////////

  final rawPacking =
      data["packing"];

  final Map<String, dynamic> packingData =
      rawPacking is Map
          ? Map<String, dynamic>.from(
              rawPacking,
            )
          : {};

  /////////////////////////////////////////////////////////
  /// PACKING ITEMS
  /////////////////////////////////////////////////////////

  final rawItems =
      packingData["items"];

  final List<dynamic> packingItems =
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
  /// CURRENT PACKING ITEM
  /////////////////////////////////////////////////////////

  final rawItem =
      packingItems[itemIndex];

  final Map<String, dynamic> itemData =
      rawItem is Map
          ? Map<String, dynamic>.from(
              rawItem,
            )
          : {};

  /////////////////////////////////////////////////////////
  /// GET ORIGINAL ORDER
  ///
  /// IMPORTANT:
  /// Ordered quantity comes from:
  ///
  /// orders/{orderId}
  ///     items[itemIndex]
  ///         quantity
  ///
  /// NOT from packing.items
  /////////////////////////////////////////////////////////

  final orderRef = _firestore
      .collection("orders")
      .doc(orderId);

  final orderSnapshot =
      await orderRef.get();

  if (!orderSnapshot.exists) {
    throw Exception(
      "Original order not found.",
    );
  }

  final orderData =
      orderSnapshot.data() ?? {};

  final rawOrderItems =
      orderData["items"];

  if (rawOrderItems is! List ||
      itemIndex < 0 ||
      itemIndex >= rawOrderItems.length) {
    throw Exception(
      "Original order item not found.",
    );
  }

  final originalItem =
      rawOrderItems[itemIndex];

  /////////////////////////////////////////////////////////
  /// ORDERED QUANTITY
  /////////////////////////////////////////////////////////

  final int ordered =
      originalItem is Map
          ? int.tryParse(
                "${originalItem["quantity"] ?? 0}",
              ) ??
              0
          : 0;

  /////////////////////////////////////////////////////////
  /// SAVE ORDERED QUANTITY INTO PACKING ITEM
  ///
  /// This makes the packing document self-contained.
  /////////////////////////////////////////////////////////

  itemData["orderedQuantity"] =
      ordered;

  /////////////////////////////////////////////////////////
  /// RECEIVED QUANTITY
  /////////////////////////////////////////////////////////

  final int received =
      int.tryParse(
            "${itemData["receivedQuantity"] ?? 0}",
          ) ??
          0;

  /////////////////////////////////////////////////////////
  /// MISSING QUANTITY
  /////////////////////////////////////////////////////////

  final int missing =
      int.tryParse(
            "${itemData["missingQuantity"] ?? 0}",
          ) ??
          0;

  /////////////////////////////////////////////////////////
  /// VALIDATE QUANTITIES
  /////////////////////////////////////////////////////////

  if (received + missing != ordered) {
    throw Exception(
      "Cannot confirm. "
      "Received ($received) + Missing ($missing) "
      "must equal Ordered ($ordered).",
    );
  }

  /////////////////////////////////////////////////////////
  /// CONFIRM CURRENT ITEM
  /////////////////////////////////////////////////////////

  itemData["status"] =
      "confirmed";

  itemData["confirmedBy"] =
      adminId;

  itemData["confirmedAt"] =
      Timestamp.now();

  itemData["updatedBy"] =
      adminId;

  itemData["updatedAt"] =
      Timestamp.now();

  /////////////////////////////////////////////////////////
  /// SAVE CURRENT ITEM BACK TO ARRAY
  /////////////////////////////////////////////////////////

  packingItems[itemIndex] =
      itemData;

  /////////////////////////////////////////////////////////
  /// CALCULATE PACKING REPORT
  /////////////////////////////////////////////////////////

  int confirmedCount = 0;
  int pendingCount = 0;

  int totalOrdered = 0;
  int totalReceived = 0;
  int totalMissing = 0;

  for (
    int i = 0;
    i < packingItems.length;
    i++
  ) {
    final raw =
        packingItems[i];

    if (raw is! Map) {
      pendingCount++;
      continue;
    }

    final map =
        Map<String, dynamic>.from(
      raw,
    );

    ///////////////////////////////////////////////////////
    /// ORDERED QUANTITY FOR EACH ITEM
    ///
    /// Prefer saved orderedQuantity.
    /// If it doesn't exist, get it from original order.
    ///////////////////////////////////////////////////////

    int itemOrdered =
        int.tryParse(
              "${map["orderedQuantity"] ?? 0}",
            ) ??
            0;

    if (itemOrdered <= 0 &&
        i < rawOrderItems.length) {
      final original =
          rawOrderItems[i];

      if (original is Map) {
        itemOrdered =
            int.tryParse(
                  "${original["quantity"] ?? 0}",
                ) ??
                0;

        map["orderedQuantity"] =
            itemOrdered;

        packingItems[i] =
            map;
      }
    }

    ///////////////////////////////////////////////////////
    /// RECEIVED
    ///////////////////////////////////////////////////////

    final int itemReceived =
        int.tryParse(
              "${map["receivedQuantity"] ?? 0}",
            ) ??
            0;

    ///////////////////////////////////////////////////////
    /// MISSING
    ///////////////////////////////////////////////////////

    final int itemMissing =
        int.tryParse(
              "${map["missingQuantity"] ?? 0}",
            ) ??
            0;

    ///////////////////////////////////////////////////////
    /// TOTALS
    ///////////////////////////////////////////////////////

    totalOrdered +=
        itemOrdered;

    totalReceived +=
        itemReceived;

    totalMissing +=
        itemMissing;

    ///////////////////////////////////////////////////////
    /// STATUS
    ///////////////////////////////////////////////////////

    final status =
        "${map["status"] ?? ""}"
            .trim()
            .toLowerCase();

    if (status == "confirmed") {
      confirmedCount++;
    } else {
      pendingCount++;
    }
  }

  /////////////////////////////////////////////////////////
  /// CHECK WHETHER EVERYTHING IS CONFIRMED
  /////////////////////////////////////////////////////////

  final bool allConfirmed =
      packingItems.isNotEmpty &&
      pendingCount == 0;

  /////////////////////////////////////////////////////////
  /// UPDATE PACKING DATA
  /////////////////////////////////////////////////////////

  packingData["items"] =
      packingItems;

  packingData["totalItems"] =
      packingItems.length;

  packingData["totalOrderedQuantity"] =
      totalOrdered;

  packingData["totalReceivedQuantity"] =
      totalReceived;

  packingData["totalMissingQuantity"] =
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
  /// FINAL PACKING CONFIRMATION
  /////////////////////////////////////////////////////////

  if (allConfirmed) {
    packingData["confirmedBy"] =
        adminId;

    packingData["confirmedAt"] =
        FieldValue.serverTimestamp();
  }

  /////////////////////////////////////////////////////////
  /// SAVE TO FIRESTORE
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