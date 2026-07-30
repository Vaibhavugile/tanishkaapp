import 'package:flutter/material.dart';

import '../../../models/order_chat_model.dart';
import '../../../models/chat_message_model.dart';
import '../../../services/order_chat_service.dart';

class OrderChatScreen extends StatefulWidget {
  final OrderChatModel chat;

  const OrderChatScreen({
    super.key,
    required this.chat,
  });

  @override
  State<OrderChatScreen> createState() =>
      _OrderChatScreenState();
}

class _OrderChatScreenState
    extends State<OrderChatScreen> {
  final TextEditingController _controller =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    OrderChatService.instance.markAsRead(
      widget.chat.orderId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF8FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        titleSpacing: 0,

        title: Row(
          children: [

            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xffFFCCE1),
                    Color(0xffE91E63),
                  ],
                ),
              ),
              child: const Icon(
                Icons.shopping_bag,
                color: Colors.white,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    widget.chat.orderId,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    widget.chat.orderStatus,
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [

          //////////////////////////////////////////////////////
          /// MESSAGES
          //////////////////////////////////////////////////////

          Expanded(
            child: StreamBuilder<
                List<ChatMessageModel>>(
              stream: OrderChatService.instance
                  .messagesStream(
                widget.chat.orderId,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                final messages =
                    snapshot.data!;

                return ListView.builder(
                  padding:
                      const EdgeInsets.all(16),

                  itemCount:
                      messages.length,

                  itemBuilder:
                      (context, index) {
                    final message =
                        messages[index];

                    return buildMessageBubble(
                      message,
                    );
                  },
                );
              },
            ),
          ),

          //////////////////////////////////////////////////////
          /// INPUT
          //////////////////////////////////////////////////////

          SafeArea(
            child: Container(
              padding:
                  const EdgeInsets.all(12),

              decoration: const BoxDecoration(
                color: Colors.white,
              ),

              child: Row(
                children: [

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(
                          0xffF7F4F6,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                                30),
                      ),

                      child: TextField(
                        controller:
                            _controller,

                        decoration:
                            const InputDecoration(
                          hintText:
                              "Type your message...",
                          border:
                              InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  InkWell(
                    borderRadius:
                        BorderRadius.circular(
                            100),
                    onTap: () async {
                      final text =
                          _controller.text;

                      _controller.clear();

                      await OrderChatService
                          .instance
                          .sendMessage(
                        orderId:
                            widget.chat.orderId,
                        text: text,
                      );
                    },
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration:
                          const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient:
                            LinearGradient(
                          colors: [
                            Color(0xffFF73AF),
                            Color(0xffE91E63),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMessageBubble(
  ChatMessageModel message,
) {
  final isMine = message.isCustomer;

  //////////////////////////////////////////////////////
  /// ORDER CARD
  //////////////////////////////////////////////////////

  if (message.isOrder) {
    final summary = message.orderSummary ?? {};

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            //////////////////////////////////////////////////////
            /// HEADER
            //////////////////////////////////////////////////////

            Row(
              children: [

                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(16),
                    gradient:
                        const LinearGradient(
                      colors: [
                        Color(0xffFFCCE1),
                        Color(0xffE91E63),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.shopping_bag,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 14),

                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        "Order Placed Successfully",
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        "Our team will contact you shortly.",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            //////////////////////////////////////////////////////
            /// DETAILS
            //////////////////////////////////////////////////////

            _infoRow(
              Icons.shopping_cart_outlined,
              "Items",
              "${summary["itemsCount"] ?? 0}",
            ),

            const SizedBox(height: 10),

            _infoRow(
              Icons.currency_rupee,
              "Subtotal",
              "₹${summary["subtotal"] ?? 0}",
            ),

            const SizedBox(height: 10),

            _infoRow(
              Icons.local_shipping_outlined,
              "Shipping",
              "₹${summary["shippingFee"] ?? 0}",
            ),

            const Divider(height: 28),

            Row(
              children: [

                const Text(
                  "Total",
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const Spacer(),

                Text(
                  "₹${summary["totalAmount"] ?? 0}",
                  style: const TextStyle(
                    color: Color(0xffE91E63),
                    fontWeight:
                        FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [

                _statusChip(
                  summary["orderStatus"] ??
                      "Placed",
                  Colors.green,
                ),

                const SizedBox(width: 10),

                _statusChip(
                  summary["paymentStatus"] ??
                      "Pending",
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////
  /// NORMAL CHAT BUBBLE
  //////////////////////////////////////////////////////

  return Align(
    alignment: isMine
        ? Alignment.centerRight
        : Alignment.centerLeft,
    child: Container(
      margin:
          const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      constraints: const BoxConstraints(
        maxWidth: 290,
      ),
      decoration: BoxDecoration(
        color: isMine
            ? const Color(0xffE91E63)
            : Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(.05),
            blurRadius: 12,
          ),
        ],
      ),
      child: Text(
        message.text,
        style: TextStyle(
          color: isMine
              ? Colors.white
              : Colors.black87,
          height: 1.5,
        ),
      ),
    ),
  );
}

Widget _infoRow(
  IconData icon,
  String title,
  String value,
) {
  return Row(
    children: [
      Icon(
        icon,
        size: 18,
        color: const Color(0xffE91E63),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(title),
      ),
      Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

Widget _statusChip(
  String text,
  Color color,
) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 7,
    ),
    decoration: BoxDecoration(
      color: color.withOpacity(.10),
      borderRadius:
          BorderRadius.circular(30),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
}