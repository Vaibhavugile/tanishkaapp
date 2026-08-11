import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'last_message_widget.dart';
import 'order_status_chip.dart';
import 'payment_status_chip.dart';
import 'unread_badge.dart';

class OrderCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>>
      order;

  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  Map<String, dynamic> get data =>
      order.data();

  String get customerName =>
      data["customerName"] ?? "-";

  String get customerPhone =>
      data["customerPhone"] ?? "-";

  String get orderId =>
      data["orderId"] ?? "";

  String get orderStatus =>
      data["orderStatus"] ?? "Placed";

  String get paymentStatus =>
      data["paymentStatus"] ?? "Pending";

  String get lastMessage =>
      data["lastMessage"] ?? "";

  String get lastSenderType =>
      data["lastSenderType"] ??
      data["senderType"] ??
      "system";

  String get lastMessageType =>
      data["lastMessageType"] ??
      "text";

  int get unreadAdmin =>
      data["unreadAdmin"] ?? 0;

  Timestamp? get lastMessageTime =>
      data["lastMessageTime"];

  String get orderSource =>
      data["orderSource"] ?? "";

  String get formattedTime {
    if (lastMessageTime == null) {
      return "";
    }

    return DateFormat(
      "dd MMM • hh:mm a",
    ).format(
      lastMessageTime!.toDate(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(22),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
                        //////////////////////////////////////////////////////////
            /// HEADER
            //////////////////////////////////////////////////////////

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      const Color(0xffF5F5F5),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xffE91E63),
                    size: 26,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.w700,
                          color:
                              Color(0xff222222),
                        ),
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            size: 14,
                            color: Colors.grey,
                          ),

                          const SizedBox(width: 4),

                          Expanded(
                            child: Text(
                              customerPhone,
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xffE8F5E9,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      30,
                    ),
                  ),
                  child: Text(
                    orderSource,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight:
                          FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                ),
              ],
            ),

            const SizedBox(height: 16),

            //////////////////////////////////////////////////////////
            /// LAST MESSAGE
            //////////////////////////////////////////////////////////

            LastMessageWidget(
              message: lastMessage,
              senderType: lastSenderType,
              messageType: lastMessageType,
            ),

            const SizedBox(height: 14),
                        //////////////////////////////////////////////////////////
            /// STATUS ROW
            //////////////////////////////////////////////////////////

            Row(
              children: [
                Expanded(
                  child: OrderStatusChip(
                    status: orderStatus,
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: PaymentStatusChip(
                    status: paymentStatus,
                  ),
                ),

                const SizedBox(width: 8),

                UnreadBadge(
                  count: unreadAdmin,
                ),
              ],
            ),

            const SizedBox(height: 14),

            //////////////////////////////////////////////////////////
            /// FOOTER
            //////////////////////////////////////////////////////////

            Row(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 15,
                  color: Colors.grey.shade600,
                ),

                const SizedBox(width: 6),

                Expanded(
                  child: Text(
                    "#$orderId",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                if (formattedTime.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        formattedTime,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}