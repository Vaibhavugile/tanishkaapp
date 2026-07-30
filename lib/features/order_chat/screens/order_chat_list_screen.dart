import 'package:flutter/material.dart';

import 'package:tanishka/features/splash/widgets/luxury_background.dart';
import '../../../models/order_chat_model.dart';
import '../../../services/order_chat_service.dart';
import 'order_chat_screen.dart';

class OrderChatListScreen extends StatefulWidget {
  const OrderChatListScreen({
    super.key,
  });

  @override
  State<OrderChatListScreen> createState() =>
      _OrderChatListScreenState();
}

class _OrderChatListScreenState
    extends State<OrderChatListScreen> {
  
Future<void> _refresh() async {
  // StreamBuilder already keeps data live.
  // This is only to show the refresh animation.

  await Future.delayed(
    const Duration(milliseconds: 800),
  );

  if (mounted) {
    setState(() {});
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: LuxuryBackground(
        child: SafeArea(
          child: Column(
            children: [
              /////////////////////////////////////////////////////////
              /// HEADER
              /////////////////////////////////////////////////////////

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  18,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xffF8D7E5),
                            Color(0xffF4B6CC),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xffD79AB1,
                            ).withOpacity(.25),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.chat_bubble_rounded,
                        color: Color(0xff7A294D),
                        size: 26,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "My Orders",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight:
                                  FontWeight.w800,
                              color:
                                  Color(0xff44212E),
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            "Track orders & chat with us",
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  Color(0xff9B7B85),
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(.05),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        color: Color(0xffE91E63),
                      ),
                    ),
                  ],
                ),
              ),

              /////////////////////////////////////////////////////////
              /// BODY
              /////////////////////////////////////////////////////////

              Expanded(
                child: StreamBuilder<
                    List<OrderChatModel>>(
                  stream: OrderChatService
                      .instance
                      .chatsStream(),
                  builder: (context, snapshot) {
                    //////////////////////////////////////////////////////
                    /// Loading
                    //////////////////////////////////////////////////////

                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child:
                            CircularProgressIndicator(
                          color:
                              Color(0xffE91E63),
                        ),
                      );
                    }

                    //////////////////////////////////////////////////////
                    /// Empty
                    //////////////////////////////////////////////////////

                    if (!snapshot.hasData ||
                        snapshot.data!.isEmpty) {
                      return Center(
                        child: Padding(
                          padding:
                              const EdgeInsets.all(
                                  28),
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration:
                                    BoxDecoration(
                                  shape:
                                      BoxShape.circle,
                                  gradient:
                                      const LinearGradient(
                                    colors: [
                                      Color(
                                          0xffFFE8F2),
                                      Color(
                                          0xffF8D7E5),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                              0xffE91E63)
                                          .withOpacity(
                                              .10),
                                      blurRadius:
                                          30,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons
                                      .shopping_bag_outlined,
                                  size: 55,
                                  color: Color(
                                      0xffE91E63),
                                ),
                              ),

                              const SizedBox(
                                  height: 30),

                              const Text(
                                "No Orders Yet",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                  color: Color(
                                      0xff44212E),
                                ),
                              ),

                              const SizedBox(
                                  height: 12),

                              const Text(
                                "Place your first order and\nall conversations with our team\nwill appear here.",
                                textAlign:
                                    TextAlign.center,
                                style: TextStyle(
                                  height: 1.6,
                                  fontSize: 15,
                                  color: Color(
                                      0xff8F7984),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    //////////////////////////////////////////////////////
                    /// LIST
                    //////////////////////////////////////////////////////

                    final chats =
                        snapshot.data!;

                    return RefreshIndicator(
  color: const Color(0xffE91E63),

  backgroundColor: Colors.white,

  onRefresh: _refresh,

  child: ListView.separated(
    physics: const AlwaysScrollableScrollPhysics(
      parent: BouncingScrollPhysics(),
    ),

    padding: const EdgeInsets.fromLTRB(
      20,
      4,
      20,
      120,
    ),

    itemCount: chats.length,

    separatorBuilder: (_, __) =>
        const SizedBox(height: 16),

    itemBuilder: (context, index) {
      return _ChatTile(
        chat: chats[index],
      );
    },
  ),
);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
 
}
 class _ChatTile extends StatelessWidget {
  final OrderChatModel chat;

  const _ChatTile({
    required this.chat,
  });

  Color get statusColor {
    switch (chat.orderStatus.toLowerCase()) {
      case "confirmed":
        return const Color(0xff2196F3);

      case "packed":
        return const Color(0xffFF9800);

      case "shipped":
        return const Color(0xff7B61FF);

      case "delivered":
        return const Color(0xff2E7D32);

      case "cancelled":
        return Colors.red;

      default:
        return const Color(0xff28A745);
    }
  }

  Color get paymentColor {
    return chat.paymentStatus.toLowerCase() == "paid"
        ? const Color(0xff28A745)
        : const Color(0xffFF9800);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderChatScreen(
              chat: chat,
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 28,
              spreadRadius: 1,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //////////////////////////////////////////////////////////
            /// ICON
            //////////////////////////////////////////////////////////

            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xffFFCCE1),
                    Color(0xffE91E63),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.shopping_bag_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),

            const SizedBox(width: 16),

            //////////////////////////////////////////////////////////
            /// DETAILS
            //////////////////////////////////////////////////////////

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [

                      Expanded(
                        child: Text(
                          chat.orderId,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.w800,
                            fontSize: 17,
                            color:
                                Color(0xff2E2036),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    chat.lastMessage,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [

                      ////////////////////////////////////////////////////
                      /// ORDER STATUS
                      ////////////////////////////////////////////////////

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              statusColor.withOpacity(.10),
                          borderRadius:
                              BorderRadius.circular(30),
                        ),
                        child: Text(
                          chat.orderStatus,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight:
                                FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      ////////////////////////////////////////////////////
                      /// PAYMENT
                      ////////////////////////////////////////////////////

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: paymentColor
                              .withOpacity(.10),
                          borderRadius:
                              BorderRadius.circular(30),
                        ),
                        child: Text(
                          chat.paymentStatus,
                          style: TextStyle(
                            color: paymentColor,
                            fontWeight:
                                FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [

                      Icon(
                        Icons.access_time_rounded,
                        size: 15,
                        color: Colors.grey.shade500,
                      ),

                      const SizedBox(width: 5),

                      Expanded(
                        child: Text(
                          chat.lastMessageTime == null
                              ? "-"
                              : "${chat.lastMessageTime!.toDate().day}/${chat.lastMessageTime!.toDate().month}/${chat.lastMessageTime!.toDate().year}",
                          style: TextStyle(
                            color:
                                Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      if (chat.unreadCustomer > 0)
                        Container(
                          width: 26,
                          height: 26,
                          decoration:
                              const BoxDecoration(
                            color:
                                Color(0xffE91E63),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              "${chat.unreadCustomer}",
                              style:
                                  const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}