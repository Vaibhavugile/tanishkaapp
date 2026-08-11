import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../orders/services/admin_order_service.dart';

import '../orders/screens/admin_order_chat_screen.dart';

import 'dashboard_card.dart';

class RecentOrdersWidget extends StatelessWidget {
  final VoidCallback? onViewAll;

  const RecentOrdersWidget({
    super.key,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        ///////////////////////////////////////////////////////
        /// HEADER
        ///////////////////////////////////////////////////////

        Padding(
          padding: const EdgeInsets.only(
            left: 4,
            bottom: 16,
          ),
          child: Row(
            children: [

              const Expanded(
                child: Text(
                  "Recent Orders",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(0xff241B2F),
                  ),
                ),
              ),

              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                  child: const Text(
                    "View All",
                    style: TextStyle(
                      color:
                          Color(0xffE91E63),
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
        ),

        ///////////////////////////////////////////////////////
        /// REALTIME ORDER STREAM
        ///////////////////////////////////////////////////////

        StreamBuilder<
            QuerySnapshot<
                Map<String, dynamic>>>(
          stream:
              AdminOrderService.instance
                  .latestOrderChats(),

          builder: (
            context,
            snapshot,
          ) {
            ///////////////////////////////////////////////////
            /// LOADING
            ///////////////////////////////////////////////////

            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return Column(
                children: List.generate(
                  3,
                  (index) {
                    return Padding(
                      padding:
                          EdgeInsets.only(
                        bottom:
                            index == 2
                                ? 0
                                : 14,
                      ),
                      child:
                          const _LoadingOrderTile(),
                    );
                  },
                ),
              );
            }

            ///////////////////////////////////////////////////
            /// ERROR
            ///////////////////////////////////////////////////

            if (snapshot.hasError) {
              return _ErrorState(
                message:
                    "Unable to load recent orders.",
              );
            }

            ///////////////////////////////////////////////////
            /// DOCUMENTS
            ///////////////////////////////////////////////////

            final docs =
                snapshot.data?.docs ?? [];

            ///////////////////////////////////////////////////
            /// EMPTY
            ///////////////////////////////////////////////////

            if (docs.isEmpty) {
              return const _EmptyOrdersState();
            }

            ///////////////////////////////////////////////////
            /// SHOW ONLY TOP 5 ON DASHBOARD
            ///
            /// AdminOrderService itself listens to only
            /// latest 25.
            ///////////////////////////////////////////////////

            final recentOrders =
                docs.take(5).toList();

            return ListView.separated(
              shrinkWrap: true,

              physics:
                  const NeverScrollableScrollPhysics(),

              itemCount:
                  recentOrders.length,

              separatorBuilder:
                  (_, __) =>
                      const SizedBox(
                height: 14,
              ),

              itemBuilder: (
                context,
                index,
              ) {
                final order =
                    recentOrders[index];

                return _RecentOrderTile(
                  order: order,
                );
              },
            );
          },
        ),
      ],
    );
  }
}

///////////////////////////////////////////////////////////////
/// RECENT ORDER TILE
///////////////////////////////////////////////////////////////

class _RecentOrderTile
    extends StatelessWidget {
  final QueryDocumentSnapshot<
      Map<String, dynamic>> order;

  const _RecentOrderTile({
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final data = order.data();

    ///////////////////////////////////////////////////////////
    /// DATA
    ///////////////////////////////////////////////////////////

    final customerName =
        (data["customerName"] ??
                "Unknown Customer")
            .toString();

    final orderId =
        (data["orderId"] ?? order.id)
            .toString();

    final lastMessage =
        (data["lastMessage"] ?? "")
            .toString();

    final lastMessageType =
        (data["lastMessageType"] ??
                "text")
            .toString();

    final orderStatus =
        (data["orderStatus"] ??
                "Unknown")
            .toString();

    final paymentStatus =
        (data["paymentStatus"] ??
                "Unknown")
            .toString();

    final unreadAdmin =
        _toInt(
      data["unreadAdmin"],
    );

    final lastMessageTime =
        _getTimestamp(
      data["lastMessageTime"],
    );

    ///////////////////////////////////////////////////////////
    /// OPEN CHAT
    ///////////////////////////////////////////////////////////

    void openChat() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AdminOrderChatScreen(
            orderId: orderId,
          ),
        ),
      );
    }

