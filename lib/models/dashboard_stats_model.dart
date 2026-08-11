import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardStatsModel {
  /// Orders
  final int todayOrders;
  final int pendingOrders;
  final int confirmedOrders;
  final int packingOrders;
  final int shippedOrders;
  final int deliveredOrders;
  final int cancelledOrders;

  /// Payments
  final int paymentPending;
  final int paymentVerified;

  /// Chats
  final int unreadChats;

  /// Products
  final int lowStockProducts;
  final int outOfStockProducts;

  /// Customers
  final int totalCustomers;
  final int newCustomersToday;

  /// Revenue
  final double todayRevenue;
  final double monthlyRevenue;
  final double totalRevenue;

  /// Staff
  final int activeAdmins;

  /// Timestamp
  final Timestamp? updatedAt;

  const DashboardStatsModel({
    this.todayOrders = 0,
    this.pendingOrders = 0,
    this.confirmedOrders = 0,
    this.packingOrders = 0,
    this.shippedOrders = 0,
    this.deliveredOrders = 0,
    this.cancelledOrders = 0,

    this.paymentPending = 0,
    this.paymentVerified = 0,

    this.unreadChats = 0,

    this.lowStockProducts = 0,
    this.outOfStockProducts = 0,

    this.totalCustomers = 0,
    this.newCustomersToday = 0,

    this.todayRevenue = 0,
    this.monthlyRevenue = 0,
    this.totalRevenue = 0,

    this.activeAdmins = 0,

    this.updatedAt,
  });

  factory DashboardStatsModel.fromMap(
    Map<String, dynamic>? map,
  ) {
    map ??= {};

    return DashboardStatsModel(
      todayOrders: map["todayOrders"] ?? 0,
      pendingOrders: map["pendingOrders"] ?? 0,
      confirmedOrders: map["confirmedOrders"] ?? 0,
      packingOrders: map["packingOrders"] ?? 0,
      shippedOrders: map["shippedOrders"] ?? 0,
      deliveredOrders: map["deliveredOrders"] ?? 0,
      cancelledOrders: map["cancelledOrders"] ?? 0,

      paymentPending: map["paymentPending"] ?? 0,
      paymentVerified: map["paymentVerified"] ?? 0,

      unreadChats: map["unreadChats"] ?? 0,

      lowStockProducts: map["lowStockProducts"] ?? 0,
      outOfStockProducts: map["outOfStockProducts"] ?? 0,

      totalCustomers: map["totalCustomers"] ?? 0,
      newCustomersToday: map["newCustomersToday"] ?? 0,

      todayRevenue:
          (map["todayRevenue"] ?? 0).toDouble(),

      monthlyRevenue:
          (map["monthlyRevenue"] ?? 0).toDouble(),

      totalRevenue:
          (map["totalRevenue"] ?? 0).toDouble(),

      activeAdmins: map["activeAdmins"] ?? 0,

      updatedAt: map["updatedAt"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "todayOrders": todayOrders,
      "pendingOrders": pendingOrders,
      "confirmedOrders": confirmedOrders,
      "packingOrders": packingOrders,
      "shippedOrders": shippedOrders,
      "deliveredOrders": deliveredOrders,
      "cancelledOrders": cancelledOrders,

      "paymentPending": paymentPending,
      "paymentVerified": paymentVerified,

      "unreadChats": unreadChats,

      "lowStockProducts": lowStockProducts,
      "outOfStockProducts": outOfStockProducts,

      "totalCustomers": totalCustomers,
      "newCustomersToday": newCustomersToday,

      "todayRevenue": todayRevenue,
      "monthlyRevenue": monthlyRevenue,
      "totalRevenue": totalRevenue,

      "activeAdmins": activeAdmins,

      "updatedAt": updatedAt,
    };
  }
}