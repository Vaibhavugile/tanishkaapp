import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:tanishka/features/splash/widgets/luxury_background.dart';

import '../services/admin_order_service.dart';
import '../widgets/order_card.dart';
import 'admin_order_chat_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({
    super.key,
  });

  @override
  State<OrderListScreen> createState() =>
      _OrderListScreenState();
}

class _OrderListScreenState
    extends State<OrderListScreen> {
  ///////////////////////////////////////////////////////////
  /// SEARCH
  ///////////////////////////////////////////////////////////

  final TextEditingController _searchController =
      TextEditingController();

  final FocusNode _searchFocusNode =
      FocusNode();

  String _searchQuery = "";

  ///////////////////////////////////////////////////////////
  /// FILTERS
  ///////////////////////////////////////////////////////////

  String _selectedOrderStatus = "All";

  String _selectedPaymentStatus = "All";

  bool _unreadOnly = false;

  ///////////////////////////////////////////////////////////
  /// INIT
  ///////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();

    _searchController.addListener(
      _onSearchChanged,
    );
  }

  ///////////////////////////////////////////////////////////
  /// DISPOSE
  ///////////////////////////////////////////////////////////

  @override
  void dispose() {
    _searchController.removeListener(
      _onSearchChanged,
    );

    _searchController.dispose();
    _searchFocusNode.dispose();

    super.dispose();
  }

  ///////////////////////////////////////////////////////////
  /// SEARCH
  ///////////////////////////////////////////////////////////

  void _onSearchChanged() {
    final value =
        _searchController.text.trim();

    if (value == _searchQuery) {
      return;
    }

    setState(() {
      _searchQuery = value;
    });
  }

  ///////////////////////////////////////////////////////////
  /// ACTIVE FILTERS
  ///////////////////////////////////////////////////////////

  bool get _hasActiveFilters {
    return _searchQuery.isNotEmpty ||
        _selectedOrderStatus != "All" ||
        _selectedPaymentStatus != "All" ||
        _unreadOnly;
  }

  ///////////////////////////////////////////////////////////
  /// CLEAR FILTERS
  ///////////////////////////////////////////////////////////

  void _clearFilters() {
    _searchController.clear();

    _searchFocusNode.unfocus();

    setState(() {
      _searchQuery = "";
      _selectedOrderStatus = "All";
      _selectedPaymentStatus = "All";
      _unreadOnly = false;
    });
  }

  ///////////////////////////////////////////////////////////
  /// FILTER ORDERS
  ///////////////////////////////////////////////////////////

  List<QueryDocumentSnapshot<Map<String, dynamic>>>
      _filterOrders(
    List<QueryDocumentSnapshot<Map<String, dynamic>>>
        docs,
  ) {
    final search =
        _searchQuery.toLowerCase().trim();

    return docs.where((doc) {
      final data = doc.data();

      final customerName =
          (data["customerName"] ?? "")
              .toString()
              .toLowerCase();

      final customerPhone =
          (data["customerPhone"] ?? "")
              .toString()
              .toLowerCase();

      final orderId =
          (data["orderId"] ?? doc.id)
              .toString()
              .toLowerCase();

      final lastMessage =
          (data["lastMessage"] ?? "")
              .toString()
              .toLowerCase();

      final orderStatus =
          (data["orderStatus"] ?? "")
              .toString();

      final paymentStatus =
          (data["paymentStatus"] ?? "")
              .toString();

      final unreadAdmin =
          _toInt(
        data["unreadAdmin"],
      );

      /////////////////////////////////////////////////////////
      /// SEARCH
      /////////////////////////////////////////////////////////

      if (search.isNotEmpty) {
        final matches =
            customerName.contains(search) ||
            customerPhone.contains(search) ||
            orderId.contains(search) ||
            lastMessage.contains(search);

        if (!matches) {
          return false;
        }
      }

      /////////////////////////////////////////////////////////
      /// ORDER STATUS
      /////////////////////////////////////////////////////////

      if (_selectedOrderStatus != "All") {
        if (orderStatus.toLowerCase() !=
            _selectedOrderStatus.toLowerCase()) {
          return false;
        }
      }

      /////////////////////////////////////////////////////////
      /// PAYMENT STATUS
      /////////////////////////////////////////////////////////

      if (_selectedPaymentStatus != "All") {
        if (paymentStatus.toLowerCase() !=
            _selectedPaymentStatus.toLowerCase()) {
          return false;
        }
      }

      /////////////////////////////////////////////////////////
      /// UNREAD
      /////////////////////////////////////////////////////////

      if (_unreadOnly && unreadAdmin <= 0) {
        return false;
      }

      return true;
    }).toList();
  }

  ///////////////////////////////////////////////////////////
  /// OPEN ORDER
  ///////////////////////////////////////////////////////////

  void _openOrder(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>>
        order,
  ) {
    final data = order.data();

    final orderId =
        (data["orderId"] ?? order.id)
            .toString();

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

  ///////////////////////////////////////////////////////////
  /// BUILD
  ///////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: LuxuryBackground(
        child: SafeArea(
          child: Column(
            children: [

              //////////////////////////////////////////////////
              /// PREMIUM HEADER
              //////////////////////////////////////////////////

              _buildHeader(),

              //////////////////////////////////////////////////
              /// SEARCH + FILTERS
              //////////////////////////////////////////////////

              _buildSearchSection(),

              //////////////////////////////////////////////////
              /// ORDERS
              //////////////////////////////////////////////////

              Expanded(
                child: StreamBuilder<
                    QuerySnapshot<
                        Map<String, dynamic>>>(
                  stream:
                      AdminOrderService
                          .instance
                          .latestOrderChats(),

                  builder: (
                    context,
                    snapshot,
                  ) {
                    //////////////////////////////////////////////////
                    /// LOADING
                    //////////////////////////////////////////////////

                    if (snapshot
                            .connectionState ==
                        ConnectionState.waiting) {
                      return _buildLoading();
                    }

                    //////////////////////////////////////////////////
                    /// ERROR
                    //////////////////////////////////////////////////

                    if (snapshot.hasError) {
                      return _buildError();
                    }

                    //////////////////////////////////////////////////
                    /// DATA
                    //////////////////////////////////////////////////

                    final docs =
                        snapshot.data?.docs ?? [];

                    //////////////////////////////////////////////////
                    /// EMPTY
                    //////////////////////////////////////////////////

                    if (docs.isEmpty) {
                      return _buildEmptyState(
                        filtered: false,
                      );
                    }

                    //////////////////////////////////////////////////
                    /// FILTER
                    //////////////////////////////////////////////////

                    final filtered =
                        _filterOrders(docs);

                    //////////////////////////////////////////////////
                    /// FILTERED EMPTY
                    //////////////////////////////////////////////////

                    if (filtered.isEmpty) {
                      return _buildEmptyState(
                        filtered: true,
                      );
                    }

                    //////////////////////////////////////////////////
                    /// LIST
                    //////////////////////////////////////////////////

                    return RefreshIndicator(
                      color:
                          const Color(
                        0xffE91E63,
                      ),

                      backgroundColor:
                          Colors.white,

                      onRefresh: () async {
                        await AdminOrderService
                            .instance
                            .refresh();
                      },

                      child:
                          CustomScrollView(
                        physics:
                            const AlwaysScrollableScrollPhysics(
                          parent:
                              BouncingScrollPhysics(),
                        ),

                        slivers: [

                          //////////////////////////////////////////////////
                          /// RESULT HEADER
                          //////////////////////////////////////////////////

                          SliverToBoxAdapter(
                            child:
                                _buildResultHeader(
                              total:
                                  docs.length,
                              visible:
                                  filtered.length,
                            ),
                          ),

                          //////////////////////////////////////////////////
                          /// ORDER LIST
                          //////////////////////////////////////////////////

                          SliverPadding(
                            padding:
                                const EdgeInsets
                                    .fromLTRB(
                              20,
                              4,
                              20,
                              120,
                            ),

                            sliver:
                                SliverList(
                              delegate:
                                  SliverChildBuilderDelegate(
                                (
                                  context,
                                  index,
                                ) {
                                  final order =
                                      filtered[index];

                                  return Padding(
                                    padding:
                                        const EdgeInsets
                                            .only(
                                      bottom: 16,
                                    ),
                                    child:
                                        OrderCard(
                                      order:
                                          order,
                                      onTap: () {
                                        _openOrder(
                                          context,
                                          order,
                                        );
                                      },
                                    ),
                                  );
                                },
                                childCount:
                                    filtered.length,
                              ),
                            ),
                          ),
                        ],
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

  ///////////////////////////////////////////////////////////
  /// PREMIUM HEADER
  ///////////////////////////////////////////////////////////

  Widget _buildHeader() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        14,
      ),
      child: Row(
        children: [

          //////////////////////////////////////////////////
          /// BACK BUTTON
          //////////////////////////////////////////////////

          Container(
            width: 48,
            height: 48,
            decoration:
                BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                16,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black
                          .withOpacity(.05),
                  blurRadius: 18,
                  offset:
                      const Offset(0, 7),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              icon:
                  const Icon(
                Icons
                    .arrow_back_ios_new_rounded,
                size: 18,
                color:
                    Color(0xff44212E),
              ),
            ),
          ),

          const SizedBox(
            width: 14,
          ),

          //////////////////////////////////////////////////
          /// TITLE
          //////////////////////////////////////////////////

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: const [

                Text(
                  "Orders",
                  style:
                      TextStyle(
                    fontSize: 26,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(0xff44212E),
                  ),
                ),

                SizedBox(
                  height: 4,
                ),

                Text(
                  "Manage customer orders",
                  style:
                      TextStyle(
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

          //////////////////////////////////////////////////
          /// LIVE INDICATOR
          //////////////////////////////////////////////////

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 8,
            ),
            decoration:
                BoxDecoration(
              color:
                  Colors.white,
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black
                          .withOpacity(.045),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: [

                Container(
                  width: 7,
                  height: 7,
                  decoration:
                      const BoxDecoration(
                    color:
                        Color(0xff28A745),
                    shape:
                        BoxShape.circle,
                  ),
                ),

                const SizedBox(
                  width: 6,
                ),

                const Text(
                  "LIVE",
                  style:
                      TextStyle(
                    color:
                        Color(0xff44212E),
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
    );
  }

  ///////////////////////////////////////////////////////////
  /// SEARCH SECTION
  ///////////////////////////////////////////////////////////

  Widget _buildSearchSection() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        12,
      ),
      child: Column(
        children: [

          //////////////////////////////////////////////////
          /// SEARCH
          //////////////////////////////////////////////////

          Container(
            height: 54,
            decoration:
                BoxDecoration(
              color:
                  Colors.white,
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      const Color(
                    0xffD79AB1,
                  ).withOpacity(.12),
                  blurRadius: 22,
                  offset:
                      const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [

                const SizedBox(
                  width: 17,
                ),

                Container(
                  width: 34,
                  height: 34,
                  decoration:
                      BoxDecoration(
                    gradient:
                        const LinearGradient(
                      colors: [
                        Color(0xffFFE8F2),
                        Color(0xffF8D7E5),
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      11,
                    ),
                  ),
                  child:
                      const Icon(
                    Icons.search_rounded,
                    size: 19,
                    color:
                        Color(0xff7A294D),
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: TextField(
                    controller:
                        _searchController,
                    focusNode:
                        _searchFocusNode,
                    decoration:
                        const InputDecoration(
                      hintText:
                          "Search order, customer or phone",
                      hintStyle:
                          TextStyle(
                        color:
                            Color(0xffB19CA5),
                        fontSize: 12,
                      ),
                      border:
                          InputBorder.none,
                    ),
                  ),
                ),

                if (_searchQuery
                    .isNotEmpty)
                  IconButton(
                    onPressed: () {
                      _searchController
                          .clear();

                      _searchFocusNode
                          .unfocus();
                    },
                    icon:
                        const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color:
                          Color(0xff9B7B85),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          //////////////////////////////////////////////////
          /// FILTERS
          //////////////////////////////////////////////////

          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection:
                  Axis.horizontal,
              physics:
                  const BouncingScrollPhysics(),
              children: [

  // =========================================================
  // ALL
  // =========================================================

  _filterChip(
    "All",
    selected: !_hasStatusFilter,
    onTap: () {
      setState(() {
        _selectedOrderStatus = "All";
        _selectedPaymentStatus = "All";
        _unreadOnly = false;
      });
    },
  ),

  const SizedBox(width: 8),

  // =========================================================
  // UNREAD
  // =========================================================

  _filterChip(
    "Unread",
    selected: _unreadOnly,
    icon: Icons.mark_chat_unread_outlined,
    onTap: () {
      setState(() {
        _unreadOnly = !_unreadOnly;
      });
    },
  ),

  const SizedBox(width: 8),

  // =========================================================
  // PLACED
  // =========================================================

  _filterChip(
    "Placed",
    selected: _selectedOrderStatus == "Placed",
    onTap: () {
      _selectOrderStatus("Placed");
    },
  ),

  const SizedBox(width: 8),

  // =========================================================
  // PAID
  // =========================================================

  _filterChip(
    "Paid",
    selected: _selectedOrderStatus == "Paid",
    icon: Icons.check_circle_outline,
    onTap: () {
      _selectOrderStatus("Paid");
    },
  ),

  const SizedBox(width: 8),

  // =========================================================
  // PACKED
  // =========================================================

  _filterChip(
    "Packed",
    selected: _selectedOrderStatus == "Packed",
    icon: Icons.inventory_2_outlined,
    onTap: () {
      _selectOrderStatus("Packed");
    },
  ),

  const SizedBox(width: 8),

  // =========================================================
  // SHIPPED
  // =========================================================

  _filterChip(
    "Shipped",
    selected: _selectedOrderStatus == "Shipped",
    icon: Icons.local_shipping_outlined,
    onTap: () {
      _selectOrderStatus("Shipped");
    },
  ),

  const SizedBox(width: 8),

  // =========================================================
  // DELIVERED
  // =========================================================

  _filterChip(
    "Delivered",
    selected: _selectedOrderStatus == "Delivered",
    icon: Icons.done_all_rounded,
    onTap: () {
      _selectOrderStatus("Delivered");
    },
  ),

  const SizedBox(width: 8),

  // =========================================================
  // CANCELLED
  // =========================================================

  _filterChip(
    "Cancelled",
    selected: _selectedOrderStatus == "Cancelled",
    icon: Icons.cancel_outlined,
    onTap: () {
      _selectOrderStatus("Cancelled");
    },
  ),

  const SizedBox(width: 8),

  // =========================================================
  // PAYMENT PENDING
  // =========================================================

  _filterChip(
    "Payment Pending",
    icon: Icons.payments_outlined,
    selected: _selectedPaymentStatus == "Pending",
    onTap: () {
      _selectPaymentStatus("Pending");
    },
  ),
],
            ),
          ),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// FILTER CHIP
  ///////////////////////////////////////////////////////////

  Widget _filterChip(
    String label, {
    required bool selected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child:
          AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 200,
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
        ),
        decoration:
            BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [
                    Color(0xffE91E63),
                    Color(0xffC2185B),
                  ],
                )
              : null,
          color: selected
              ? null
              : Colors.white,
          borderRadius:
              BorderRadius.circular(
            22,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color:
                        const Color(
                      0xffE91E63,
                    ).withOpacity(.20),
                    blurRadius: 14,
                    offset:
                        const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color:
                        Colors.black
                            .withOpacity(.035),
                    blurRadius: 12,
                  ),
                ],
        ),
        child: Row(
          mainAxisSize:
              MainAxisSize.min,
          children: [

            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: selected
                    ? Colors.white
                    : const Color(
                        0xff7A294D,
                      ),
              ),
              const SizedBox(
                width: 5,
              ),
            ],

            Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : const Color(
                        0xff6E5A63,
                      ),
                fontSize: 11,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// SELECT ORDER STATUS
  ///////////////////////////////////////////////////////////

  void _selectOrderStatus(
    String status,
  ) {
    setState(() {
      if (_selectedOrderStatus ==
          status) {
        _selectedOrderStatus =
            "All";
      } else {
        _selectedOrderStatus =
            status;

        _selectedPaymentStatus =
            "All";
      }
    });
  }

  ///////////////////////////////////////////////////////////
  /// SELECT PAYMENT STATUS
  ///////////////////////////////////////////////////////////

  void _selectPaymentStatus(
    String status,
  ) {
    setState(() {
      if (_selectedPaymentStatus ==
          status) {
        _selectedPaymentStatus =
            "All";
      } else {
        _selectedPaymentStatus =
            status;

        _selectedOrderStatus =
            "All";
      }
    });
  }

  ///////////////////////////////////////////////////////////
  /// STATUS FILTER
  ///////////////////////////////////////////////////////////

  bool get _hasStatusFilter {
    return _selectedOrderStatus !=
            "All" ||
        _selectedPaymentStatus !=
            "All" ||
        _unreadOnly;
  }

  ///////////////////////////////////////////////////////////
  /// RESULT HEADER
  ///////////////////////////////////////////////////////////

  Widget _buildResultHeader({
    required int total,
    required int visible,
  }) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        22,
        8,
        22,
        8,
      ),
      child: Row(
        children: [

          Container(
            width: 30,
            height: 30,
            decoration:
                BoxDecoration(
              gradient:
                  const LinearGradient(
                colors: [
                  Color(0xffFFE8F2),
                  Color(0xffF8D7E5),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),
            child:
                const Icon(
              Icons.shopping_bag_outlined,
              size: 15,
              color:
                  Color(0xff7A294D),
            ),
          ),

          const SizedBox(
            width: 9,
          ),

          Text(
            _hasActiveFilters
                ? "$visible matching orders"
                : "$visible recent orders",
            style:
                const TextStyle(
              color:
                  Color(0xff6E5A63),
              fontSize: 12,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const Spacer(),

          if (_hasActiveFilters)
            GestureDetector(
              onTap:
                  _clearFilters,
              child:
                  const Text(
                "Clear",
                style:
                    TextStyle(
                  color:
                      Color(0xffE91E63),
                  fontSize: 11,
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
  /// LOADING
  ///////////////////////////////////////////////////////////

  Widget _buildLoading() {
    return ListView.builder(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        100,
      ),
      itemCount: 5,
      itemBuilder: (
        context,
        index,
      ) {
        return Padding(
          padding:
              const EdgeInsets.only(
            bottom: 16,
          ),
          child:
              _LoadingCard(),
        );
      },
    );
  }

  ///////////////////////////////////////////////////////////
  /// ERROR
  ///////////////////////////////////////////////////////////

  Widget _buildError() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [

            Container(
              width: 90,
              height: 90,
              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,
                gradient:
                    const LinearGradient(
                  colors: [
                    Color(0xffffe5ee),
                    Color(0xffF8D7E5),
                  ],
                ),
              ),
              child:
                  const Icon(
                Icons
                    .cloud_off_rounded,
                color:
                    Color(0xffE91E63),
                size: 38,
              ),
            ),

            const SizedBox(
              height: 22,
            ),

            const Text(
              "Unable to load orders",
              style:
                  TextStyle(
                fontSize: 19,
                fontWeight:
                    FontWeight.w800,
                color:
                    Color(0xff44212E),
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              "Please check your connection and try again.",
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                color:
                    Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// EMPTY
  ///////////////////////////////////////////////////////////

  Widget _buildEmptyState({
    required bool filtered,
  }) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(28),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
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
                    Color(0xffFFE8F2),
                    Color(0xffF8D7E5),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        const Color(
                      0xffE91E63,
                    ).withOpacity(.10),
                    blurRadius: 30,
                  ),
                ],
              ),
              child:
                  Icon(
                filtered
                    ? Icons
                        .filter_alt_off_outlined
                    : Icons
                        .shopping_bag_outlined,
                size: 55,
                color:
                    const Color(
                  0xffE91E63,
                ),
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            Text(
              filtered
                  ? "No Matching Orders"
                  : "No Orders Yet",
              style:
                  const TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
                color:
                    Color(0xff44212E),
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              filtered
                  ? "Try changing your search or filters."
                  : "Flutter App orders will appear here.",
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                height: 1.6,
                fontSize: 14,
                color:
                    Color(0xff8F7984),
              ),
            ),

            if (filtered) ...[
              const SizedBox(
                height: 18,
              ),
              TextButton(
                onPressed:
                    _clearFilters,
                child:
                    const Text(
                  "Clear all filters",
                  style:
                      TextStyle(
                    color:
                        Color(0xffE91E63),
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////
/// LOADING CARD
///////////////////////////////////////////////////////////////

class _LoadingCard
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 165,
      padding:
          const EdgeInsets.all(18),
      decoration:
          BoxDecoration(
        color:
            Colors.white.withOpacity(.92),
        borderRadius:
            BorderRadius.circular(
          28,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black
                    .withOpacity(.045),
            blurRadius: 28,
            offset:
                const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [

          Container(
            width: 62,
            height: 62,
            decoration:
                BoxDecoration(
              gradient:
                  const LinearGradient(
                colors: [
                  Color(0xffFFE8F2),
                  Color(0xffF8D7E5),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),
          ),

          const SizedBox(
            width: 16,
          ),

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                _loadingLine(
                  150,
                  13,
                ),

                const SizedBox(
                  height: 10,
                ),

                _loadingLine(
                  100,
                  10,
                ),

                const SizedBox(
                  height: 14,
                ),

                Row(
                  children: [
                    _loadingLine(
                      65,
                      24,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    _loadingLine(
                      90,
                      24,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingLine(
    double width,
    double height,
  ) {
    return Container(
      width: width,
      height: height,
      decoration:
          BoxDecoration(
        color:
            const Color(0xffF4EDF1),
        borderRadius:
            BorderRadius.circular(
          8,
        ),
      ),
    );
  }
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