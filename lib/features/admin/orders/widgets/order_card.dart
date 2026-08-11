import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> order;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  ///////////////////////////////////////////////////////////
  /// BUILD
  ///////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    final data = order.data();

    ///////////////////////////////////////////////////////////
    /// DATA
    ///////////////////////////////////////////////////////////

    final customerName =
        (data["customerName"] ?? "Unknown Customer")
            .toString()
            .trim();

    final customerPhone =
        (data["customerPhone"] ?? "")
            .toString()
            .trim();

    final orderId =
        (data["orderId"] ?? order.id)
            .toString()
            .trim();

    final lastMessage =
        (data["lastMessage"] ?? "")
            .toString()
            .trim();

    final lastMessageType =
        (data["lastMessageType"] ?? "text")
            .toString()
            .trim();

    final orderStatus =
        (data["orderStatus"] ?? "Unknown")
            .toString()
            .trim();

    final paymentStatus =
        (data["paymentStatus"] ?? "Unknown")
            .toString()
            .trim();

    final orderSource =
        (data["orderSource"] ?? "")
            .toString()
            .trim();

    final unreadAdmin =
        _toInt(data["unreadAdmin"]);

    final lastMessageTime =
        _timestamp(data["lastMessageTime"]);

    ///////////////////////////////////////////////////////////
    /// CARD
    ///////////////////////////////////////////////////////////

    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        borderRadius:
            BorderRadius.circular(28),

        splashColor:
            const Color(0xffE91E63)
                .withOpacity(.05),

        highlightColor:
            const Color(0xffE91E63)
                .withOpacity(.025),

        child: Container(
          padding:
              const EdgeInsets.all(18),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius:
                BorderRadius.circular(28),

            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(.055),
                blurRadius: 28,
                spreadRadius: 1,
                offset:
                    const Offset(0, 14),
              ),

              if (unreadAdmin > 0)
                BoxShadow(
                  color:
                      const Color(0xffE91E63)
                          .withOpacity(.08),
                  blurRadius: 22,
                  spreadRadius: 1,
                ),
            ],
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              ///////////////////////////////////////////////////
              /// TOP SECTION
              ///////////////////////////////////////////////////

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  ///////////////////////////////////////////////////
                  /// CUSTOMER AVATAR
                  ///////////////////////////////////////////////////

                  Container(
                    width: 62,
                    height: 62,

                    decoration:
                        BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(20),

                      gradient:
                          const LinearGradient(
                        colors: [
                          Color(0xffFFCCE1),
                          Color(0xffE91E63),
                        ],

                        begin:
                            Alignment.topLeft,

                        end:
                            Alignment.bottomRight,
                      ),

                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(
                            0xffE91E63,
                          ).withOpacity(.16),

                          blurRadius: 16,

                          offset:
                              const Offset(0, 7),
                        ),
                      ],
                    ),

                    child:
                        const Icon(
                      Icons
                          .shopping_bag_rounded,

                      color:
                          Colors.white,

                      size: 30,
                    ),
                  ),

                  const SizedBox(
                    width: 15,
                  ),

                  ///////////////////////////////////////////////////
                  /// CUSTOMER DETAILS
                  ///////////////////////////////////////////////////

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        ///////////////////////////////////////////////////
                        /// CUSTOMER NAME + UNREAD
                        ///////////////////////////////////////////////////

                        Row(
                          children: [

                            Expanded(
                              child: Text(
                                customerName.isEmpty
                                    ? "Unknown Customer"
                                    : customerName,

                                maxLines: 1,

                                overflow:
                                    TextOverflow.ellipsis,

                                style:
                                    const TextStyle(
                                  fontSize: 17,

                                  fontWeight:
                                      FontWeight.w800,

                                  color:
                                      Color(0xff44212E),
                                ),
                              ),
                            ),

                            if (unreadAdmin > 0) ...[
                              const SizedBox(
                                width: 8,
                              ),

                              _UnreadBadge(
                                count:
                                    unreadAdmin,
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(
                          height: 5,
                        ),

                        ///////////////////////////////////////////////////
                        /// ORDER ID
                        ///////////////////////////////////////////////////

                        Text(
                          orderId,

                          maxLines: 1,

                          overflow:
                              TextOverflow.ellipsis,

                          style:
                              const TextStyle(
                            fontSize: 11,

                            color:
                                Color(0xff9B7B85),

                            fontWeight:
                                FontWeight.w700,

                            letterSpacing:
                                .2,
                          ),
                        ),

                        ///////////////////////////////////////////////////
                        /// PHONE
                        ///////////////////////////////////////////////////

                        if (customerPhone.isNotEmpty) ...[
                          const SizedBox(
                            height: 3,
                          ),

                          Text(
                            customerPhone,

                            maxLines: 1,

                            overflow:
                                TextOverflow.ellipsis,

                            style:
                                const TextStyle(
                              fontSize: 10,

                              color:
                                  Color(0xffB09AA3),

                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  ///////////////////////////////////////////////////
                  /// CHEVRON
                  ///////////////////////////////////////////////////

                  Container(
                    width: 32,
                    height: 32,

                    decoration:
                        BoxDecoration(
                      color:
                          const Color(0xffFFF3F7),

                      borderRadius:
                          BorderRadius.circular(11),
                    ),

                    child:
                        const Icon(
                      Icons
                          .chevron_right_rounded,

                      color:
                          Color(0xffC48BA3),

                      size: 20,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 16,
              ),

              ///////////////////////////////////////////////////
              /// LAST MESSAGE
              ///////////////////////////////////////////////////

              Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      const Color(0xffFCF8FA),

                  borderRadius:
                      BorderRadius.circular(17),

                  border:
                      Border.all(
                    color:
                        const Color(
                      0xffF4E9EE,
                    ),
                  ),
                ),

                child: Row(
                  children: [

                    ///////////////////////////////////////////////////
                    /// MESSAGE ICON
                    ///////////////////////////////////////////////////

                    Container(
                      width: 32,
                      height: 32,

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xffFFE8F2,
                        ),

                        borderRadius:
                            BorderRadius.circular(11),
                      ),

                      child:
                          _messageTypeIcon(
                        lastMessageType,
                      ),
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    ///////////////////////////////////////////////////
                    /// MESSAGE
                    ///////////////////////////////////////////////////

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Text(
                            _messageTypeTitle(
                              lastMessageType,
                            ),

                            style:
                                const TextStyle(
                              color:
                                  Color(0xffB08A99),

                              fontSize: 9,

                              fontWeight:
                                  FontWeight.w800,

                              letterSpacing:
                                  .4,
                            ),
                          ),

                          const SizedBox(
                            height: 2,
                          ),

                          Text(
                            _messagePreview(
                              lastMessage,
                              lastMessageType,
                            ),

                            maxLines: 1,

                            overflow:
                                TextOverflow.ellipsis,

                            style:
                                TextStyle(
                              color:
                                  const Color(
                                0xff5F4C55,
                              ),

                              fontSize: 12,

                              fontWeight:
                                  unreadAdmin > 0
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    ///////////////////////////////////////////////////
                    /// TIME
                    ///////////////////////////////////////////////////

                    if (lastMessageTime != null)
                      Padding(
                        padding:
                            const EdgeInsets.only(
                          left: 8,
                        ),

                        child: Text(
                          _formatTime(
                            lastMessageTime,
                          ),

                          style:
                              const TextStyle(
                            color:
                                Color(0xffA9949D),

                            fontSize: 9,

                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              ///////////////////////////////////////////////////
              /// STATUS + PAYMENT
              ///////////////////////////////////////////////////

              Row(
                children: [

                  ///////////////////////////////////////////////////
                  /// ORDER STATUS
                  ///////////////////////////////////////////////////

                  Flexible(
                    child:
                        _statusChip(
                      label:
                          orderStatus,

                      type:
                          _StatusType.order,
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  ///////////////////////////////////////////////////
                  /// PAYMENT
                  ///////////////////////////////////////////////////

                  Flexible(
                    child:
                        _statusChip(
                      label:
                          paymentStatus,

                      type:
                          _StatusType.payment,
                    ),
                  ),

                  const Spacer(),

                  ///////////////////////////////////////////////////
                  /// APP SOURCE
                  ///////////////////////////////////////////////////

                  if (orderSource
                      .isNotEmpty)
                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xffF8F3F6,
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),

                      child: Row(
                        mainAxisSize:
                            MainAxisSize.min,

                        children: [

                          const Icon(
                            Icons
                                .phone_iphone_rounded,

                            size: 12,

                            color:
                                Color(0xff8D6877),
                          ),

                          const SizedBox(
                            width: 4,
                          ),

                          Text(
                            "APP",

                            style:
                                const TextStyle(
                              color:
                                  Color(0xff8D6877),

                              fontSize: 9,

                              fontWeight:
                                  FontWeight.w800,

                              letterSpacing:
                                  .5,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// MESSAGE TYPE ICON
  ///////////////////////////////////////////////////////////

  Widget _messageTypeIcon(
    String type,
  ) {
    IconData icon;

    switch (type.toLowerCase()) {
      case "image":
        icon =
            Icons.image_outlined;
        break;

      case "order":
        icon =
            Icons.shopping_bag_outlined;
        break;

      case "payment":
        icon =
            Icons.payments_outlined;
        break;

      case "tracking":
        icon =
            Icons.local_shipping_outlined;
        break;

      case "invoice":
        icon =
            Icons.receipt_long_outlined;
        break;

      case "status":
        icon =
            Icons.sync_alt_rounded;
        break;

      default:
        icon =
            Icons.chat_bubble_outline_rounded;
    }

    return Icon(
      icon,
      size: 16,
      color:
          const Color(0xffE91E63),
    );
  }

  ///////////////////////////////////////////////////////////
  /// MESSAGE TYPE TITLE
  ///////////////////////////////////////////////////////////

  String _messageTypeTitle(
    String type,
  ) {
    switch (type.toLowerCase()) {
      case "image":
        return "IMAGE";

      case "order":
        return "ORDER UPDATE";

      case "payment":
        return "PAYMENT UPDATE";

      case "tracking":
        return "TRACKING";

      case "invoice":
        return "INVOICE";

      case "status":
        return "STATUS UPDATE";

      default:
        return "LAST MESSAGE";
    }
  }

  ///////////////////////////////////////////////////////////
  /// MESSAGE PREVIEW
  ///////////////////////////////////////////////////////////

  String _messagePreview(
    String message,
    String type,
  ) {
    if (message.trim().isNotEmpty) {
      return message.trim();
    }

    switch (type.toLowerCase()) {
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

  ///////////////////////////////////////////////////////////
  /// STATUS CHIP
  ///////////////////////////////////////////////////////////

  Widget _statusChip({
    required String label,
    required _StatusType type,
  }) {
    final normalized =
        label.trim().toLowerCase();

    Color background;
    Color foreground;
    IconData icon;

    if (type ==
        _StatusType.payment) {
      if (normalized.contains("paid") ||
          normalized.contains("verified") ||
          normalized.contains("complete")) {
        background =
            const Color(0xffE8F5E9);

        foreground =
            const Color(0xff2E7D32);

        icon =
            Icons.check_circle_outline_rounded;
      } else {
        background =
            const Color(0xfffff3e0);

        foreground =
            const Color(0xffEF6C00);

        icon =
            Icons.schedule_rounded;
      }
    } else {
      if (normalized.contains("cancel")) {
        background =
            const Color(0xffffebee);

        foreground =
            const Color(0xffC62828);

        icon =
            Icons.cancel_outlined;
      } else if (normalized.contains("deliver")) {
        background =
            const Color(0xffE8F5E9);

        foreground =
            const Color(0xff2E7D32);

        icon =
            Icons.check_circle_outline_rounded;
      } else if (normalized.contains("ship")) {
        background =
            const Color(0xffE3F2FD);

        foreground =
            const Color(0xff1565C0);

        icon =
            Icons.local_shipping_outlined;
      } else if (normalized.contains("pack")) {
        background =
            const Color(0xffF3E5F5);

        foreground =
            const Color(0xff7B1FA2);

        icon =
            Icons.inventory_2_outlined;
      } else {
        background =
            const Color(0xfffff3e0);

        foreground =
            const Color(0xffEF6C00);

        icon =
            Icons.pending_actions_rounded;
      }
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),

      decoration:
          BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(30),
      ),

      child: Row(
        mainAxisSize:
            MainAxisSize.min,

        children: [

          Icon(
            icon,
            size: 12,
            color: foreground,
          ),

          const SizedBox(
            width: 4,
          ),

          Flexible(
            child: Text(
              label.isEmpty
                  ? "Unknown"
                  : label,

              maxLines: 1,

              overflow:
                  TextOverflow.ellipsis,

              style:
                  TextStyle(
                color: foreground,

                fontSize: 10,

                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// TIMESTAMP
  ///////////////////////////////////////////////////////////

  Timestamp? _timestamp(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value;
    }

    return null;
  }

  ///////////////////////////////////////////////////////////
  /// INTEGER
  ///////////////////////////////////////////////////////////

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

  ///////////////////////////////////////////////////////////
  /// FORMAT TIME
  ///////////////////////////////////////////////////////////

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
        date.year ==
            yesterday.year &&
        date.month ==
            yesterday.month &&
        date.day ==
            yesterday.day;

    if (isYesterday) {
      return "Yesterday";
    }

    return "${date.day}/${date.month}/${date.year}";
  }
}

///////////////////////////////////////////////////////////////
/// UNREAD BADGE
///////////////////////////////////////////////////////////////

class _UnreadBadge
    extends StatelessWidget {
  final int count;

  const _UnreadBadge({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          const BoxConstraints(
        minWidth: 24,
      ),

      height: 24,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 7,
      ),

      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            Color(0xffE91E63),
            Color(0xffC2185B),
          ],
        ),

        borderRadius:
            BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color:
                const Color(0xffE91E63)
                    .withOpacity(.22),
            blurRadius: 10,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),

      alignment:
          Alignment.center,

      child: Text(
        count > 99
            ? "99+"
            : "$count",

        style:
            const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight:
              FontWeight.w800,
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////
/// STATUS TYPE
///////////////////////////////////////////////////////////////

enum _StatusType {
  order,
  payment,
}