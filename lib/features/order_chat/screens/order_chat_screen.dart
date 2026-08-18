import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/order_chat_model.dart';
import '../../../models/chat_message_model.dart';
import '../../../services/order_chat_service.dart';
import 'package:tanishka/features/orders/screens/customer_packing_report_screen.dart';
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

  final ImagePicker _picker =
      ImagePicker();

  bool _sending = false;
  bool _uploadingProof = false;

  @override
  void initState() {
    super.initState();

    OrderChatService.instance.markAsRead(
      widget.chat.orderId,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // =========================================================
  // SEND NORMAL MESSAGE
  // =========================================================

  Future<void> _sendMessage() async {
    final text =
        _controller.text.trim();

    if (text.isEmpty || _sending) {
      return;
    }

    setState(() {
      _sending = true;
    });

    try {
      await OrderChatService.instance.sendMessage(
        orderId: widget.chat.orderId,
        text: text,
      );

      _controller.clear();
    } catch (e) {
      if (!mounted) return;

      _showError(
        "Unable to send message.",
      );

      debugPrint(
        "Send message error: $e",
      );
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  // =========================================================
  // PICK PAYMENT SCREENSHOT
  // =========================================================

  Future<void> _pickPaymentProof(
    ChatMessageModel message,
  ) async {
    if (_uploadingProof) {
      return;
    }

    final source =
        await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              24,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  "Upload Payment Proof",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xff44212E),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Choose how you want to upload your payment screenshot.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(
                      child: _sourceButton(
                        icon:
                            Icons.photo_library_rounded,
                        title: "Gallery",
                        source:
                            ImageSource.gallery,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _sourceButton(
                        icon:
                            Icons.camera_alt_rounded,
                        title: "Camera",
                        source:
                            ImageSource.camera,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) {
      return;
    }

    try {
      final XFile? file =
          await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (file == null) {
        return;
      }

      if (!mounted) return;

      await _submitPaymentProof(
        message,
        file,
      );
    } catch (e) {
      if (!mounted) return;

      _showError(
        "Unable to select screenshot.",
      );

      debugPrint(
        "Payment proof picker error: $e",
      );
    }
  }

  // =========================================================
  // SOURCE BUTTON
  // =========================================================

  Widget _sourceButton({
    required IconData icon,
    required String title,
    required ImageSource source,
  }) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(18),
      onTap: () {
        Navigator.pop(
          context,
          source,
        );
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color:
              const Color(0xffFFF5F9),
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color:
                const Color(0xffF3DCE5),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
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
              child: Icon(
                icon,
                color: Colors.white,
                size: 23,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              title,
              style: const TextStyle(
                fontWeight:
                    FontWeight.w800,
                color:
                    Color(0xff44212E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // UPLOAD PAYMENT PROOF
  // =========================================================

 Future<void> _submitPaymentProof(
  ChatMessageModel message,
  XFile file,
) async {
  if (_uploadingProof) {
    return;
  }

  setState(() {
    _uploadingProof = true;
  });

  try {
    final messageId = message.id;

    if (messageId.isEmpty) {
      throw Exception(
        "Payment message ID is missing.",
      );
    }

    await OrderChatService.instance
        .submitPaymentProof(
      orderId: widget.chat.orderId,
      messageId: messageId,
      imageFile: File(file.path),
    );

    if (!mounted) return;

    _showSuccess(
      "Payment proof submitted successfully.",
    );
  } catch (e) {
    debugPrint(
      "Payment proof error: $e",
    );

    if (!mounted) return;

    _showError(
      "Unable to submit payment proof.",
    );
  } finally {
    if (mounted) {
      setState(() {
        _uploadingProof = false;
      });
    }
  }
}

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xffFFF8FB),

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
              decoration:
                  const BoxDecoration(
                shape: BoxShape.circle,
                gradient:
                    LinearGradient(
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
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  Text(
                    widget.chat.orderStatus,
                    style: TextStyle(
                      color:
                          Colors.green.shade700,
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
          // ===================================================
          // MESSAGES
          // ===================================================

          Expanded(
            child: StreamBuilder<
                List<ChatMessageModel>>(
              stream:
                  OrderChatService.instance
                      .messagesStream(
                widget.chat.orderId,
              ),

              builder:
                  (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child:
                        CircularProgressIndicator(
                      color:
                          Color(0xffE91E63),
                    ),
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

          // ===================================================
          // INPUT
          // ===================================================

          SafeArea(
            child: Container(
              padding:
                  const EdgeInsets.all(12),

              decoration:
                  const BoxDecoration(
                color: Colors.white,
              ),

              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xffF7F4F6,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          30,
                        ),
                      ),

                      child: TextField(
                        controller:
                            _controller,

                        textInputAction:
                            TextInputAction.send,

                        onSubmitted: (_) {
                          _sendMessage();
                        },

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
                      100,
                    ),

                    onTap:
                        _sending
                            ? null
                            : _sendMessage,

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

                      child: _sending
                          ? const Padding(
                              padding:
                                  EdgeInsets.all(
                                16,
                              ),
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                    Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.send,
                              color:
                                  Colors.white,
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

  // =========================================================
  // MESSAGE ROUTER
  // =========================================================

 ///////////////////////////////////////////////////////////
/// MESSAGE ROUTER
///////////////////////////////////////////////////////////

Widget buildMessageBubble(
  ChatMessageModel message,
) {
  /////////////////////////////////////////////////////////
  /// ORDER
  /////////////////////////////////////////////////////////

  if (message.isOrder) {
    return _buildOrderCard(
      message,
    );
  }

  /////////////////////////////////////////////////////////
  /// PAYMENT
  /////////////////////////////////////////////////////////

  if (message.isPayment) {
    return _buildPaymentCard(
      message,
    );
  }

  /////////////////////////////////////////////////////////
  /// PACKING REPORT
  /////////////////////////////////////////////////////////

  if (message.isPacking) {
    final packing =
        message.packingData ?? {};

    if (packing["reportType"] ==
        "packing_report") {
      return _buildPackingReportCard(
        message,
      );
    }
  }

  /////////////////////////////////////////////////////////
  /// SHIPMENT
  /////////////////////////////////////////////////////////

  if (message.isShipment) {
    final shipment = message.shipmentData ?? {};

    if (shipment["reportType"] == "shipment") {
      return _buildShipmentCard(message);
    }
  }

  /////////////////////////////////////////////////////////
  /// NORMAL MESSAGE
  /////////////////////////////////////////////////////////

  final isMine =
      message.isCustomer;

  return Align(
    alignment: isMine
        ? Alignment.centerRight
        : Alignment.centerLeft,

    child: Container(
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),

      padding:
          const EdgeInsets.all(14),

      constraints:
          const BoxConstraints(
        maxWidth: 290,
      ),

      decoration:
          BoxDecoration(
        color: isMine
            ? const Color(0xffE91E63)
            : Colors.white,

        borderRadius:
            BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(.05),
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
///////////////////////////////////////////////////////////
/// SHIPMENT CARD
///////////////////////////////////////////////////////////

Widget _buildShipmentCard(
  ChatMessageModel message,
) {
  final shipment = message.shipmentData ?? {};

  final shipmentId =
      (shipment["shipmentId"] ?? "").toString().trim();

  final status =
      (shipment["status"] ?? "shipped").toString();

  final rawImages = shipment["packageImages"];
  final images = <String>[];

  if (rawImages is List) {
    for (final item in rawImages) {
      final url = item.toString().trim();
      if (url.isNotEmpty) images.add(url);
    }
  }

  final photoCount = images.isNotEmpty
      ? images.length
      : _toInt(shipment["photoCount"]);

  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: const Color(0xffE6DCE2),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.055),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xffDCC8E7),
                      Color(0xff7B3F98),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Shipment",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xff44212E),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      "Your order has been shipped",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff9B7B85),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xff2E7D32),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xffFAF6FC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.qr_code_2_rounded,
                  size: 20,
                  color: Color(0xff7B3F98),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "SHIPMENT ID",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .5,
                          color: Color(0xff9B7B85),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        shipmentId.isEmpty
                            ? "Not available"
                            : shipmentId,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Color(0xff44212E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (images.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.photo_library_outlined,
                  size: 17,
                  color: Color(0xff7B3F98),
                ),
                const SizedBox(width: 6),
                Text(
                  "$photoCount package photo"
                  "${photoCount == 1 ? '' : 's'}",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff44212E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            SizedBox(
              height: 105,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: 9),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      images[index],
                      width: 105,
                      height: 105,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(
                        width: 105,
                        height: 105,
                        color: const Color(0xffF7F2F5),
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 15),

          Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: Color(0xff2E7D32),
              ),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  "Shipment dispatched",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff44212E),
                  ),
                ),
              ),
              if (photoCount > 0)
                Text(
                  "$photoCount photo"
                  "${photoCount == 1 ? '' : 's'}",
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff9B7B85),
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
/// PACKING REPORT CARD
///////////////////////////////////////////////////////////

Widget _buildPackingReportCard(
  ChatMessageModel message,
) {
  final packing =
      message.packingData ?? {};

  final totalItems =
      _toInt(
    packing["totalItems"],
  );

  final receivedItems =
      _toInt(
    packing["receivedItems"],
  );

  final missingItems =
      _toInt(
    packing["missingItems"],
  );

  final confirmedItems =
      _toInt(
    packing["confirmedItems"],
  );

  final status =
      (packing["status"] ??
              "pending")
          .toString()
          .toLowerCase();

  final completed =
      status == "completed";

  return Container(
    width: double.infinity,

    margin:
        const EdgeInsets.only(
      bottom: 18,
    ),

    decoration:
        BoxDecoration(
      color: Colors.white,

      borderRadius:
          BorderRadius.circular(24),

      border: Border.all(
        color:
            const Color(0xffF1E2E8),
      ),

      boxShadow: [
        BoxShadow(
          color: Colors.black
              .withOpacity(.055),
          blurRadius: 20,
          offset:
              const Offset(0, 8),
        ),
      ],
    ),

    child: Padding(
      padding:
          const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          ///////////////////////////////////////////////////
          /// HEADER
          ///////////////////////////////////////////////////

          Row(
            children: [

              Container(
                width: 46,
                height: 46,

                decoration:
                    const BoxDecoration(
                  shape: BoxShape.circle,

                  gradient:
                      LinearGradient(
                    colors: [
                      Color(0xffFFCCE1),
                      Color(0xffE91E63),
                    ],
                  ),
                ),

                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),

              const SizedBox(
                width: 11,
              ),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      "Packing Report",
                      style:
                          TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w900,
                        color:
                            Color(0xff44212E),
                      ),
                    ),

                    SizedBox(
                      height: 3,
                    ),

                    Text(
                      "Your order packing summary",
                      style:
                          TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w600,
                        color:
                            Color(0xff9B7B85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 16,
          ),

          ///////////////////////////////////////////////////
          /// SUMMARY
          ///////////////////////////////////////////////////

          Container(
            padding:
                const EdgeInsets.all(12),

            decoration:
                BoxDecoration(
              color:
                  const Color(0xffFFF7FA),

              borderRadius:
                  BorderRadius.circular(16),
            ),

            child: Row(
              children: [

                Expanded(
                  child: _packingStat(
                    "Items",
                    totalItems,
                    Icons.inventory_2_outlined,
                  ),
                ),

                Expanded(
                  child: _packingStat(
                    "Received",
                    receivedItems,
                    Icons.check_circle_outline,
                  ),
                ),

                Expanded(
                  child: _packingStat(
                    "Missing",
                    missingItems,
                    Icons.warning_amber_rounded,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          ///////////////////////////////////////////////////
          /// CONFIRMED
          ///////////////////////////////////////////////////

          Row(
            children: [

              Icon(
                completed
                    ? Icons.check_circle_rounded
                    : Icons.pending_rounded,
                size: 18,
                color: completed
                    ? const Color(0xff2E7D32)
                    : const Color(0xffEF6C00),
              ),

              const SizedBox(
                width: 7,
              ),

              Expanded(
                child: Text(
                  "$confirmedItems / $totalItems items confirmed",
                  style:
                      const TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(0xff44212E),
                  ),
                ),
              ),

              Text(
                completed
                    ? "Completed"
                    : "In Progress",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w800,
                  color: completed
                      ? const Color(0xff2E7D32)
                      : const Color(0xffEF6C00),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 14,
          ),

          ///////////////////////////////////////////////////
          /// VIEW FULL REPORT
          ///////////////////////////////////////////////////

          SizedBox(
            width: double.infinity,
            height: 46,

            child: OutlinedButton.icon(
              onPressed: () {
                _openFullPackingReport(
                  message,
                );
              },

              icon: const Icon(
                Icons.arrow_forward_rounded,
                size: 18,
              ),

              label: const Text(
                "View Full Report",
              ),

              style:
                  OutlinedButton.styleFrom(
                foregroundColor:
                    const Color(0xffE91E63),

                side: const BorderSide(
                  color:
                      Color(0xffE91E63),
                ),

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),

                textStyle:
                    const TextStyle(
                  fontWeight:
                      FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
///////////////////////////////////////////////////////////
/// PACKING STAT
///////////////////////////////////////////////////////////

Widget _packingStat(
  String title,
  int value,
  IconData icon,
) {
  return Column(
    children: [

      Icon(
        icon,
        size: 18,
        color:
            const Color(0xffE91E63),
      ),

      const SizedBox(
        height: 5,
      ),

      Text(
        "$value",
        style:
            const TextStyle(
          fontSize: 16,
          fontWeight:
              FontWeight.w900,
          color:
              Color(0xff44212E),
        ),
      ),

      Text(
        title,
        style:
            const TextStyle(
          fontSize: 9,
          fontWeight:
              FontWeight.w700,
          color:
              Color(0xff9B7B85),
        ),
      ),
    ],
  );
}

  // =========================================================
  // PAYMENT CARD
  // =========================================================

  Widget _buildPaymentCard(
    ChatMessageModel message,
  ) {
    final payment =
        message.paymentData ?? {};

    final amount =
        _toDouble(
      payment["amount"],
    );

    final method =
        (payment["paymentMethod"] ??
                payment["paymentMethodName"] ??
                payment["method"] ??
                "Payment")
            .toString();

    final qr =
        (payment["qrImage"] ??
                payment["image"] ??
                payment["scannerImage"] ??
                "")
            .toString();

    final proof =
        (payment["paymentProofImage"] ??
                payment["screenshotUrl"] ??
                payment["screenshot"] ??
                "")
            .toString();

    final status =
        (payment["status"] ??
                "pending")
            .toString()
            .toLowerCase();

    final successful =
        status == "successful" ||
        status == "success" ||
        status == "paid";

    final proofSubmitted =
        status == "proof_submitted";

    return Container(
      width: double.infinity,

      margin:
          const EdgeInsets.only(
        bottom: 18,
      ),

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(26),

        border: Border.all(
          color:
              const Color(0xffF1E2E8),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(.055),
            blurRadius: 22,
            offset:
                const Offset(0, 9),
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
            // =================================================
            // HEADER
            // =================================================

            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration:
                      const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient:
                        LinearGradient(
                      colors: [
                        Color(0xffFFCCE1),
                        Color(0xffE91E63),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.payments_rounded,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Payment Request",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w900,
                          color:
                              Color(0xff44212E),
                        ),
                      ),

                      SizedBox(height: 3),

                      Text(
                        "Payment verification",
                        style: TextStyle(
                          fontSize: 11,
                          color:
                              Color(0xff9B7B85),
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // =================================================
            // AMOUNT
            // =================================================

            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.all(18),

              decoration:
                  BoxDecoration(
                color:
                    const Color(0xffFFF6FA),
                borderRadius:
                    BorderRadius.circular(18),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  const Text(
                    "AMOUNT TO PAY",
                    style: TextStyle(
                      color:
                          Color(0xff9B7B85),
                      fontSize: 10,
                      fontWeight:
                          FontWeight.w800,
                      letterSpacing: .5,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    "₹${amount.toStringAsFixed(0)}",
                    style:
                        const TextStyle(
                      color:
                          Color(0xffE91E63),
                      fontSize: 30,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 16,
                        color:
                            Color(0xff9B7B85),
                      ),

                      const SizedBox(width: 6),

                      Text(
                        method,
                        style:
                            const TextStyle(
                          color:
                              Color(0xff44212E),
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // =================================================
            // QR
            // =================================================

            if (qr.isNotEmpty &&
                !successful) ...[
              const SizedBox(height: 20),

              const Text(
                "Scan to Pay",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w900,
                  color:
                      Color(0xff44212E),
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Container(
                  width: 220,
                  height: 220,

                  padding:
                      const EdgeInsets.all(
                    10,
                  ),

                  decoration:
                      BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                    border: Border.all(
                      color:
                          const Color(
                        0xffF0E0E7,
                      ),
                    ),
                  ),

                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                    child: Image.network(
                      qr,
                      fit: BoxFit.contain,
                      errorBuilder:
                          (_, __, ___) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color:
                                Colors.grey,
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],

            // =================================================
            // SUCCESS
            // =================================================

            if (successful) ...[
              const SizedBox(height: 18),

              _statusBox(
                icon:
                    Icons.check_circle_rounded,
                title:
                    "Payment Successful",
                subtitle:
                    "Your payment has been verified.",
                color:
                    const Color(0xff2E7D32),
              ),
            ]

            // =================================================
            // PROOF SUBMITTED
            // =================================================

            else if (proofSubmitted) ...[
              const SizedBox(height: 18),

              _statusBox(
                icon:
                    Icons.hourglass_top_rounded,
                title:
                    "Payment Proof Submitted",
                subtitle:
                    "Our team is verifying your payment.",
                color:
                    const Color(0xffEF6C00),
              ),

              if (proof.isNotEmpty) ...[
                const SizedBox(height: 16),

                const Text(
                  "Your Screenshot",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w900,
                    color:
                        Color(0xff44212E),
                  ),
                ),

                const SizedBox(height: 10),

                _buildProofImage(
                  proof,
                ),
              ],
            ]

            // =================================================
            // PENDING
            // =================================================

            else ...[
              const SizedBox(height: 20),

              _statusBox(
                icon:
                    Icons.schedule_rounded,
                title:
                    "Payment Pending",
                subtitle:
                    "Complete the payment and upload your screenshot.",
                color:
                    const Color(0xffEF6C00),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton.icon(
                  onPressed:
                      _uploadingProof
                          ? null
                          : () {
                              _pickPaymentProof(
                                message,
                              );
                            },

                  icon:
                      _uploadingProof
                          ? const SizedBox(
                              width: 19,
                              height: 19,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                    Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons
                                  .cloud_upload_rounded,
                            ),

                  label: Text(
                    _uploadingProof
                        ? "Uploading..."
                        : "I've Paid — Upload Screenshot",
                  ),

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xffE91E63,
                    ),

                    foregroundColor:
                        Colors.white,

                    elevation: 0,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =========================================================
  // PAYMENT STATUS
  // =========================================================

  Widget _statusBox({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(14),

      decoration:
          BoxDecoration(
        color:
            color.withOpacity(.08),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              color.withOpacity(.16),
        ),
      ),

      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 25,
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight:
                        FontWeight.w900,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  style:
                      const TextStyle(
                    color:
                        Color(0xff6F6268),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // PROOF IMAGE
  // =========================================================

  Widget _buildProofImage(
    String url,
  ) {
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(18),

      child: Container(
        width: double.infinity,
        constraints:
            const BoxConstraints(
          maxHeight: 420,
        ),

        decoration:
            BoxDecoration(
          color:
              const Color(0xffF7F4F6),
          borderRadius:
              BorderRadius.circular(18),
        ),

        child: Image.network(
          url,
          fit: BoxFit.contain,

          loadingBuilder:
              (context, child, progress) {
            if (progress == null) {
              return child;
            }

            return const Padding(
              padding:
                  EdgeInsets.all(40),
              child:
                  CircularProgressIndicator(
                color:
                    Color(0xffE91E63),
              ),
            );
          },

          errorBuilder:
              (_, __, ___) {
            return const Padding(
              padding:
                  EdgeInsets.all(30),
              child: Icon(
                Icons.broken_image_outlined,
                size: 45,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }

  // =========================================================
  // ORDER CARD
  // =========================================================

  Widget _buildOrderCard(
    ChatMessageModel message,
  ) {
    final summary =
        message.orderSummary ?? {};

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 18,
      ),

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(26),

        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(.05),
            blurRadius: 20,
            offset:
                const Offset(0, 10),
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
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration:
                      BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
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

            const Divider(
              height: 28,
            ),

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
                  style:
                      const TextStyle(
                    color:
                        Color(0xffE91E63),
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

  // =========================================================
  // INFO ROW
  // =========================================================

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
          color:
              const Color(0xffE91E63),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(title),
        ),

        Text(
          value,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // STATUS CHIP
  // =========================================================

  Widget _statusChip(
    String text,
    Color color,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 7,
      ),

      decoration:
          BoxDecoration(
        color:
            color.withOpacity(.10),
        borderRadius:
            BorderRadius.circular(30),
      ),

      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }

  // =========================================================
  // DOUBLE
  // =========================================================

  double _toDouble(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? "",
        ) ??
        0;
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

  // =========================================================
  // SUCCESS
  // =========================================================

  void _showSuccess(
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
            const Color(0xff2E7D32),

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(16),
        ),

        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                message,
                style:
                    const TextStyle(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
///////////////////////////////////////////////////////////
/// OPEN FULL PACKING REPORT
///////////////////////////////////////////////////////////

void _openFullPackingReport(
  ChatMessageModel message,
) {
  final packing =
      message.packingData ?? {};

  final orderId =
      (packing["orderId"] ??
              widget.chat.orderId)
          .toString()
          .trim();

  if (orderId.isEmpty) {
    _showError(
      "Order ID is missing.",
    );
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>
          CustomerPackingReportScreen(
        orderId: orderId,
      ),
    ),
  );
}
  // =========================================================
  // ERROR
  // =========================================================

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
            const Color(0xffC62828),

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(16),
        ),

        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                message,
                style:
                    const TextStyle(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}