    return DashboardCard(
      onTap: openChat,

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [

          /////////////////////////////////////////////////////
          /// CUSTOMER ICON
          /////////////////////////////////////////////////////

          Container(
            width: 58,
            height: 58,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xffFCE4EC,
              ),
              borderRadius:
                  BorderRadius.circular(
                17,
              ),
            ),
            child: const Icon(
              Icons.person_outline,
              size: 28,
              color:
                  Color(0xffE91E63),
            ),
          ),

          const SizedBox(
            width: 14,
          ),

          /////////////////////////////////////////////////////
          /// DETAILS
          /////////////////////////////////////////////////////

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                //////////////////////////////////////////////////
                /// CUSTOMER + UNREAD
                //////////////////////////////////////////////////

                Row(
                  children: [

                    Expanded(
                      child: Text(
                        customerName,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.w800,
                          fontSize: 15,
                          color:
                              Color(
                            0xff241B2F,
                          ),
                        ),
                      ),
                    ),

                    if (unreadAdmin > 0)
                      Container(
                        constraints:
                            const BoxConstraints(
                          minWidth: 21,
                        ),
                        height: 21,
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 6,
                        ),
                        alignment:
                            Alignment.center,
                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xffE91E63,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),
                        child: Text(
                          unreadAdmin > 99
                              ? "99+"
                              : "$unreadAdmin",
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize: 9,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(
                  height: 3,
                ),

                //////////////////////////////////////////////////
                /// ORDER ID
                //////////////////////////////////////////////////

                Text(
                  "#$orderId",
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    color:
                        Colors.grey.shade500,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                //////////////////////////////////////////////////
                /// LAST MESSAGE
                //////////////////////////////////////////////////

                Row(
                  children: [

                    Icon(
                      _messageIcon(
                        lastMessageType,
                      ),
                      size: 14,
                      color:
                          const Color(
                        0xffE91E63,
                      ),
                    ),

                    const SizedBox(
                      width: 5,
                    ),

                    Expanded(
                      child: Text(
                        _messagePreview(
                          lastMessage,
                          lastMessageType,
                        ),
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                              Colors.grey
                                  .shade700,
                          fontSize: 11,
                          fontWeight:
                              unreadAdmin > 0
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 9,
                ),

                //////////////////////////////////////////////////
                /// STATUS
                //////////////////////////////////////////////////

                Row(
                  children: [

                    _statusChip(
                      orderStatus,
                      isPayment: false,
                    ),

                    const SizedBox(
                      width: 6,
                    ),

                    _statusChip(
                      paymentStatus,
                      isPayment: true,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          /////////////////////////////////////////////////////
          /// RIGHT SIDE
          /////////////////////////////////////////////////////

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [

              //////////////////////////////////////////////////
              /// TIME
              //////////////////////////////////////////////////

              if (lastMessageTime != null)
                Text(
                  _formatTime(
                    lastMessageTime,
                  ),
                  style: TextStyle(
                    color:
                        Colors.grey.shade500,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

              const SizedBox(
                height: 10,
              ),

              //////////////////////////////////////////////////
              /// ARROW
              //////////////////////////////////////////////////

              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color:
                    Color(0xffE91E63),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////////
/// STATUS CHIP
///////////////////////////////////////////////////////////////

Widget _statusChip(
  String value, {
  required bool isPayment,
}) {
  final status =
      value.trim().toLowerCase();

  Color background;
  Color foreground;

  if (isPayment) {
    if (status.contains("paid") ||
        status.contains("verified") ||
        status.contains("complete")) {
      background =
          const Color(0xffE8F5E9);
      foreground =
          const Color(0xff2E7D32);
    } else {
      background =
          const Color(0xfffff3e0);
      foreground =
          const Color(0xffEF6C00);
    }
  } else {
    if (status.contains("cancel")) {
      background =
          const Color(0xffffebee);
      foreground =
          const Color(0xffC62828);
    } else if (status.contains("deliver")) {
      background =
          const Color(0xffE8F5E9);
      foreground =
          const Color(0xff2E7D32);
    } else if (status.contains("ship")) {
      background =
          const Color(0xffE3F2FD);
      foreground =
          const Color(0xff1565C0);
    } else if (status.contains("pack")) {
      background =
          const Color(0xffF3E5F5);
      foreground =
          const Color(0xff7B1FA2);
    } else {
      background =
          const Color(0xfffff3e0);
      foreground =
          const Color(0xffEF6C00);
    }
  }

  return Container(
    padding:
        const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 4,
    ),
    decoration:
        BoxDecoration(
      color: background,
      borderRadius:
          BorderRadius.circular(20),
    ),
    child: Text(
      value.isEmpty
          ? "Unknown"
          : value,
      maxLines: 1,
      overflow:
          TextOverflow.ellipsis,
      style: TextStyle(
        color: foreground,
        fontSize: 9,
        fontWeight:
            FontWeight.w800,
      ),
    ),
  );
}

///////////////////////////////////////////////////////////////
/// MESSAGE ICON
///////////////////////////////////////////////////////////////

IconData _messageIcon(
  String type,
) {
  switch (type) {
    case "image":
      return Icons.image_outlined;

    case "order":
      return Icons.shopping_bag_outlined;

    case "payment":
      return Icons.payments_outlined;

    case "tracking":
      return Icons.local_shipping_outlined;

    case "invoice":
      return Icons.receipt_long_outlined;

    case "status":
      return Icons.sync_alt;

    default:
      return Icons.chat_bubble_outline;
  }
}

///////////////////////////////////////////////////////////////
/// MESSAGE PREVIEW
///////////////////////////////////////////////////////////////

String _messagePreview(
  String message,
  String type,
) {
  if (message.trim().isNotEmpty) {
    return message.trim();
  }

  switch (type) {
    case "image":
      return "Image";

    case "order":
      return "Order update";

    case "payment":
      return "Payment update";

    case "tracking":
      return "Tracking update";

    case "invoice":
      return "Invoice";

    case "status":
      return "Order status update";

    default:
      return "No messages yet";
  }
}

///////////////////////////////////////////////////////////////
/// TIMESTAMP
///////////////////////////////////////////////////////////////

Timestamp? _getTimestamp(
  dynamic value,
) {
  if (value is Timestamp) {
    return value;
  }

  return null;
}

///////////////////////////////////////////////////////////////
/// INTEGER
///////////////////////////////////////////////////////////////

int _toInt(
  dynamic value,
) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(
        value?.toString() ?? "",
      ) ??
      0;
}

///////////////////////////////////////////////////////////////
/// FORMAT TIME
///////////////////////////////////////////////////////////////

String _formatTime(
  Timestamp timestamp,
) {
  final date =
      timestamp.toDate();

  final now =
      DateTime.now();

  final sameDay =
      date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;

  if (sameDay) {
    final hour =
        date.hour == 0
            ? 12
            : date.hour > 12
                ? date.hour - 12
                : date.hour;

    final minute =
        date.minute
            .toString()
            .padLeft(2, "0");

    final suffix =
        date.hour >= 12
            ? "PM"
            : "AM";

    return "$hour:$minute $suffix";
  }

  final yesterday =
      DateTime(
    now.year,
    now.month,
    now.day - 1,
  );

  final isYesterday =
      date.year == yesterday.year &&
      date.month == yesterday.month &&
      date.day == yesterday.day;

  if (isYesterday) {
    return "Yesterday";
  }

  return "${date.day}/${date.month}/${date.year}";
}

///////////////////////////////////////////////////////////////
/// LOADING TILE
///////////////////////////////////////////////////////////////

class _LoadingOrderTile
    extends StatelessWidget {
  const _LoadingOrderTile();

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Row(
        children: [

          Container(
            width: 58,
            height: 58,
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xffF4F1F3,
              ),
              borderRadius:
                  BorderRadius.circular(
                17,
              ),
            ),
          ),

          const SizedBox(
            width: 14,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Container(
                  height: 14,
                  width: 130,
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xffF0EDF0,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      6,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 9,
                ),

                Container(
                  height: 10,
                  width: 90,
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xffF0EDF0,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      6,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 9,
                ),

                Container(
                  height: 10,
                  width: 160,
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xffF0EDF0,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////////
/// EMPTY STATE
///////////////////////////////////////////////////////////////

class _EmptyOrdersState
    extends StatelessWidget {
  const _EmptyOrdersState();

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 24,
        ),
        child: Center(
          child: Column(
            children: [

              Container(
                width: 58,
                height: 58,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xffFCE4EC,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),
                child: const Icon(
                  Icons
                      .shopping_bag_outlined,
                  color:
                      Color(0xffE91E63),
                  size: 28,
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              const Text(
                "No recent orders",
                style: TextStyle(
                  color:
                      Color(0xff241B2F),
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: 4,
              ),

              Text(
                "Flutter App orders will appear here.",
                style: TextStyle(
                  color:
                      Colors.grey.shade600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////
/// ERROR STATE
///////////////////////////////////////////////////////////////

class _ErrorState
    extends StatelessWidget {
  final String message;

  const _ErrorState({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Row(
          children: [

            const Icon(
              Icons.error_outline,
              color:
                  Color(0xffE91E63),
              size: 28,
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color:
                      Colors.grey.shade700,
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}