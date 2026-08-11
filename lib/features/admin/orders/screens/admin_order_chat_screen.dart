import 'package:flutter/material.dart';

import 'package:tanishka/models/chat_message_model.dart';

import '../services/admin_chat_service.dart';
import '../services/admin_order_service.dart';

import '../widgets/order_summary_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class AdminOrderChatScreen extends StatefulWidget {
  final String orderId;

  const AdminOrderChatScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<AdminOrderChatScreen> createState() =>
      _AdminOrderChatScreenState();
}

class _AdminOrderChatScreenState
    extends State<AdminOrderChatScreen> {

  ///////////////////////////////////////////////////////////
  /// COLORS
  ///////////////////////////////////////////////////////////

  static const Color primary =
      Color(0xffE91E63);

  static const Color primaryDark =
      Color(0xffC2185B);

  static const Color plum =
      Color(0xff44212E);

  static const Color muted =
      Color(0xff9B7B85);

  static const Color background =
      Color(0xffFFF8FB);

  ///////////////////////////////////////////////////////////
  /// CONTROLLERS
  ///////////////////////////////////////////////////////////

  final TextEditingController
      _messageController =
      TextEditingController();

  final FocusNode _messageFocusNode =
      FocusNode();

  final ScrollController
      _scrollController =
      ScrollController();

  ///////////////////////////////////////////////////////////
  /// STATE
  ///////////////////////////////////////////////////////////

  bool _sending = false;

  bool _showNewMessageButton = false;

  int _previousMessageCount = 0;

  ///////////////////////////////////////////////////////////
  /// INIT
  ///////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(
      _handleScroll,
    );

    _markChatAsRead();
  }

  ///////////////////////////////////////////////////////////
  /// DISPOSE
  ///////////////////////////////////////////////////////////

  @override
  void dispose() {
    _messageController.dispose();

    _messageFocusNode.dispose();

    _scrollController.dispose();

    super.dispose();
  }

  ///////////////////////////////////////////////////////////
  /// MARK ADMIN CHAT READ
  ///////////////////////////////////////////////////////////

  Future<void> _markChatAsRead() async {
    try {
      await AdminChatService.instance
          .markAsRead(
        widget.orderId,
      );
    } catch (e) {
      debugPrint(
        "Admin mark read error: $e",
      );
    }
  }

  ///////////////////////////////////////////////////////////
  /// SCROLL LISTENER
  ///////////////////////////////////////////////////////////

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position =
        _scrollController.position;

    final distanceFromBottom =
        position.maxScrollExtent -
            position.pixels;

    final isNearBottom =
        distanceFromBottom < 120;

    if (isNearBottom &&
        _showNewMessageButton) {
      if (!mounted) return;

      setState(() {
        _showNewMessageButton = false;
      });
    }
  }

  ///////////////////////////////////////////////////////////
  /// SCROLL TO BOTTOM
  ///////////////////////////////////////////////////////////

  void _scrollToBottom({
    bool animated = true,
  }) {
    if (!_scrollController.hasClients) {
      return;
    }

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      final target =
          _scrollController
              .position
              .maxScrollExtent;

      if (animated) {
        _scrollController.animateTo(
          target,
          duration:
              const Duration(
            milliseconds: 300,
          ),
          curve:
              Curves.easeOutCubic,
        );
      } else {
        _scrollController.jumpTo(
          target,
        );
      }
    });
  }

  ///////////////////////////////////////////////////////////
  /// HANDLE MESSAGE CHANGES
  ///////////////////////////////////////////////////////////

  void _handleMessagesChanged(
    int messageCount,
  ) {
    if (_previousMessageCount == 0) {
      _previousMessageCount =
          messageCount;

      _scrollToBottom(
        animated: false,
      );

      return;
    }

    if (messageCount >
        _previousMessageCount) {
      final wasNearBottom =
          _isNearBottom();

      _previousMessageCount =
          messageCount;

      if (wasNearBottom) {
        _scrollToBottom();
      } else {
        if (!mounted) return;

        setState(() {
          _showNewMessageButton =
              true;
        });
      }
    }
  }

  ///////////////////////////////////////////////////////////
  /// CHECK BOTTOM
  ///////////////////////////////////////////////////////////

  bool _isNearBottom() {
    if (!_scrollController.hasClients) {
      return true;
    }

    final position =
        _scrollController.position;

    final distanceFromBottom =
        position.maxScrollExtent -
            position.pixels;

    return distanceFromBottom < 120;
  }

  ///////////////////////////////////////////////////////////
  /// SEND MESSAGE
  ///////////////////////////////////////////////////////////

  Future<void> _sendMessage() async {
    final text =
        _messageController.text.trim();

    if (text.isEmpty || _sending) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _sending = true;
    });

    try {
      await AdminChatService.instance
          .sendMessage(
        orderId: widget.orderId,
        text: text,
      );

      _messageController.clear();

      _messageFocusNode.requestFocus();

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      _showError(
        "Unable to send message",
      );

      debugPrint(
        "Admin send message error: $e",
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _sending = false;
      });
    }
  }

  ///////////////////////////////////////////////////////////
  /// ERROR SNACKBAR
  ///////////////////////////////////////////////////////////

  void _showError(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        behavior:
            SnackBarBehavior.floating,

        margin:
            const EdgeInsets.all(16),

        backgroundColor:
            plum,

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            16,
          ),
        ),

        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child: Text(
                message,
                style:
                    const TextStyle(
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

  ///////////////////////////////////////////////////////////
  /// BUILD
  ///////////////////////////////////////////////////////////

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          background,

      /////////////////////////////////////////////////////////
      /// HEADER
      /////////////////////////////////////////////////////////

      appBar:
          _buildAppBar(),

      /////////////////////////////////////////////////////////
      /// BODY
      /////////////////////////////////////////////////////////

      body: SafeArea(
        child: Column(
          children: [

            ///////////////////////////////////////////////////
            /// ORDER SUMMARY
            ///////////////////////////////////////////////////

            OrderSummaryCard(
              orderId:
                  widget.orderId,
            ),

            ///////////////////////////////////////////////////
            /// MESSAGES
            ///////////////////////////////////////////////////

            Expanded(
              child: Stack(
                children: [

                  StreamBuilder<
                      List<ChatMessageModel>>(
                    stream:
                        AdminChatService
                            .instance
                            .messagesStream(
                      widget.orderId,
                    ),

                    builder: (
                      context,
                      snapshot,
                    ) {

                      //////////////////////////////////////////////////
                      /// LOADING
                      //////////////////////////////////////////////////

                      if (snapshot
                              .connectionState ==
                          ConnectionState
                              .waiting) {
                        return _buildLoading();
                      }

                      //////////////////////////////////////////////////
                      /// ERROR
                      //////////////////////////////////////////////////

                      if (snapshot.hasError) {
                        return _buildMessageError(
                          snapshot.error,
                        );
                      }

                      final messages =
                          snapshot.data ?? [];

                      //////////////////////////////////////////////////
                      /// EMPTY
                      //////////////////////////////////////////////////

                      if (messages.isEmpty) {
                        _previousMessageCount =
                            0;

                        return _buildEmptyChat();
                      }

                      //////////////////////////////////////////////////
                      /// HANDLE NEW MESSAGES
                      //////////////////////////////////////////////////

                      WidgetsBinding.instance
                          .addPostFrameCallback(
                        (_) {
                          if (!mounted) {
                            return;
                          }

                          _handleMessagesChanged(
                            messages.length,
                          );
                        },
                      );

                      //////////////////////////////////////////////////
                      /// MESSAGE LIST
                      //////////////////////////////////////////////////

                      return ListView.builder(
                        controller:
                            _scrollController,

                        physics:
                            const BouncingScrollPhysics(),

                        padding:
                            const EdgeInsets.fromLTRB(
                          16,
                          14,
                          16,
                          24,
                        ),

                        itemCount:
                            messages.length,

                        itemBuilder: (
  context,
  index,
) {
  final message = messages[index];

  final showDateHeader =
      _shouldShowDateHeader(
    messages,
    index,
  );

  return Column(
    children: [
      if (showDateHeader)
        _buildDateSeparator(
          message.createdAt,
        ),

      _buildMessage(message),
    ],
  );
},
                      );
                    },
                  ),

                  //////////////////////////////////////////////////
                  /// NEW MESSAGE BUTTON
                  //////////////////////////////////////////////////

                  if (_showNewMessageButton)
                    Positioned(
                      bottom: 18,
                      right: 16,
                      child:
                          _buildNewMessageButton(),
                    ),
                ],
              ),
            ),

            ///////////////////////////////////////////////////
            /// INPUT
            ///////////////////////////////////////////////////

            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// APP BAR
  ///////////////////////////////////////////////////////////

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,

      scrolledUnderElevation: 0,

      backgroundColor:
          Colors.white,

      foregroundColor:
          plum,

      titleSpacing: 0,

      leading: IconButton(
        icon:
            const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: plum,
          size: 19,
        ),

        onPressed: () {
          Navigator.pop(context);
        },
      ),

      title: StreamBuilder<
          DocumentSnapshot<
              Map<String, dynamic>>>(
        stream:
            AdminOrderService
                .instance
                .orderChatStream(
          widget.orderId,
        ),

        builder: (
          context,
          snapshot,
        ) {
          final data =
              snapshot.data?.data();

          final customerName =
              (data?["customerName"] ??
                      "Customer")
                  .toString()
                  .trim();

          final orderStatus =
              (data?["orderStatus"] ??
                      "Order")
                  .toString()
                  .trim();

          return Row(
            children: [

              //////////////////////////////////////////////////
              /// AVATAR
              //////////////////////////////////////////////////

              Container(
                width: 42,
                height: 42,

                decoration:
                    const BoxDecoration(
                  shape:
                      BoxShape.circle,

                  gradient:
                      LinearGradient(
                    colors: [
                      Color(0xffFFCCE1),
                      Color(0xffE91E63),
                    ],

                    begin:
                        Alignment.topLeft,

                    end:
                        Alignment.bottomRight,
                  ),
                ),

                child:
                    const Icon(
                  Icons.shopping_bag_rounded,
                  color:
                      Colors.white,
                  size: 21,
                ),
              ),

              const SizedBox(
                width: 11,
              ),

              //////////////////////////////////////////////////
              /// NAME
              //////////////////////////////////////////////////

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    Text(
                      customerName.isEmpty
                          ? "Customer"
                          : customerName,

                      maxLines: 1,

                      overflow:
                          TextOverflow.ellipsis,

                      style:
                          const TextStyle(
                        color: plum,
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height: 2,
                    ),

                    Row(
                      children: [

                        Flexible(
                          child: Text(
                            "#${widget.orderId}",

                            maxLines: 1,

                            overflow:
                                TextOverflow.ellipsis,

                            style:
                                const TextStyle(
                              color:
                                  muted,
                              fontSize: 9,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 6,
                        ),

                        Container(
                          width: 4,
                          height: 4,
                          decoration:
                              const BoxDecoration(
                            color:
                                Color(0xffC7AAB6),
                            shape:
                                BoxShape.circle,
                          ),
                        ),

                        const SizedBox(
                          width: 6,
                        ),

                        Text(
                          orderStatus,

                          style:
                              const TextStyle(
                            color:
                                Color(0xff2E7D32),
                            fontSize: 9,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// MESSAGE
  ///////////////////////////////////////////////////////////
bool _shouldShowDateHeader(
  List<ChatMessageModel> messages,
  int index,
) {
  final current = messages[index].createdAt;

  if (current == null) {
    return false;
  }

  if (index == 0) {
    return true;
  }

  final previous =
      messages[index - 1].createdAt;

  if (previous == null) {
    return true;
  }

  final currentDate =
      current.toDate();

  final previousDate =
      previous.toDate();

  return currentDate.year != previousDate.year ||
      currentDate.month != previousDate.month ||
      currentDate.day != previousDate.day;
}
Widget _buildDateSeparator(
  Timestamp? timestamp,
) {
  if (timestamp == null) {
    return const SizedBox.shrink();
  }

  final date = timestamp.toDate();

  final now = DateTime.now();

  final today = DateTime(
    now.year,
    now.month,
    now.day,
  );

  final messageDay = DateTime(
    date.year,
    date.month,
    date.day,
  );

  final difference =
      today.difference(messageDay).inDays;

  String label;

  if (difference == 0) {
    label = "TODAY";
  } else if (difference == 1) {
    label = "YESTERDAY";
  } else if (difference == -1) {
    label = "TOMORROW";
  } else {
    label = _formatDateSeparator(date);
  }

  return Padding(
    padding: const EdgeInsets.symmetric(
      vertical: 14,
    ),
    child: Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(
            color: const Color(
              0xffF0E2E8,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(.035),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: muted,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: .5,
          ),
        ),
      ),
    ),
  );
}
String _formatDateSeparator(
  DateTime date,
) {
  final now = DateTime.now();

  final sameYear =
      date.year == now.year;

  if (sameYear) {
    return "${_monthName(date.month)} "
        "${date.day}";
  }

  return "${_monthName(date.month)} "
      "${date.day}, "
      "${date.year}";
}
String _monthName(int month) {
  const months = [
    "JANUARY",
    "FEBRUARY",
    "MARCH",
    "APRIL",
    "MAY",
    "JUNE",
    "JULY",
    "AUGUST",
    "SEPTEMBER",
    "OCTOBER",
    "NOVEMBER",
    "DECEMBER",
  ];

  return months[month - 1];
}
  Widget _buildMessage(
    ChatMessageModel message,
  ) {
    /////////////////////////////////////////////////////////
    /// ORDER MESSAGE
    /////////////////////////////////////////////////////////

    // if (message.isOrder) {
    //   return _buildOrderMessage(
    //     message,
    //   );
    // }

    /////////////////////////////////////////////////////////
    /// SYSTEM MESSAGE
    /////////////////////////////////////////////////////////

    if (message.isSystem) {
      return _buildSystemMessage(
        message,
      );
    }

    /////////////////////////////////////////////////////////
    /// NORMAL MESSAGE
    /////////////////////////////////////////////////////////

    final isAdmin =
        message.isAdmin;

    final isCustomer =
        message.isCustomer;

    /////////////////////////////////////////////////////////
    /// UNKNOWN SENDER
    /////////////////////////////////////////////////////////

    if (!isAdmin && !isCustomer) {
      return _buildSystemMessage(
        message,
      );
    }

    return _buildChatBubble(
      message,
      isAdmin: isAdmin,
    );
  }

  ///////////////////////////////////////////////////////////
  /// CHAT BUBBLE
  ///////////////////////////////////////////////////////////

  Widget _buildChatBubble(
    ChatMessageModel message, {
    required bool isAdmin,
  }) {
    final alignment =
        isAdmin
            ? Alignment.centerRight
            : Alignment.centerLeft;

    final bubbleColor =
        isAdmin
            ? primary
            : Colors.white;

    final textColor =
        isAdmin
            ? Colors.white
            : plum;

    final radius =
        isAdmin
            ? const BorderRadius.only(
                topLeft:
                    Radius.circular(22),
                topRight:
                    Radius.circular(22),
                bottomLeft:
                    Radius.circular(22),
                bottomRight:
                    Radius.circular(6),
              )
            : const BorderRadius.only(
                topLeft:
                    Radius.circular(6),
                topRight:
                    Radius.circular(22),
                bottomLeft:
                    Radius.circular(22),
                bottomRight:
                    Radius.circular(22),
              );

    /////////////////////////////////////////////////////////
    /// MESSAGE CONTENT
    /////////////////////////////////////////////////////////

    Widget content;

    if (message.isImage &&
        message.image.isNotEmpty) {
      content =
          _buildImageMessage(
        message,
        isAdmin,
      );
    } else {
      content = Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          //////////////////////////////////////////////////
          /// SENDER LABEL
          //////////////////////////////////////////////////

          Text(
            isAdmin
                ? "You"
                : "Customer",

            style:
                TextStyle(
              color: isAdmin
                  ? Colors.white
                      .withOpacity(.72)
                  : muted,

              fontSize: 9,

              fontWeight:
                  FontWeight.w800,

              letterSpacing:
                  .3,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          //////////////////////////////////////////////////
          /// TEXT
          //////////////////////////////////////////////////

          if (message.text
              .trim()
              .isNotEmpty)
            Text(
              message.text,

              style:
                  TextStyle(
                color:
                    textColor,

                fontSize: 13.5,

                height: 1.45,

                fontWeight:
                    FontWeight.w500,
              ),
            ),

          //////////////////////////////////////////////////
          /// TIME
          //////////////////////////////////////////////////

          if (message.createdAt != null)
            Padding(
              padding:
                  const EdgeInsets.only(
                top: 6,
              ),

              child: Text(
                _formatMessageTime(
                  message.createdAt!,
                ),

                style:
                    TextStyle(
                  color: isAdmin
                      ? Colors.white
                          .withOpacity(.65)
                      : muted,

                  fontSize: 8.5,

                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
        ],
      );
    }

    return Align(
      alignment: alignment,

      child: Container(
        constraints:
            BoxConstraints(
          maxWidth:
              MediaQuery.of(context)
                      .size
                      .width *
                  .76,
        ),

        margin:
            const EdgeInsets.only(
          bottom: 10,
        ),

        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 11,
        ),

        decoration:
            BoxDecoration(
          color:
              bubbleColor,

          borderRadius:
              radius,

          boxShadow: [
            BoxShadow(
              color:
                  Colors.black
                      .withOpacity(
                isAdmin
                    ? .04
                    : .055,
              ),

              blurRadius: 14,

              offset:
                  const Offset(
                0,
                6,
              ),
            ),
          ],
        ),

        child: content,
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// IMAGE MESSAGE
  ///////////////////////////////////////////////////////////

  Widget _buildImageMessage(
    ChatMessageModel message,
    bool isAdmin,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        ClipRRect(
          borderRadius:
              BorderRadius.circular(
            16,
          ),

          child: Image.network(
            message.image,

            width: 220,

            height: 220,

            fit:
                BoxFit.cover,

            errorBuilder:
                (
              context,
              error,
              stackTrace,
            ) {
              return Container(
                width: 220,
                height: 150,

                color:
                    isAdmin
                        ? primaryDark
                        : const Color(
                            0xffF7F1F4,
                          ),

                child:
                    Icon(
                  Icons
                      .broken_image_outlined,

                  color:
                      isAdmin
                          ? Colors.white
                          : muted,

                  size: 32,
                ),
              );
            },
          ),
        ),

        if (message.text
            .trim()
            .isNotEmpty) ...[
          const SizedBox(
            height: 8,
          ),

          Text(
            message.text,

            style:
                TextStyle(
              color: isAdmin
                  ? Colors.white
                  : plum,

              fontSize: 12,
            ),
          ),
        ],

        if (message.createdAt != null)
          Padding(
            padding:
                const EdgeInsets.only(
              top: 5,
            ),

            child: Text(
              _formatMessageTime(
                message.createdAt!,
              ),

              style:
                  TextStyle(
                color: isAdmin
                    ? Colors.white
                        .withOpacity(.65)
                    : muted,

                fontSize: 8,
              ),
            ),
          ),
      ],
    );
  }

  ///////////////////////////////////////////////////////////
  /// SYSTEM MESSAGE
  ///////////////////////////////////////////////////////////

  Widget _buildSystemMessage(
    ChatMessageModel message,
  ) {
    return Center(
      child: Container(
        constraints:
            BoxConstraints(
          maxWidth:
              MediaQuery.of(context)
                      .size
                      .width *
                  .82,
        ),

        margin:
            const EdgeInsets.only(
          top: 6,
          bottom: 14,
        ),

        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 11,
        ),

        decoration:
            BoxDecoration(
          color:
              Colors.white,

          borderRadius:
              BorderRadius.circular(
            20,
          ),

          border:
              Border.all(
            color:
                const Color(
              0xffF0E2E8,
            ),
          ),

          boxShadow: [
            BoxShadow(
              color:
                  Colors.black
                      .withOpacity(.035),

              blurRadius: 12,

              offset:
                  const Offset(
                0,
                5,
              ),
            ),
          ],
        ),

        child: Row(
          mainAxisSize:
              MainAxisSize.min,

          children: [

            Container(
              width: 30,
              height: 30,

              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xffFFE8F2,
                ),

                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),

              child:
                  const Icon(
                Icons.auto_awesome_rounded,
                color:
                    primary,
                size: 15,
              ),
            ),

            const SizedBox(
              width: 9,
            ),

            Flexible(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Text(
                    "SYSTEM",
                    style:
                        TextStyle(
                      color:
                          muted,
                      fontSize: 8,
                      fontWeight:
                          FontWeight.w900,
                      letterSpacing:
                          .7,
                    ),
                  ),

                  const SizedBox(
                    height: 2,
                  ),

                  Text(
                    message.text.isEmpty
                        ? "Order update"
                        : message.text,

                    textAlign:
                        TextAlign.left,

                    style:
                        const TextStyle(
                      color:
                          plum,
                      fontSize: 11.5,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// ORDER MESSAGE
  ///////////////////////////////////////////////////////////

  Widget _buildOrderMessage(
    ChatMessageModel message,
  ) {
    final summary =
        message.orderSummary ?? {};

    return Container(
      width: double.infinity,

      margin:
          const EdgeInsets.only(
        top: 4,
        bottom: 16,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          26,
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black
                    .withOpacity(.055),

            blurRadius: 22,

            offset:
                const Offset(
              0,
              10,
            ),
          ),
        ],
      ),

      child: Padding(
        padding:
            const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            //////////////////////////////////////////////////
            /// HEADER
            //////////////////////////////////////////////////

            Row(
              children: [

                Container(
                  width: 52,
                  height: 52,

                  decoration:
                      BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(
                      17,
                    ),

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
                  ),

                  child:
                      const Icon(
                    Icons
                        .shopping_bag_rounded,
                    color:
                        Colors.white,
                    size: 25,
                  ),
                ),

                const SizedBox(
                  width: 13,
                ),

                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(
                        "Order Created",
                        style:
                            TextStyle(
                          color:
                              plum,
                          fontSize: 15,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),

                      SizedBox(
                        height: 3,
                      ),

                      Text(
                        "Order details",
                        style:
                            TextStyle(
                          color:
                              muted,
                          fontSize: 10,
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            //////////////////////////////////////////////////
            /// DETAILS
            //////////////////////////////////////////////////

            _orderInfoRow(
              Icons.shopping_cart_outlined,
              "Items",
              "${summary["itemsCount"] ?? 0}",
            ),

            const SizedBox(
              height: 11,
            ),

            _orderInfoRow(
              Icons.currency_rupee_rounded,
              "Subtotal",
              "₹${summary["subtotal"] ?? 0}",
            ),

            const SizedBox(
              height: 11,
            ),

            _orderInfoRow(
              Icons.local_shipping_outlined,
              "Shipping",
              "₹${summary["shippingFee"] ?? 0}",
            ),

            const SizedBox(
              height: 14,
            ),

            const Divider(
              color:
                  Color(0xffF2E8ED),
            ),

            const SizedBox(
              height: 12,
            ),

            Row(
              children: [

                const Text(
                  "Total",
                  style:
                      TextStyle(
                    color:
                        plum,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const Spacer(),

                Text(
                  "₹${summary["totalAmount"] ?? 0}",

                  style:
                      const TextStyle(
                    color:
                        primary,
                    fontSize: 21,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 15,
            ),

            Row(
              children: [

                _orderStatusChip(
                  summary["orderStatus"] ??
                      "Placed",
                  const Color(
                    0xff2E7D32,
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                _orderStatusChip(
                  summary["paymentStatus"] ??
                      "Pending",
                  const Color(
                    0xffEF6C00,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// ORDER INFO ROW
  ///////////////////////////////////////////////////////////

  Widget _orderInfoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [

        Container(
          width: 34,
          height: 34,

          decoration:
              BoxDecoration(
            color:
                const Color(
              0xffFFF1F6,
            ),

            borderRadius:
                BorderRadius.circular(
              11,
            ),
          ),

          child:
              Icon(
            icon,
            size: 16,
            color:
                primary,
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        Expanded(
          child:
              Text(
            title,

            style:
                const TextStyle(
              color:
                  muted,
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),

        Text(
          value,

          style:
              const TextStyle(
            color:
                plum,
            fontSize: 12,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ],
    );
  }

  ///////////////////////////////////////////////////////////
  /// STATUS CHIP
  ///////////////////////////////////////////////////////////

  Widget _orderStatusChip(
    dynamic value,
    Color color,
  ) {
    final text =
        value.toString();

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),

      decoration:
          BoxDecoration(
        color:
            color.withOpacity(.10),

        borderRadius:
            BorderRadius.circular(
          30,
        ),
      ),

      child: Text(
        text,

        style:
            TextStyle(
          color:
              color,

          fontSize: 9,

          fontWeight:
              FontWeight.w800,
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// NEW MESSAGE BUTTON
  ///////////////////////////////////////////////////////////

  Widget _buildNewMessageButton() {
    return Material(
      color:
          Colors.white,

      elevation: 0,

      borderRadius:
          BorderRadius.circular(
        30,
      ),

      shadowColor:
          primary.withOpacity(.2),

      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          30,
        ),

        onTap: () {
          setState(() {
            _showNewMessageButton =
                false;
          });

          _scrollToBottom();
        },

        child: Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 10,
          ),

          decoration:
              BoxDecoration(
            color:
                Colors.white,

            borderRadius:
                BorderRadius.circular(
              30,
            ),

            boxShadow: [
              BoxShadow(
                color:
                    primary.withOpacity(.14),

                blurRadius: 18,

                offset:
                    const Offset(
                  0,
                  7,
                ),
              ),
            ],
          ),

          child: Row(
            mainAxisSize:
                MainAxisSize.min,

            children: [

              const Icon(
                Icons
                    .keyboard_arrow_down_rounded,

                size: 18,

                color:
                    primary,
              ),

              const SizedBox(
                width: 5,
              ),

              const Text(
                "New message",

                style:
                    TextStyle(
                  color:
                      primary,

                  fontSize: 11,

                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// EMPTY CHAT
  ///////////////////////////////////////////////////////////

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisSize:
            MainAxisSize.min,

        children: [

          Container(
            width: 78,
            height: 78,

            decoration:
                const BoxDecoration(
              shape:
                  BoxShape.circle,

              gradient:
                  LinearGradient(
                colors: [
                  Color(0xffFFCCE1),
                  Color(0xffE91E63),
                ],
              ),
            ),

            child:
                const Icon(
              Icons.chat_bubble_outline_rounded,
              color:
                  Colors.white,
              size: 32,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          const Text(
            "No messages yet",
            style:
                TextStyle(
              color:
                  plum,
              fontSize: 17,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          const Text(
            "Start the conversation with the customer.",
            style:
                TextStyle(
              color:
                  muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// LOADING
  ///////////////////////////////////////////////////////////

  Widget _buildLoading() {
    return const Center(
      child:
          SizedBox(
        width: 28,
        height: 28,

        child:
            CircularProgressIndicator(
          strokeWidth: 2.5,

          valueColor:
              AlwaysStoppedAnimation<
                  Color>(
            primary,
          ),
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// ERROR
  ///////////////////////////////////////////////////////////

  Widget _buildMessageError(
    Object? error,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          28,
        ),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [

            Container(
              width: 70,
              height: 70,

              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xffffebf1,
                ),

                borderRadius:
                    BorderRadius.circular(
                  22,
                ),
              ),

              child:
                  const Icon(
                Icons
                    .cloud_off_rounded,

                color:
                    primary,

                size: 30,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            const Text(
              "Unable to load messages",
              style:
                  TextStyle(
                color:
                    plum,

                fontSize: 16,

                fontWeight:
                    FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: 7,
            ),

            Text(
              "Please try again.",

              style:
                  const TextStyle(
                color:
                    muted,

                fontSize: 11,
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            TextButton(
              onPressed:
                  () {
                setState(() {});
              },

              child:
                  const Text(
                "Retry",

                style:
                    TextStyle(
                  color:
                      primary,

                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// MESSAGE INPUT
  ///////////////////////////////////////////////////////////

  Widget _buildMessageInput() {
    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        10,
        8,
        10,
        10,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        boxShadow: [
          BoxShadow(
            color:
                Colors.black
                    .withOpacity(.055),

            blurRadius: 18,

            offset:
                const Offset(
              0,
              -5,
            ),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.end,

        children: [

          //////////////////////////////////////////////////
          /// ATTACHMENT
          //////////////////////////////////////////////////

          Container(
            width: 44,
            height: 44,

            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xffFFF1F6,
              ),

              borderRadius:
                  BorderRadius.circular(
                15,
              ),
            ),

            child:
                IconButton(
              onPressed:
                  _sending
                      ? null
                      : () {
                          // Future:
                          // image / PDF / invoice
                        },

              icon:
                  const Icon(
                Icons
                    .add_rounded,

                color:
                    primary,

                size: 21,
              ),
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          //////////////////////////////////////////////////
          /// TEXT FIELD
          //////////////////////////////////////////////////

          Expanded(
            child: Container(
              constraints:
                  const BoxConstraints(
                minHeight: 48,
                maxHeight: 120,
              ),

              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 16,
                vertical: 2,
              ),

              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xffF7F4F6,
                ),

                borderRadius:
                    BorderRadius.circular(
                  25,
                ),

                border:
                    Border.all(
                  color:
                      const Color(
                    0xffF1E5EA,
                  ),
                ),
              ),

              child:
                  TextField(
                controller:
                    _messageController,

                focusNode:
                    _messageFocusNode,

                enabled:
                    !_sending,

                maxLines: 4,

                minLines: 1,

                textCapitalization:
                    TextCapitalization
                        .sentences,

                

                decoration:
                    const InputDecoration(
                  hintText:
                      "Type a message...",

                  hintStyle:
                      TextStyle(
                    color:
                        Color(
                      0xffB39DA7,
                    ),

                    fontSize:
                        12,
                  ),

                  border:
                      InputBorder.none,

                  contentPadding:
                      EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          //////////////////////////////////////////////////
          /// SEND
          //////////////////////////////////////////////////

          ValueListenableBuilder<TextEditingValue>(
  valueListenable: _messageController,
  builder: (context, value, child) {
    final hasText = value.text.trim().isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasText
            ? const LinearGradient(
                colors: [
                  Color(0xffFF73AF),
                  Color(0xffE91E63),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [
                  Color(0xffE9DDE2),
                  Color(0xffDCCDD3),
                ],
              ),
        boxShadow: hasText
            ? [
                BoxShadow(
                  color: primary.withOpacity(.22),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: _sending
          ? const Padding(
              padding: EdgeInsets.all(14),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(
                  Colors.white,
                ),
              ),
            )
          : IconButton(
              onPressed:
                  hasText ? _sendMessage : null,
              icon: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 19,
              ),
            ),
    );
  },
),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// FORMAT MESSAGE TIME
  ///////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////
/// FORMAT MESSAGE TIME
////////////////////////////////////////////////////////////

String _formatMessageTime(
  dynamic timestamp,
) {
  DateTime date;

  try {
    date = timestamp.toDate();
  } catch (_) {
    return "";
  }

  final now = DateTime.now();

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

  return "${date.day}/${date.month}";
}
}