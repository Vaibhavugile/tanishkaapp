import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:tanishka/models/chat_message_model.dart';
import '../services/admin_profile_service.dart';

class AdminMessageBubble extends StatefulWidget {
  final ChatMessageModel message;

  const AdminMessageBubble({
    super.key,
    required this.message,
  });

  @override
  State<AdminMessageBubble> createState() =>
      _AdminMessageBubbleState();
}

class _AdminMessageBubbleState
    extends State<AdminMessageBubble> {

  String? _adminName;

  ///////////////////////////////////////////////////////////
  /// INIT
  ///////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();

    if (widget.message.isAdmin) {
      _loadAdminName();
    }
  }

  ///////////////////////////////////////////////////////////
  /// LOAD ADMIN NAME
  ///////////////////////////////////////////////////////////

  Future<void> _loadAdminName() async {
    final name =
        await AdminProfileService.instance
            .getAdminName(
      widget.message.senderId,
    );

    if (!mounted) return;

    setState(() {
      _adminName = name;
    });
  }

  ///////////////////////////////////////////////////////////
  /// BUILD
  ///////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    final message = widget.message;

    /////////////////////////////////////////////////////////
    /// SYSTEM
    /////////////////////////////////////////////////////////

    if (message.isSystem) {
      return _buildSystemMessage();
    }

    final bool isAdmin =
        message.isAdmin;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 5,
      ),
      child: Row(
        mainAxisAlignment: isAdmin
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment:
            CrossAxisAlignment.end,
        children: [

          /////////////////////////////////////////////////////
          /// CUSTOMER AVATAR
          /////////////////////////////////////////////////////

          if (!isAdmin) ...[
            _avatar(
              isAdmin: false,
            ),

            const SizedBox(width: 8),
          ],

          /////////////////////////////////////////////////////
          /// MESSAGE
          /////////////////////////////////////////////////////

          Flexible(
            child: _buildBubble(
              isAdmin: isAdmin,
            ),
          ),

          /////////////////////////////////////////////////////
          /// ADMIN AVATAR
          /////////////////////////////////////////////////////

          if (isAdmin) ...[
            const SizedBox(width: 8),

            _avatar(
              isAdmin: true,
            ),
          ],
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// MESSAGE BUBBLE
  ///////////////////////////////////////////////////////////

  Widget _buildBubble({
    required bool isAdmin,
  }) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 320,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: isAdmin
            ? const Color(0xffE91E63)
            : Colors.white,
        borderRadius:
            BorderRadius.only(
          topLeft:
              const Radius.circular(18),

          topRight:
              const Radius.circular(18),

          bottomLeft:
              Radius.circular(
            isAdmin ? 18 : 4,
          ),

          bottomRight:
              Radius.circular(
            isAdmin ? 4 : 18,
          ),
        ),
        boxShadow: [
          if (!isAdmin)
            BoxShadow(
              color:
                  Colors.black.withOpacity(.04),
              blurRadius: 8,
              offset:
                  const Offset(0, 3),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: isAdmin
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [

          ///////////////////////////////////////////////////
          /// SENDER NAME
          ///////////////////////////////////////////////////

          if (isAdmin)
            _buildAdminName(),

          if (!isAdmin)
            _buildCustomerName(),

          const SizedBox(height: 4),

          ///////////////////////////////////////////////////
          /// CONTENT
          ///////////////////////////////////////////////////

          _buildMessageContent(
            isAdmin: isAdmin,
          ),

          const SizedBox(height: 5),

          ///////////////////////////////////////////////////
          /// TIME
          ///////////////////////////////////////////////////

          _buildTime(
            isAdmin: isAdmin,
          ),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// ADMIN NAME
  ///////////////////////////////////////////////////////////

 Widget _buildAdminName() {
  return Text(
    _adminName ?? "Admin",
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      color: Colors.white.withOpacity(.90),
      fontSize: 11,
      fontWeight: FontWeight.w800,
    ),
  );
}

  ///////////////////////////////////////////////////////////
  /// CUSTOMER NAME
  ///////////////////////////////////////////////////////////

  Widget _buildCustomerName() {
    return const Text(
      "Customer",
      style: TextStyle(
        color: Color(0xff77727A),
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// MESSAGE CONTENT
  ///////////////////////////////////////////////////////////

  Widget _buildMessageContent({
    required bool isAdmin,
  }) {
    final message = widget.message;

    switch (message.type) {

      ///////////////////////////////////////////////////////
      /// IMAGE
      ///////////////////////////////////////////////////////

      case "image":
        return _buildImageMessage(
          isAdmin: isAdmin,
        );

      ///////////////////////////////////////////////////////
      /// ORDER
      ///////////////////////////////////////////////////////

      case "order":
        return _buildOrderMessage(
          isAdmin: isAdmin,
        );

      ///////////////////////////////////////////////////////
      /// PAYMENT
      ///////////////////////////////////////////////////////

      case "payment":
        return _buildSpecialMessage(
          icon:
              Icons.payments_outlined,
          title:
              "Payment Update",
          isAdmin: isAdmin,
        );

      ///////////////////////////////////////////////////////
      /// TRACKING
      ///////////////////////////////////////////////////////

      case "tracking":
        return _buildSpecialMessage(
          icon:
              Icons.local_shipping_outlined,
          title:
              "Tracking Update",
          isAdmin: isAdmin,
        );

      ///////////////////////////////////////////////////////
      /// INVOICE
      ///////////////////////////////////////////////////////

      case "invoice":
        return _buildSpecialMessage(
          icon:
              Icons.receipt_long_outlined,
          title:
              "Invoice",
          isAdmin: isAdmin,
        );

      ///////////////////////////////////////////////////////
      /// STATUS
      ///////////////////////////////////////////////////////

      case "status":
        return _buildSpecialMessage(
          icon:
              Icons.sync_alt,
          title:
              "Order Status Update",
          isAdmin: isAdmin,
        );

      ///////////////////////////////////////////////////////
      /// TEXT
      ///////////////////////////////////////////////////////

      case "text":
      default:
        return Text(
          message.text,
          style: TextStyle(
            color: isAdmin
                ? Colors.white
                : const Color(
                    0xff241B2F,
                  ),
            fontSize: 14.5,
            height: 1.4,
          ),
        );
    }
  }

  ///////////////////////////////////////////////////////////
  /// IMAGE MESSAGE
  ///////////////////////////////////////////////////////////

  Widget _buildImageMessage({
    required bool isAdmin,
  }) {
    final message = widget.message;

    if (message.image.isEmpty) {
      return _buildSpecialMessage(
        icon:
            Icons.image_outlined,
        title:
            "Image",
        isAdmin: isAdmin,
      );
    }

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(14),
      child: Image.network(
        message.image,
        width: 220,
        height: 220,
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) {
          return _buildSpecialMessage(
            icon:
                Icons.broken_image_outlined,
            title:
                "Image unavailable",
            isAdmin: isAdmin,
          );
        },
        loadingBuilder:
            (
          context,
          child,
          loadingProgress,
        ) {
          if (loadingProgress ==
              null) {
            return child;
          }

          return SizedBox(
            width: 220,
            height: 180,
            child: Center(
              child:
                  CircularProgressIndicator(
                strokeWidth: 2,
                value:
                    loadingProgress
                                .expectedTotalBytes !=
                            null
                        ? loadingProgress
                                .cumulativeBytesLoaded /
                            loadingProgress
                                .expectedTotalBytes!
                        : null,
              ),
            ),
          );
        },
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// ORDER MESSAGE
  ///////////////////////////////////////////////////////////

  Widget _buildOrderMessage({
    required bool isAdmin,
  }) {
    final message = widget.message;

    final summary =
        message.orderSummary ?? {};

    final itemsCount =
        summary["itemsCount"] ?? 0;

    final total =
        (summary["totalAmount"] ?? 0)
            .toDouble();

    final status =
        summary["orderStatus"] ??
            "Placed";

    return Container(
      padding:
          const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAdmin
            ? Colors.white
                .withOpacity(.12)
            : const Color(
                0xffF8F5F7,
              ),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Icon(
                Icons
                    .shopping_bag_outlined,
                size: 20,
                color: isAdmin
                    ? Colors.white
                    : const Color(
                        0xffE91E63,
                      ),
              ),

              const SizedBox(
                width: 8,
              ),

              Text(
                "Order Created",
                style: TextStyle(
                  color: isAdmin
                      ? Colors.white
                      : const Color(
                          0xff241B2F,
                        ),
                  fontWeight:
                      FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),

          _summaryRow(
            "Items",
            "$itemsCount",
            isAdmin,
          ),

          _summaryRow(
            "Total",
            "₹${total.toStringAsFixed(0)}",
            isAdmin,
          ),

          _summaryRow(
            "Status",
            status.toString(),
            isAdmin,
          ),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// SPECIAL MESSAGE
  ///////////////////////////////////////////////////////////

  Widget _buildSpecialMessage({
    required IconData icon,
    required String title,
    required bool isAdmin,
  }) {
    final message = widget.message;

    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [

        Icon(
          icon,
          size: 20,
          color: isAdmin
              ? Colors.white
              : const Color(
                  0xffE91E63,
                ),
        ),

        const SizedBox(
          width: 8,
        ),

        Flexible(
          child: Text(
            message.text.isNotEmpty
                ? message.text
                : title,
            style: TextStyle(
              color: isAdmin
                  ? Colors.white
                  : const Color(
                      0xff241B2F,
                    ),
              fontSize: 14,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  ///////////////////////////////////////////////////////////
  /// SYSTEM MESSAGE
  ///////////////////////////////////////////////////////////

  Widget _buildSystemMessage() {
    final message = widget.message;

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 8,
      ),
      child: Center(
        child: Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 9,
          ),
          decoration:
              BoxDecoration(
            color:
                const Color(0xffF1EDF0),
            borderRadius:
                BorderRadius.circular(
              30,
            ),
          ),
          child: Row(
            mainAxisSize:
                MainAxisSize.min,
            children: [

              const Icon(
                Icons.info_outline,
                size: 15,
                color:
                    Color(0xff7E6A71),
              ),

              const SizedBox(
                width: 6,
              ),

              Flexible(
                child: Text(
                  message.text.isNotEmpty
                      ? message.text
                      : "System update",
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    color:
                        Color(0xff6F6268),
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// AVATAR
  ///////////////////////////////////////////////////////////

  Widget _avatar({
    required bool isAdmin,
  }) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: isAdmin
          ? const Color(0xffFCE4EC)
          : const Color(0xffEEEEF2),
      child: Icon(
        isAdmin
            ? Icons.support_agent
            : Icons.person_outline,
        size: 17,
        color: isAdmin
            ? const Color(0xffE91E63)
            : const Color(0xff77727A),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// TIME
  ///////////////////////////////////////////////////////////

  Widget _buildTime({
    required bool isAdmin,
  }) {
    final message = widget.message;

    if (message.createdAt ==
        null) {
      return const SizedBox.shrink();
    }

    final time =
        DateFormat(
      "hh:mm a",
    ).format(
      message.createdAt!.toDate(),
    );

    return Text(
      time,
      style: TextStyle(
        color: isAdmin
            ? Colors.white
                .withOpacity(.75)
            : Colors.grey.shade500,
        fontSize: 10,
        fontWeight:
            FontWeight.w500,
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// ORDER SUMMARY ROW
  ///////////////////////////////////////////////////////////

  Widget _summaryRow(
    String label,
    String value,
    bool isAdmin,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 5,
      ),
      child: Row(
        children: [

          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isAdmin
                    ? Colors.white
                        .withOpacity(.75)
                    : Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),

          Text(
            value,
            style: TextStyle(
              color: isAdmin
                  ? Colors.white
                  : const Color(
                      0xff241B2F,
                    ),
              fontSize: 12,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}