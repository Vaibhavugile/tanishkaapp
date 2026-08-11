import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderSummaryCard extends StatefulWidget {
  final String orderId;

  const OrderSummaryCard({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderSummaryCard> createState() =>
      _OrderSummaryCardState();
}

class _OrderSummaryCardState
    extends State<OrderSummaryCard> {

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

  static const Color softPink =
      Color(0xffFFF1F6);

  ///////////////////////////////////////////////////////////
  /// STATE
  ///////////////////////////////////////////////////////////

  bool _expanded = false;

  ///////////////////////////////////////////////////////////
  /// BUILD
  ///////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection("orderChats")
          .doc(widget.orderId)
          .collection("messages")
          .where(
            "type",
            isEqualTo: "order",
          )
          .limit(1)
          .snapshots(),

      builder: (
        context,
        snapshot,
      ) {
        ///////////////////////////////////////////////////////
        /// LOADING
        ///////////////////////////////////////////////////////

        if (snapshot.connectionState ==
                ConnectionState.waiting &&
            !snapshot.hasData) {
          return _buildLoading();
        }

        ///////////////////////////////////////////////////////
        /// ERROR
        ///////////////////////////////////////////////////////

        if (snapshot.hasError) {
          return _buildError();
        }

        ///////////////////////////////////////////////////////
        /// DATA
        ///////////////////////////////////////////////////////

        final docs =
            snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final message =
            docs.first.data();

        final rawSummary =
            message["orderSummary"];

        if (rawSummary == null ||
            rawSummary is! Map) {
          return const SizedBox.shrink();
        }

        final summary =
            Map<String, dynamic>.from(
          rawSummary,
        );

        final itemsCount =
            _toInt(
          summary["itemsCount"],
        );

        final subtotal =
            _toDouble(
          summary["subtotal"],
        );

        final shipping =
            _toDouble(
          summary["shippingFee"],
        );

        final total =
            _toDouble(
          summary["totalAmount"],
        );

        final orderStatus =
            (summary["orderStatus"] ??
                    "Placed")
                .toString();

        final paymentStatus =
            (summary["paymentStatus"] ??
                    "Pending")
                .toString();

        return _buildCard(
          context: context,
          itemsCount: itemsCount,
          subtotal: subtotal,
          shipping: shipping,
          total: total,
          orderStatus: orderStatus,
          paymentStatus: paymentStatus,
        );
      },
    );
  }

  ///////////////////////////////////////////////////////////
  /// CARD
  ///////////////////////////////////////////////////////////

  Widget _buildCard({
    required BuildContext context,
    required int itemsCount,
    required double subtotal,
    required double shipping,
    required double total,
    required String orderStatus,
    required String paymentStatus,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        6,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(.045),

            blurRadius: 22,

            offset:
                const Offset(0, 8),
          ),

          BoxShadow(
            color:
                primary.withOpacity(.025),

            blurRadius: 18,
          ),
        ],
      ),

      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(22),

        child: Column(
          children: [

            ///////////////////////////////////////////////////
            /// PINK ACCENT
            ///////////////////////////////////////////////////

            Container(
              height: 3,

              decoration:
                  const BoxDecoration(
                gradient:
                    LinearGradient(
                  colors: [
                    Color(0xffFF78AD),
                    Color(0xffE91E63),
                    Color(0xffC2185B),
                  ],
                ),
              ),
            ),

            ///////////////////////////////////////////////////
            /// CLICKABLE HEADER
            ///////////////////////////////////////////////////

            Material(
              color: Colors.transparent,

              child: InkWell(
                onTap: () {
                  setState(() {
                    _expanded =
                        !_expanded;
                  });
                },

                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),

                  child: Row(
                    children: [

                      //////////////////////////////////////////////////
                      /// ICON
                      //////////////////////////////////////////////////

                      Container(
                        width: 42,
                        height: 42,

                        decoration:
                            BoxDecoration(
                          gradient:
                              const LinearGradient(
                            colors: [
                              Color(0xffffd4e5),
                              Color(0xffE91E63),
                            ],

                            begin:
                                Alignment.topLeft,

                            end:
                                Alignment.bottomRight,
                          ),

                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),

                          boxShadow: [
                            BoxShadow(
                              color:
                                  primary.withOpacity(
                                .13,
                              ),

                              blurRadius: 12,

                              offset:
                                  const Offset(
                                0,
                                5,
                              ),
                            ),
                          ],
                        ),

                        child:
                            const Icon(
                          Icons
                              .shopping_bag_rounded,

                          color:
                              Colors.white,

                          size: 20,
                        ),
                      ),

                      const SizedBox(
                        width: 11,
                      ),

                      //////////////////////////////////////////////////
                      /// TITLE
                      //////////////////////////////////////////////////

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            Row(
                              children: [

                                const Text(
                                  "Order Summary",

                                  style:
                                      TextStyle(
                                    color:
                                        plum,

                                    fontSize:
                                        14,

                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),

                                const SizedBox(
                                  width: 6,
                                ),

                                Container(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),

                                  decoration:
                                      BoxDecoration(
                                    color:
                                        softPink,

                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      10,
                                    ),
                                  ),

                                  child:
                                      const Text(
                                    "ORDER",

                                    style:
                                        TextStyle(
                                      color:
                                          primary,

                                      fontSize:
                                          7,

                                      fontWeight:
                                          FontWeight.w900,

                                      letterSpacing:
                                          .4,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 3,
                            ),

                            Row(
                              children: [

                                Flexible(
                                  child: Text(
                                    "#${widget.orderId}",

                                    maxLines: 1,

                                    overflow:
                                        TextOverflow
                                            .ellipsis,

                                    style:
                                        const TextStyle(
                                      color:
                                          muted,

                                      fontSize:
                                          9,

                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  width: 6,
                                ),

                                Container(
                                  width: 3,
                                  height: 3,

                                  decoration:
                                      const BoxDecoration(
                                    color:
                                        Color(
                                      0xffCDB7C0,
                                    ),

                                    shape:
                                        BoxShape.circle,
                                  ),
                                ),

                                const SizedBox(
                                  width: 6,
                                ),

                                Text(
                                  "$itemsCount items",

                                  style:
                                      const TextStyle(
                                    color:
                                        muted,

                                    fontSize:
                                        9,

                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      //////////////////////////////////////////////////
                      /// TOTAL
                      //////////////////////////////////////////////////

                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.end,

                        children: [

                          Text(
                            _rupees(total),

                            style:
                                const TextStyle(
                              color:
                                  primary,

                              fontSize:
                                  15,

                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),

                          const SizedBox(
                            height: 2,
                          ),

                          Text(
                            orderStatus,

                            style:
                                TextStyle(
                              color:
                                  _orderStatusColor(
                                orderStatus,
                              ),

                              fontSize:
                                  8,

                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      //////////////////////////////////////////////////
                      /// ARROW
                      //////////////////////////////////////////////////

                      AnimatedRotation(
                        turns:
                            _expanded
                                ? .5
                                : 0,

                        duration:
                            const Duration(
                          milliseconds: 250,
                        ),

                        child:
                            const Icon(
                          Icons
                              .keyboard_arrow_down_rounded,

                          color:
                              muted,

                          size: 21,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            ///////////////////////////////////////////////////
            /// EXPANDABLE CONTENT
            ///////////////////////////////////////////////////

            AnimatedCrossFade(
              duration:
                  const Duration(
                milliseconds: 250,
              ),

              firstCurve:
                  Curves.easeOut,

              secondCurve:
                  Curves.easeIn,

              sizeCurve:
                  Curves.easeInOut,

              crossFadeState:
                  _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,

              firstChild:
                  const SizedBox(
                width: double.infinity,
                height: 0,
              ),

              secondChild:
                  _buildExpandedContent(
                itemsCount: itemsCount,
                subtotal: subtotal,
                shipping: shipping,
                total: total,
                orderStatus: orderStatus,
                paymentStatus: paymentStatus,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// EXPANDED CONTENT
  ///////////////////////////////////////////////////////////

  Widget _buildExpandedContent({
    required int itemsCount,
    required double subtotal,
    required double shipping,
    required double total,
    required String orderStatus,
    required String paymentStatus,
  }) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        14,
        0,
        14,
        14,
      ),

      child: Column(
        children: [

          Container(
            height: 1,

            color:
                const Color(0xffF3E8ED),
          ),

          const SizedBox(
            height: 12,
          ),

          ///////////////////////////////////////////////////////
          /// DETAILS
          ///////////////////////////////////////////////////////

          Container(
            padding:
                const EdgeInsets.all(12),

            decoration:
                BoxDecoration(
              color:
                  const Color(0xffFCF8FA),

              borderRadius:
                  BorderRadius.circular(16),

              border:
                  Border.all(
                color:
                    const Color(0xffF4E8EE),
              ),
            ),

            child: Column(
              children: [

                _detailRow(
                  icon:
                      Icons
                          .shopping_cart_outlined,

                  title:
                      "Items",

                  value:
                      "$itemsCount",
                ),

                const SizedBox(
                  height: 10,
                ),

                _detailRow(
                  icon:
                      Icons
                          .receipt_long_outlined,

                  title:
                      "Subtotal",

                  value:
                      _rupees(subtotal),
                ),

                const SizedBox(
                  height: 10,
                ),

                _detailRow(
                  icon:
                      Icons
                          .local_shipping_outlined,

                  title:
                      "Shipping",

                  value:
                      shipping == 0
                          ? "FREE"
                          : _rupees(
                              shipping,
                            ),

                  valueColor:
                      shipping == 0
                          ? const Color(
                              0xff2E7D32,
                            )
                          : plum,
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          ///////////////////////////////////////////////////////
          /// TOTAL
          ///////////////////////////////////////////////////////

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 11,
            ),

            decoration:
                BoxDecoration(
              gradient:
                  const LinearGradient(
                colors: [
                  Color(0xfffff1f6),
                  Color(0xfffff7fa),
                ],
              ),

              borderRadius:
                  BorderRadius.circular(16),
            ),

            child: Row(
              children: [

                const Expanded(
                  child: Text(
                    "Total Amount",

                    style:
                        TextStyle(
                      color:
                          plum,

                      fontSize:
                          11,

                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),

                Text(
                  _rupees(total),

                  style:
                      const TextStyle(
                    color:
                        primary,

                    fontSize:
                        18,

                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          ///////////////////////////////////////////////////////
          /// STATUS
          ///////////////////////////////////////////////////////

          Row(
            children: [

              Expanded(
                child:
                    _statusChip(
                  icon:
                      _orderStatusIcon(
                    orderStatus,
                  ),

                  text:
                      orderStatus,

                  color:
                      _orderStatusColor(
                    orderStatus,
                  ),
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              Expanded(
                child:
                    _statusChip(
                  icon:
                      _paymentStatusIcon(
                    paymentStatus,
                  ),

                  text:
                      paymentStatus,

                  color:
                      _paymentStatusColor(
                    paymentStatus,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// DETAIL ROW
  ///////////////////////////////////////////////////////////

  Widget _detailRow({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [

        Container(
          width: 30,
          height: 30,

          decoration:
              BoxDecoration(
            color:
                const Color(
              0xffffedf4,
            ),

            borderRadius:
                BorderRadius.circular(
              9,
            ),
          ),

          child: Icon(
            icon,

            size: 14,

            color:
                primary,
          ),
        ),

        const SizedBox(
          width: 9,
        ),

        Expanded(
          child: Text(
            title,

            style:
                const TextStyle(
              color:
                  muted,

              fontSize:
                  10.5,

              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),

        Text(
          value,

          style:
              TextStyle(
            color:
                valueColor ?? plum,

            fontSize:
                11,

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

  Widget _statusChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),

      decoration:
          BoxDecoration(
        color:
            color.withOpacity(.09),

        borderRadius:
            BorderRadius.circular(
          30,
        ),

        border:
            Border.all(
          color:
              color.withOpacity(.08),
        ),
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          Icon(
            icon,

            size: 12,

            color:
                color,
          ),

          const SizedBox(
            width: 4,
          ),

          Flexible(
            child: Text(
              text,

              maxLines: 1,

              overflow:
                  TextOverflow.ellipsis,

              style:
                  TextStyle(
                color:
                    color,

                fontSize:
                    8.5,

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
  /// STATUS COLORS
  ///////////////////////////////////////////////////////////

  Color _orderStatusColor(
    String status,
  ) {
    final value =
        status.toLowerCase();

    if (value.contains("cancel")) {
      return const Color(
        0xffC62828,
      );
    }

    if (value.contains("deliver")) {
      return const Color(
        0xff2E7D32,
      );
    }

    if (value.contains("ship")) {
      return const Color(
        0xff1565C0,
      );
    }

    if (value.contains("pack")) {
      return const Color(
        0xff7B1FA2,
      );
    }

    return const Color(
      0xffEF6C00,
    );
  }

  Color _paymentStatusColor(
    String status,
  ) {
    final value =
        status.toLowerCase();

    if (value.contains("paid") ||
        value.contains("verified") ||
        value.contains("complete")) {
      return const Color(
        0xff2E7D32,
      );
    }

    if (value.contains("failed") ||
        value.contains("cancel")) {
      return const Color(
        0xffC62828,
      );
    }

    return const Color(
      0xffEF6C00,
    );
  }

  ///////////////////////////////////////////////////////////
  /// ICONS
  ///////////////////////////////////////////////////////////

  IconData _orderStatusIcon(
    String status,
  ) {
    final value =
        status.toLowerCase();

    if (value.contains("cancel")) {
      return Icons.cancel_outlined;
    }

    if (value.contains("deliver")) {
      return Icons.check_circle_outline_rounded;
    }

    if (value.contains("ship")) {
      return Icons.local_shipping_outlined;
    }

    if (value.contains("pack")) {
      return Icons.inventory_2_outlined;
    }

    return Icons.pending_actions_rounded;
  }

  IconData _paymentStatusIcon(
    String status,
  ) {
    final value =
        status.toLowerCase();

    if (value.contains("paid") ||
        value.contains("verified") ||
        value.contains("complete")) {
      return Icons.check_circle_outline_rounded;
    }

    if (value.contains("failed") ||
        value.contains("cancel")) {
      return Icons.error_outline_rounded;
    }

    return Icons.schedule_rounded;
  }

  ///////////////////////////////////////////////////////////
  /// LOADING
  ///////////////////////////////////////////////////////////

  Widget _buildLoading() {
    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        6,
      ),

      height: 66,

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(.04),

            blurRadius: 18,

            offset:
                const Offset(0, 7),
          ),
        ],
      ),

      child: const Center(
        child:
            SizedBox(
          width: 22,
          height: 22,

          child:
              CircularProgressIndicator(
            strokeWidth: 2,

            valueColor:
                AlwaysStoppedAnimation<
                    Color>(
              primary,
            ),
          ),
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// ERROR
  ///////////////////////////////////////////////////////////

  Widget _buildError() {
    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        6,
      ),

      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(22),
      ),

      child: const Row(
        children: [

          Icon(
            Icons.error_outline_rounded,

            color:
                Color(0xffC62828),

            size: 20,
          ),

          SizedBox(
            width: 9,
          ),

          Expanded(
            child: Text(
              "Order summary unavailable",

              style:
                  TextStyle(
                color:
                    plum,

                fontSize:
                    11,

                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// RUPEES
  ///////////////////////////////////////////////////////////

  String _rupees(
    double value,
  ) {
    return "₹${value.toStringAsFixed(0)}";
  }

  ///////////////////////////////////////////////////////////
  /// DOUBLE
  ///////////////////////////////////////////////////////////

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
  /// INT
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
}