import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/dashboard_stats_model.dart';

class DashboardStatsService {
  DashboardStatsService._();

  static final DashboardStatsService instance =
      DashboardStatsService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _stats =>
      _firestore
          .collection("dashboard")
          .doc("adminStats");

  ///////////////////////////////////////////////////////////
  /// Dashboard Stream
  ///////////////////////////////////////////////////////////

  Stream<DashboardStatsModel> statsStream() {
    return _stats.snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return const DashboardStatsModel();
      }

      return DashboardStatsModel.fromMap(
        snapshot.data(),
      );
    });
  }

  ///////////////////////////////////////////////////////////
  /// Current Dashboard
  ///////////////////////////////////////////////////////////

  Future<DashboardStatsModel> getStats() async {
    final doc = await _stats.get();

    if (!doc.exists) {
      return const DashboardStatsModel();
    }

    return DashboardStatsModel.fromMap(
      doc.data(),
    );
  }

  ///////////////////////////////////////////////////////////
  /// Create Dashboard Document
  ///////////////////////////////////////////////////////////

  Future<void> initializeDashboard() async {
    final doc = await _stats.get();

    if (doc.exists) return;

    await _stats.set(
      DashboardStatsModel(
        updatedAt: Timestamp.now(),
      ).toMap(),
    );
  }

  ///////////////////////////////////////////////////////////
  /// New Order
  ///////////////////////////////////////////////////////////

  Future<void> newOrderPlaced({
    required double amount,
  }) async {
    await _stats.set({
      "todayOrders": FieldValue.increment(1),
      "pendingOrders": FieldValue.increment(1),
      "todayRevenue": FieldValue.increment(amount),
      "monthlyRevenue": FieldValue.increment(amount),
      "totalRevenue": FieldValue.increment(amount),
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  ///////////////////////////////////////////////////////////
  /// Payment Requested
  ///////////////////////////////////////////////////////////

  Future<void> paymentRequested() async {
    await _stats.set({
      "paymentPending": FieldValue.increment(1),
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  ///////////////////////////////////////////////////////////
  /// Payment Verified
  ///////////////////////////////////////////////////////////

  Future<void> paymentVerified() async {
    await _stats.set({
      "paymentPending": FieldValue.increment(-1),
      "paymentVerified": FieldValue.increment(1),
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  ///////////////////////////////////////////////////////////
  /// Packing Started
  ///////////////////////////////////////////////////////////

  Future<void> packingStarted() async {
    await _stats.set({
      "pendingOrders": FieldValue.increment(-1),
      "packingOrders": FieldValue.increment(1),
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  ///////////////////////////////////////////////////////////
  /// Packing Completed
  ///////////////////////////////////////////////////////////

  Future<void> packingCompleted() async {
    await _stats.set({
      "packingOrders": FieldValue.increment(-1),
      "shippedOrders": FieldValue.increment(1),
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  ///////////////////////////////////////////////////////////
  /// Order Delivered
  ///////////////////////////////////////////////////////////

  Future<void> orderDelivered() async {
    await _stats.set({
      "shippedOrders": FieldValue.increment(-1),
      "deliveredOrders": FieldValue.increment(1),
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  ///////////////////////////////////////////////////////////
  /// Order Cancelled
  ///////////////////////////////////////////////////////////

  Future<void> orderCancelled({
    required double amount,
  }) async {
    await _stats.set({
      "pendingOrders": FieldValue.increment(-1),
      "cancelledOrders": FieldValue.increment(1),
      "todayRevenue": FieldValue.increment(-amount),
      "monthlyRevenue": FieldValue.increment(-amount),
      "totalRevenue": FieldValue.increment(-amount),
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  ///////////////////////////////////////////////////////////
  /// Customer Registered
  ///////////////////////////////////////////////////////////

  Future<void> customerRegistered() async {
    await _stats.set({
      "totalCustomers": FieldValue.increment(1),
      "newCustomersToday": FieldValue.increment(1),
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  ///////////////////////////////////////////////////////////
  /// Chat Received
  ///////////////////////////////////////////////////////////

  Future<void> newCustomerMessage() async {
    await _stats.set({
      "unreadChats": FieldValue.increment(1),
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  ///////////////////////////////////////////////////////////
  /// Chat Read
  ///////////////////////////////////////////////////////////

  Future<void> customerChatRead() async {
    await _stats.set({
      "unreadChats": FieldValue.increment(-1),
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  ///////////////////////////////////////////////////////////
  /// Low Stock
  ///////////////////////////////////////////////////////////

  Future<void> lowStockDetected() async {
    await _stats.set({
      "lowStockProducts": FieldValue.increment(1),
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  ///////////////////////////////////////////////////////////
  /// Out Of Stock
  ///////////////////////////////////////////////////////////

  Future<void> outOfStockDetected() async {
    await _stats.set({
      "outOfStockProducts": FieldValue.increment(1),
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  ///////////////////////////////////////////////////////////
  /// Admin Logged In
  ///////////////////////////////////////////////////////////

  Future<void> adminLoggedIn() async {
    await _stats.set({
      "activeAdmins": FieldValue.increment(1),
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  ///////////////////////////////////////////////////////////
  /// Admin Logged Out
  ///////////////////////////////////////////////////////////

  Future<void> adminLoggedOut() async {
    await _stats.set({
      "activeAdmins": FieldValue.increment(-1),
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}