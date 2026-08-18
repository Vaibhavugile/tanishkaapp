import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../admin/orders/services/admin_order_service.dart';
class CustomerPackingReportScreen extends StatefulWidget {
  final String orderId;

  const CustomerPackingReportScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<CustomerPackingReportScreen> createState() =>
      _CustomerPackingReportScreenState();
}

class _CustomerPackingReportScreenState
    extends State<CustomerPackingReportScreen> {
  ///////////////////////////////////////////////////////////
  /// STATE
  ///////////////////////////////////////////////////////////

  bool _isLoading = true;

  String? _error;

  List<Map<String, dynamic>> _items = [];

  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';

  ///////////////////////////////////////////////////////////
  /// INIT
  ///////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      if (!mounted) return;

      setState(() {
        _searchQuery =
            _searchController.text.trim().toLowerCase();
      });
    });

    _loadReport();
  }

  ///////////////////////////////////////////////////////////
  /// DISPOSE
  ///////////////////////////////////////////////////////////

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  ///////////////////////////////////////////////////////////
  /// LOAD REPORT
  ///////////////////////////////////////////////////////////

  Future<void> _loadReport() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      /////////////////////////////////////////////////////////
      /// ORIGINAL ORDER ITEMS
      /////////////////////////////////////////////////////////

      final originalItems =
          await AdminOrderService.instance
              .getOrderItems(widget.orderId);

      /////////////////////////////////////////////////////////
      /// SAVED PACKING DATA
      /////////////////////////////////////////////////////////

      final packingData =
          await AdminOrderService.instance
              .getPackingData(widget.orderId);

      final rawPackingItems =
          packingData["items"];

      final List<dynamic> savedPackingItems =
          rawPackingItems is List
              ? rawPackingItems
              : [];

      /////////////////////////////////////////////////////////
      /// MERGED ITEMS
      /////////////////////////////////////////////////////////

      final mergedItems =
          <Map<String, dynamic>>[];

      for (
        int index = 0;
        index < originalItems.length;
        index++
      ) {
        final original =
            Map<String, dynamic>.from(
          originalItems[index],
        );

        ///////////////////////////////////////////////////////
        /// ORDERED
        ///////////////////////////////////////////////////////

        final ordered =
            _toInt(
          original["quantity"],
        );

        original["orderedQuantity"] =
            ordered;

        ///////////////////////////////////////////////////////
        /// DEFAULTS
        ///////////////////////////////////////////////////////

        int received = 0;
        int missing = 0;

        String packingStatus = "";

        ///////////////////////////////////////////////////////
        /// SAVED PACKING ITEM
        ///////////////////////////////////////////////////////

        if (index <
            savedPackingItems.length) {
          final saved =
              savedPackingItems[index];

          if (saved is Map) {
            final savedMap =
                Map<String, dynamic>.from(
              saved,
            );

            ///////////////////////////////////////////////////
            /// PRODUCT CODE
            ///////////////////////////////////////////////////

            if (savedMap["productCode"] != null) {
              original["productCode"] =
                  savedMap["productCode"];
            }

            ///////////////////////////////////////////////////
            /// VARIANT
            ///////////////////////////////////////////////////

            if (savedMap["variant"] != null) {
              original["variationLabel"] =
                  savedMap["variant"];
            }

            ///////////////////////////////////////////////////
            /// OLD QUANTITY SUPPORT
            ///////////////////////////////////////////////////

            if (savedMap["quantity"] != null) {
              received =
                  _toInt(
                savedMap["quantity"],
              );
            }

            ///////////////////////////////////////////////////
            /// RECEIVED
            ///////////////////////////////////////////////////

            if (savedMap["receivedQuantity"] != null) {
              received =
                  _toInt(
                savedMap["receivedQuantity"],
              );
            }

            ///////////////////////////////////////////////////
            /// MISSING
            ///////////////////////////////////////////////////

            if (savedMap["missingQuantity"] != null) {
              missing =
                  _toInt(
                savedMap["missingQuantity"],
              );
            }

            ///////////////////////////////////////////////////
            /// NOTE
            ///////////////////////////////////////////////////

            if (savedMap["adminNote"] != null) {
              original["adminNote"] =
                  savedMap["adminNote"];
            }

            ///////////////////////////////////////////////////
            /// STATUS
            ///////////////////////////////////////////////////

            packingStatus =
                (
                  savedMap["status"] ??
                      savedMap["packingStatus"] ??
                      ""
                )
                    .toString()
                    .trim();

            ///////////////////////////////////////////////////
            /// CONFIRMED BY
            ///////////////////////////////////////////////////

            if (savedMap["confirmedBy"] != null) {
              original["confirmedBy"] =
                  savedMap["confirmedBy"];
            }

            ///////////////////////////////////////////////////
            /// CONFIRMED AT
            ///////////////////////////////////////////////////

            if (savedMap["confirmedAt"] != null) {
              original["confirmedAt"] =
                  savedMap["confirmedAt"];
            }

            ///////////////////////////////////////////////////
            /// UPDATED BY
            ///////////////////////////////////////////////////

            if (savedMap["updatedBy"] != null) {
              original["updatedBy"] =
                  savedMap["updatedBy"];
            }

            ///////////////////////////////////////////////////
            /// UPDATED AT
            ///////////////////////////////////////////////////

            if (savedMap["updatedAt"] != null) {
              original["updatedAt"] =
                  savedMap["updatedAt"];
            }
          }
        }

        ///////////////////////////////////////////////////////
        /// SANITIZE
        ///////////////////////////////////////////////////////

        if (received < 0) {
          received = 0;
        }

        if (missing < 0) {
          missing = 0;
        }

        if (received > ordered) {
          received = ordered;
        }

        if (missing > ordered) {
          missing = ordered;
        }

        ///////////////////////////////////////////////////////
        /// NEVER EXCEED ORDERED
        ///////////////////////////////////////////////////////

        if (received + missing > ordered) {
          missing =
              ordered - received;

          if (missing < 0) {
            missing = 0;
          }
        }

        ///////////////////////////////////////////////////////
        /// STORE
        ///////////////////////////////////////////////////////

        original["receivedQuantity"] =
            received;

        original["missingQuantity"] =
            missing;

        original["packingStatus"] =
            packingStatus;

        mergedItems.add(
          original,
        );
      }

      /////////////////////////////////////////////////////////
      /// SET STATE
      /////////////////////////////////////////////////////////

      if (!mounted) return;

      setState(() {
        _items = mergedItems;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error =
            "Failed to load packing report.";
      });
    }
  }

  ///////////////////////////////////////////////////////////
  /// INTEGER
  ///////////////////////////////////////////////////////////

  int _toInt(dynamic value) {
    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  ///////////////////////////////////////////////////////////
  /// ORDERED
  ///////////////////////////////////////////////////////////

  int _orderedQuantity(
    Map<String, dynamic> item,
  ) {
    return _toInt(
      item["orderedQuantity"] ??
          item["quantity"],
    );
  }

  ///////////////////////////////////////////////////////////
  /// RECEIVED
  ///////////////////////////////////////////////////////////

  int _receivedQuantity(
    Map<String, dynamic> item,
  ) {
    return _toInt(
      item["receivedQuantity"],
    );
  }

  ///////////////////////////////////////////////////////////
  /// MISSING
  ///////////////////////////////////////////////////////////

  int _missingQuantity(
    Map<String, dynamic> item,
  ) {
    return _toInt(
      item["missingQuantity"],
    );
  }

  ///////////////////////////////////////////////////////////
  /// CONFIRMED
  ///////////////////////////////////////////////////////////

  bool _isConfirmed(
    Map<String, dynamic> item,
  ) {
    final status =
        (item["packingStatus"] ?? "")
            .toString()
            .trim()
            .toLowerCase();

    return status == "confirmed";
  }

  ///////////////////////////////////////////////////////////
  /// VARIANT
  ///////////////////////////////////////////////////////////

  String _getVariant(
    Map<String, dynamic> item,
  ) {
    final packingVariant =
        (item["packingVariant"] ?? "")
            .toString()
            .trim();

    if (packingVariant.isNotEmpty) {
      return packingVariant;
    }

    final variationLabel =
        (item["variationLabel"] ?? "")
            .toString()
            .trim();

    if (variationLabel.isNotEmpty) {
      return variationLabel;
    }

    final variation =
        item["variation"];

    if (variation is Map) {
      return variation.entries
          .map(
            (entry) =>
                "${entry.key}: ${entry.value}",
          )
          .join(" / ");
    }

    return "No variant";
  }

  ///////////////////////////////////////////////////////////
  /// PRODUCT NAME
  ///////////////////////////////////////////////////////////

  String _getProductName(
    Map<String, dynamic> item,
  ) {
    final possibleNames = [
      item["productName"],
      item["name"],
      item["title"],
      item["productTitle"],
    ];

    for (final value in possibleNames) {
      final text =
          (value ?? "")
              .toString()
              .trim();

      if (text.isNotEmpty) {
        return text;
      }
    }

    return "Product";
  }

  ///////////////////////////////////////////////////////////
  /// PRODUCT CODE
  ///////////////////////////////////////////////////////////

  String _getProductCode(
    Map<String, dynamic> item,
  ) {
    final value =
        (item["productCode"] ?? "")
            .toString()
            .trim();

    return value.isEmpty
        ? "N/A"
        : value;
  }

  ///////////////////////////////////////////////////////////
  /// IMAGES
  ///////////////////////////////////////////////////////////

  ///////////////////////////////////////////////////////////
/// GET PRODUCT IMAGES
///////////////////////////////////////////////////////////

List<String> _getImages(
  Map<String, dynamic> item,
) {
  final List<String> images = [];

  /////////////////////////////////////////////////////////
  /// MULTIPLE IMAGES
  /////////////////////////////////////////////////////////

  final rawImages = item["images"];

  if (rawImages is List) {
    for (final image in rawImages) {
      final url =
          image.toString().trim();

      if (url.isNotEmpty &&
          !images.contains(url)) {
        images.add(url);
      }
    }
  }

  /////////////////////////////////////////////////////////
  /// SINGLE IMAGE FALLBACK
  /////////////////////////////////////////////////////////

  final singleImage =
      (item["image"] ?? "")
          .toString()
          .trim();

  if (singleImage.isNotEmpty &&
      !images.contains(singleImage)) {
    images.add(singleImage);
  }

  /////////////////////////////////////////////////////////
  /// IMAGE URL FALLBACKS
  /////////////////////////////////////////////////////////

  final imageUrl =
      (item["imageUrl"] ?? "")
          .toString()
          .trim();

  if (imageUrl.isNotEmpty &&
      !images.contains(imageUrl)) {
    images.add(imageUrl);
  }

  return images;
}

  ///////////////////////////////////////////////////////////
  /// FILTERED ITEMS
  ///////////////////////////////////////////////////////////

  List<Map<String, dynamic>>
      get _filteredItems {
    if (_searchQuery.isEmpty) {
      return _items;
    }

    return _items.where((item) {
      final name =
          _getProductName(item)
              .toLowerCase();

      final code =
          _getProductCode(item)
              .toLowerCase();

      final variant =
          _getVariant(item)
              .toLowerCase();

      return name.contains(_searchQuery) ||
          code.contains(_searchQuery) ||
          variant.contains(_searchQuery);
    }).toList();
  }

  ///////////////////////////////////////////////////////////
  /// TOTAL ORDERED
  ///////////////////////////////////////////////////////////

  int get _totalOrdered {
    return _items.fold<int>(
      0,
      (sum, item) =>
          sum +
          _orderedQuantity(item),
    );
  }

  ///////////////////////////////////////////////////////////
  /// TOTAL RECEIVED
  ///////////////////////////////////////////////////////////

  int get _totalReceived {
    return _items.fold<int>(
      0,
      (sum, item) =>
          sum +
          _receivedQuantity(item),
    );
  }

  ///////////////////////////////////////////////////////////
  /// TOTAL MISSING
  ///////////////////////////////////////////////////////////

  int get _totalMissing {
    return _items.fold<int>(
      0,
      (sum, item) =>
          sum +
          _missingQuantity(item),
    );
  }

  ///////////////////////////////////////////////////////////
  /// CONFIRMED
  ///////////////////////////////////////////////////////////

  int get _confirmedCount {
    return _items
        .where(
          _isConfirmed,
        )
        .length;
  }

  ///////////////////////////////////////////////////////////
  /// PENDING
  ///////////////////////////////////////////////////////////

  int get _pendingCount {
    return _items.length -
        _confirmedCount;
  }

  ///////////////////////////////////////////////////////////
  /// COMPLETED
  ///////////////////////////////////////////////////////////

  bool get _isCompleted {
    return _items.isNotEmpty &&
        _confirmedCount ==
            _items.length;
  }

  ///////////////////////////////////////////////////////////
  /// FORMAT DATE TIME
  ///////////////////////////////////////////////////////////

  String _formatDateTime(
    dynamic value,
  ) {
    if (value == null) {
      return "N/A";
    }

    DateTime? dateTime;

    if (value is Timestamp) {
      dateTime =
          value.toDate();
    } else if (value is DateTime) {
      dateTime = value;
    } else if (value is String) {
      dateTime =
          DateTime.tryParse(value);
    }

    if (dateTime == null) {
      return value
          .toString();
    }

    final day =
        dateTime.day
            .toString()
            .padLeft(2, '0');

    final month =
        dateTime.month
            .toString()
            .padLeft(2, '0');

    final year =
        dateTime.year
            .toString();

    final hour =
        dateTime.hour
            .toString()
            .padLeft(2, '0');

    final minute =
        dateTime.minute
            .toString()
            .padLeft(2, '0');

    return "$day/$month/$year  $hour:$minute";
  }

  ///////////////////////////////////////////////////////////
  /// ADMIN NAME
  ///////////////////////////////////////////////////////////

  String _adminDisplayName(
    dynamic value,
  ) {
    final id =
        (value ?? "")
            .toString()
            .trim();

    if (id.isEmpty) {
      return "N/A";
    }

    return id;
  }

  ///////////////////////////////////////////////////////////
  /// REFRESH
  ///////////////////////////////////////////////////////////

  Future<void> _refresh() async {
    await _loadReport();
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
          const Color(0xffFAF8F9),

      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            const Color(0xff241B2F),
        foregroundColor:
            Colors.white,
        titleSpacing: 16,
        title: const Text(
          "Packing Report",
          style: TextStyle(
            fontSize: 18,
            fontWeight:
                FontWeight.w900,
          ),
        ),
      ),

      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh:
                      _refresh,
                  child:
                      CustomScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      ///////////////////////////////////////////////////
                      /// HEADER
                      ///////////////////////////////////////////////////

                      SliverToBoxAdapter(
                        child:
                            _buildHeader(),
                      ),

                      ///////////////////////////////////////////////////
                      /// SEARCH
                      ///////////////////////////////////////////////////

                      SliverToBoxAdapter(
                        child:
                            _buildSearch(),
                      ),

                      ///////////////////////////////////////////////////
                      /// ITEM COUNT
                      ///////////////////////////////////////////////////

                      SliverToBoxAdapter(
                        child:
                            _buildResultsHeader(),
                      ),

                      ///////////////////////////////////////////////////
                      /// ITEMS
                      ///////////////////////////////////////////////////

                      if (_filteredItems.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody:
                              false,
                          child:
                              _buildEmpty(),
                        )
                      else
                        SliverList(
                          delegate:
                              SliverChildBuilderDelegate(
                            (
                              context,
                              index,
                            ) {
                              final item =
                                  _filteredItems[
                                      index];

                              return Padding(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                child:
                                    _buildItemCard(
                                  item,
                                  index,
                                ),
                              );
                            },
                            childCount:
                                _filteredItems.length,
                          ),
                        ),

                      ///////////////////////////////////////////////////
                      /// BOTTOM
                      ///////////////////////////////////////////////////

                      const SliverToBoxAdapter(
                        child:
                            SizedBox(
                          height: 30,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// HEADER
  ///////////////////////////////////////////////////////////

  Widget _buildHeader() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        14,
        14,
        14,
        8,
      ),
      child:
          Container(
        width:
            double.infinity,
        padding:
            const EdgeInsets.all(18),
        decoration:
            BoxDecoration(
          color:
              const Color(0xff241B2F),
          borderRadius:
              BorderRadius.circular(22),
        ),
        child:
            Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            ///////////////////////////////////////////////////////
            /// TITLE
            ///////////////////////////////////////////////////////

            const Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  color:
                      Colors.white,
                  size: 22,
                ),
                SizedBox(
                  width: 9,
                ),
                Text(
                  "Packing Report",
                  style:
                      TextStyle(
                    color:
                        Colors.white,
                    fontSize: 19,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 6,
            ),

            ///////////////////////////////////////////////////////
            /// ORDER
            ///////////////////////////////////////////////////////

            Text(
              "Order ID: ${widget.orderId}",
              style:
                  const TextStyle(
                color:
                    Colors.white70,
                fontSize: 11,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            ///////////////////////////////////////////////////////
            /// STATS
            ///////////////////////////////////////////////////////

            Row(
              children: [
                _summaryStat(
                  "Items",
                  "${_items.length}",
                ),
                _summaryStat(
                  "Ordered",
                  "$_totalOrdered",
                ),
                _summaryStat(
                  "Received",
                  "$_totalReceived",
                ),
                _summaryStat(
                  "Missing",
                  "$_totalMissing",
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            ///////////////////////////////////////////////////////
            /// STATUS
            ///////////////////////////////////////////////////////

            Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration:
                  BoxDecoration(
                color:
                    Colors.white
                        .withOpacity(.08),
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child:
                  Row(
                children: [
                  Icon(
                    _isCompleted
                        ? Icons
                            .check_circle_rounded
                        : Icons
                            .pending_actions,
                    size: 18,
                    color:
                        _isCompleted
                            ? Colors.greenAccent
                            : Colors.orangeAccent,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child:
                        Text(
                      _isCompleted
                          ? "Packing Completed"
                          : "Packing In Progress",
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    "$_confirmedCount / ${_items.length}",
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w900,
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
  /// SUMMARY STAT
  ///////////////////////////////////////////////////////////

  Widget _summaryStat(
    String title,
    String value,
  ) {
    return Expanded(
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style:
                const TextStyle(
              color:
                  Colors.white,
              fontSize: 17,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
          const SizedBox(
            height: 2,
          ),
          Text(
            title,
            style:
                const TextStyle(
              color:
                  Colors.white60,
              fontSize: 9,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// SEARCH
  ///////////////////////////////////////////////////////////

  Widget _buildSearch() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        14,
        8,
        14,
        8,
      ),
      child:
          TextField(
        controller:
            _searchController,
        decoration:
            InputDecoration(
          hintText:
              "Search product, code or variant...",
          prefixIcon:
              const Icon(
            Icons.search_rounded,
          ),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController
                            .clear();
                      },
                      icon:
                          const Icon(
                        Icons.close_rounded,
                      ),
                    )
                  : null,
          filled:
              true,
          fillColor:
              Colors.white,
          contentPadding:
              const EdgeInsets
                  .symmetric(
            vertical: 14,
            horizontal: 14,
          ),
          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              15,
            ),
            borderSide:
                const BorderSide(
              color:
                  Color(0xffECE3E7),
            ),
          ),
          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              15,
            ),
            borderSide:
                const BorderSide(
              color:
                  Color(0xffECE3E7),
            ),
          ),
          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              15,
            ),
            borderSide:
                const BorderSide(
              color:
                  Color(0xff241B2F),
            ),
          ),
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// RESULTS HEADER
  ///////////////////////////////////////////////////////////

  Widget _buildResultsHeader() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        4,
      ),
      child:
          Row(
        children: [
          Expanded(
            child:
                Text(
              _searchQuery.isEmpty
                  ? "${_items.length} products"
                  : "${_filteredItems.length} matching products",
              style:
                  const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w800,
                color:
                    Color(0xff6A5962),
              ),
            ),
          ),

          if (_pendingCount > 0)
            Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 9,
                vertical: 5,
              ),
              decoration:
                  BoxDecoration(
                color:
                    const Color(0xfffff4dd),
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),
              child:
                  Text(
                "$_pendingCount pending",
                style:
                    TextStyle(
                  color:
                      Colors.orange.shade800,
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
  /// ITEM CARD
  ///////////////////////////////////////////////////////////

  Widget _buildItemCard(
    Map<String, dynamic> item,
    int index,
  ) {
    final ordered =
        _orderedQuantity(item);

    final received =
        _receivedQuantity(item);

    final missing =
        _missingQuantity(item);

    final confirmed =
        _isConfirmed(item);

    final images =
        _getImages(item);

    final name =
        _getProductName(item);

    final code =
        _getProductCode(item);

    final variant =
        _getVariant(item);

    final confirmedBy =
        item["confirmedBy"];

    final confirmedAt =
        item["confirmedAt"];

    final updatedBy =
        item["updatedBy"];

    final updatedAt =
        item["updatedAt"];

    final note =
        (item["adminNote"] ?? "")
            .toString()
            .trim();

    return Container(
      width:
          double.infinity,
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
              confirmed
                  ? Colors.green.shade200
                  : const Color(
                      0xffECE3E7,
                    ),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black
                    .withOpacity(.035),
            blurRadius:
                12,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),
      child:
          Padding(
        padding:
            const EdgeInsets.all(12),
        child:
            Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            ///////////////////////////////////////////////////
            /// ITEM HEADER
            ///////////////////////////////////////////////////

            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment:
                      Alignment.center,
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xffF3EFF1,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                  child:
                      Text(
                    "${index + 1}",
                    style:
                        const TextStyle(
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child:
                      Text(
                    name,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w900,
                      color:
                          Color(0xff241B2F),
                    ),
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                _statusBadge(
                  confirmed,
                ),
              ],
            ),

            const SizedBox(
              height: 12,
            ),

            ///////////////////////////////////////////////////
            /// IMAGE
            ///////////////////////////////////////////////////

            if (images.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _showImages(
                    images,
                    0,
                  );
                },
                child:
                    ClipRRect(
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                  child:
                      SizedBox(
                    height: 210,
                    width:
                        double.infinity,
                    child:
                        Stack(
                      fit:
                          StackFit.expand,
                      children: [
                        Image.network(
                          images.first,
                          fit:
                              BoxFit.cover,
                          errorBuilder:
                              (
                            _,
                            __,
                            ___,
                          ) {
                            return _imagePlaceholder();
                          },
                        ),

                        if (images.length >
                            1)
                          Positioned(
                            right: 10,
                            top: 10,
                            child:
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
                                    Colors.black
                                        .withOpacity(
                                  .68,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                  20,
                                ),
                              ),
                              child:
                                  Text(
                                "1 / ${images.length}",
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize:
                                      10,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              )
            else
              _imagePlaceholder(),

            const SizedBox(
              height: 12,
            ),

            ///////////////////////////////////////////////////
            /// CODE + VARIANT
            ///////////////////////////////////////////////////

            _infoBox(
              icon:
                  Icons.qr_code_2_rounded,
              title:
                  "Product Code",
              value:
                  code,
            ),

            const SizedBox(
              height: 8,
            ),

            _infoBox(
              icon:
                  Icons.style_outlined,
              title:
                  "Variant",
              value:
                  variant,
            ),

            const SizedBox(
              height: 12,
            ),

            ///////////////////////////////////////////////////
            /// QUANTITY
            ///////////////////////////////////////////////////

            Row(
              children: [
                Expanded(
                  child:
                      _quantityBox(
                    title:
                        "Ordered",
                    value:
                        ordered,
                    icon:
                        Icons.shopping_cart_outlined,
                    background:
                        const Color(
                      0xffF5F2F3,
                    ),
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                Expanded(
                  child:
                      _quantityBox(
                    title:
                        "Received",
                    value:
                        received,
                    icon:
                        Icons.inventory_2_outlined,
                    background:
                        const Color(
                      0xffEEF8F1,
                    ),
                    iconColor:
                        Colors.green.shade700,
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                Expanded(
                  child:
                      _quantityBox(
                    title:
                        "Missing",
                    value:
                        missing,
                    icon:
                        Icons.warning_amber_outlined,
                    background:
                        const Color(
                      0xfffff8e1,
                    ),
                    iconColor:
                        Colors.orange.shade700,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 12,
            ),

            ///////////////////////////////////////////////////
            /// RECEIVED + MISSING
            ///////////////////////////////////////////////////

            _buildProgress(
              ordered:
                  ordered,
              received:
                  received,
              missing:
                  missing,
            ),

            ///////////////////////////////////////////////////
            /// CONFIRMATION
            ///////////////////////////////////////////////////

            if (confirmedBy != null ||
                confirmedAt != null ||
                updatedBy != null ||
                updatedAt != null) ...[
              const SizedBox(
                height: 12,
              ),
              _buildMeta(
                confirmed:
                    confirmed,
                confirmedBy:
                    confirmedBy,
                confirmedAt:
                    confirmedAt,
                updatedBy:
                    updatedBy,
                updatedAt:
                    updatedAt,
              ),
            ],

            ///////////////////////////////////////////////////
            /// ADMIN NOTE
            ///////////////////////////////////////////////////

            if (note.isNotEmpty) ...[
              const SizedBox(
                height: 12,
              ),
              _buildNote(
                note,
              ),
            ],
          ],
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// STATUS BADGE
  ///////////////////////////////////////////////////////////

  Widget _statusBadge(
    bool confirmed,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration:
          BoxDecoration(
        color:
            confirmed
                ? const Color(
                    0xffEAF7ED,
                  )
                : const Color(
                    0xfffff4dd,
                  ),
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child:
          Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            confirmed
                ? Icons.check_circle_rounded
                : Icons.pending_actions,
            size: 13,
            color:
                confirmed
                    ? Colors.green.shade700
                    : Colors.orange.shade700,
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            confirmed
                ? "Confirmed"
                : "Pending",
            style:
                TextStyle(
              fontSize: 9,
              fontWeight:
                  FontWeight.w900,
              color:
                  confirmed
                      ? Colors.green.shade800
                      : Colors.orange.shade800,
            ),
          ),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// IMAGE PLACEHOLDER
  ///////////////////////////////////////////////////////////

  Widget _imagePlaceholder() {
    return Container(
      height: 150,
      width:
          double.infinity,
      decoration:
          BoxDecoration(
        color:
            const Color(0xffF5F2F3),
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child:
          const Center(
        child:
            Icon(
          Icons.image_not_supported_outlined,
          size: 42,
          color:
              Colors.grey,
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// INFO BOX
  ///////////////////////////////////////////////////////////

  Widget _infoBox({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        11,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(0xffF8F5F6),
        borderRadius:
            BorderRadius.circular(
          12,
        ),
      ),
      child:
          Row(
        children: [
          Icon(
            icon,
            size: 18,
            color:
                const Color(0xff6A5962),
          ),
          const SizedBox(
            width: 9,
          ),
          Text(
            "$title: ",
            style:
                const TextStyle(
              fontSize: 11,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
          Expanded(
            child:
                Text(
              value,
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
              style:
                  const TextStyle(
                fontSize: 11,
                color:
                    Color(0xff76656D),
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// QUANTITY BOX
  ///////////////////////////////////////////////////////////

  Widget _quantityBox({
    required String title,
    required int value,
    required IconData icon,
    required Color background,
    Color? iconColor,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(
        11,
      ),
      decoration:
          BoxDecoration(
        color:
            background,
        borderRadius:
            BorderRadius.circular(
          13,
        ),
      ),
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 17,
            color:
                iconColor ??
                    const Color(
                      0xff4E4348,
                    ),
          ),
          const SizedBox(
            height: 7,
          ),
          Text(
            "$value",
            style:
                const TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
          const SizedBox(
            height: 2,
          ),
          Text(
            title,
            style:
                const TextStyle(
              fontSize: 9,
              fontWeight:
                  FontWeight.w700,
              color:
                  Color(0xff76656D),
            ),
          ),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// PROGRESS
  ///////////////////////////////////////////////////////////

  Widget _buildProgress({
    required int ordered,
    required int received,
    required int missing,
  }) {
    final total =
        received + missing;

    final progress =
        ordered <= 0
            ? 0.0
            : (total / ordered)
                .clamp(
                0.0,
                1.0,
              );

    final complete =
        total == ordered;

    return Container(
      padding:
          const EdgeInsets.all(
        12,
      ),
      decoration:
          BoxDecoration(
        color:
            complete
                ? const Color(
                    0xffF0F9F2,
                  )
                : const Color(
                    0xffF7F4F5,
                  ),
        borderRadius:
            BorderRadius.circular(
          13,
        ),
      ),
      child:
          Column(
        children: [
          Row(
            children: [
              Icon(
                complete
                    ? Icons
                        .check_circle_outline
                    : Icons
                        .pending_actions,
                size: 17,
                color:
                    complete
                        ? Colors.green.shade700
                        : const Color(
                            0xff76656D,
                          ),
              ),
              const SizedBox(
                width: 7,
              ),
              Expanded(
                child:
                    Text(
                  complete
                      ? "Quantity completed"
                      : "Packing progress",
                  style:
                      const TextStyle(
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),
              Text(
                "$total / $ordered",
                style:
                    const TextStyle(
                  fontSize: 10,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(
              20,
            ),
            child:
                LinearProgressIndicator(
              value:
                  progress,
              minHeight: 6,
              backgroundColor:
                  Colors.white,
              valueColor:
                  AlwaysStoppedAnimation<
                      Color>(
                complete
                    ? Colors.green.shade600
                    : const Color(
                        0xff241B2F,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// META
  ///////////////////////////////////////////////////////////

  Widget _buildMeta({
    required bool confirmed,
    required dynamic confirmedBy,
    required dynamic confirmedAt,
    required dynamic updatedBy,
    required dynamic updatedAt,
  }) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        13,
      ),
      decoration:
          BoxDecoration(
        color:
            confirmed
                ? const Color(
                    0xffF0F9F2,
                  )
                : const Color(
                    0xffF7F4F5,
                  ),
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        border:
            Border.all(
          color:
              confirmed
                  ? Colors.green.shade200
                  : const Color(
                      0xffECE3E7,
                    ),
        ),
      ),
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                confirmed
                    ? Icons
                        .verified_rounded
                    : Icons
                        .history_rounded,
                size: 18,
                color:
                    confirmed
                        ? Colors.green.shade700
                        : const Color(
                            0xff76656D,
                          ),
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                confirmed
                    ? "Confirmation Details"
                    : "Update Details",
                style:
                    const TextStyle(
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ],
          ),

          if (confirmedBy != null) ...[
            const SizedBox(
              height: 10,
            ),
            _metaRow(
              Icons.person_outline,
              "Confirmed By",
              _adminDisplayName(
                confirmedBy,
              ),
            ),
          ],

          if (confirmedAt != null) ...[
            const SizedBox(
              height: 7,
            ),
            _metaRow(
              Icons.schedule_outlined,
              "Confirmed At",
              _formatDateTime(
                confirmedAt,
              ),
            ),
          ],

          if (updatedBy != null) ...[
            const SizedBox(
              height: 7,
            ),
            _metaRow(
              Icons.edit_outlined,
              "Updated By",
              _adminDisplayName(
                updatedBy,
              ),
            ),
          ],

          if (updatedAt != null) ...[
            const SizedBox(
              height: 7,
            ),
            _metaRow(
              Icons.update_outlined,
              "Updated At",
              _formatDateTime(
                updatedAt,
              ),
            ),
          ],
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// META ROW
  ///////////////////////////////////////////////////////////

  Widget _metaRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color:
              const Color(0xff76656D),
        ),
        const SizedBox(
          width: 7,
        ),
        Text(
          "$title: ",
          style:
              const TextStyle(
            fontSize: 10,
            fontWeight:
                FontWeight.w900,
          ),
        ),
        Expanded(
          child:
              Text(
            value,
            style:
                const TextStyle(
              fontSize: 10,
              color:
                  Color(0xff76656D),
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  ///////////////////////////////////////////////////////////
  /// NOTE
  ///////////////////////////////////////////////////////////

  Widget _buildNote(
    String note,
  ) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        12,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(0xfffff8e1),
        borderRadius:
            BorderRadius.circular(
          13,
        ),
      ),
      child:
          Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.notes_outlined,
            size: 18,
            color:
                Colors.orange.shade700,
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  "Packing Note",
                  style:
                      TextStyle(
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  note,
                  style:
                      const TextStyle(
                    fontSize: 11,
                    color:
                        Color(0xff76656D),
                    height: 1.35,
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
  /// SHOW ALL IMAGES
  ///////////////////////////////////////////////////////////

  void _showImages(
    List<String> images,
    int initialIndex,
  ) {
    if (images.isEmpty) {
      return;
    }

    showDialog(
      context: context,
      barrierColor:
          Colors.black.withOpacity(
        .9,
      ),
      builder:
          (_) {
        return Dialog(
          backgroundColor:
              Colors.transparent,
          insetPadding:
              const EdgeInsets.all(
            10,
          ),
          child:
              _FullScreenImageViewer(
            images:
                images,
            initialIndex:
                initialIndex,
          ),
        );
      },
    );
  }

  ///////////////////////////////////////////////////////////
  /// ERROR
  ///////////////////////////////////////////////////////////

  Widget _buildError() {
    return Center(
      child:
          Padding(
        padding:
            const EdgeInsets.all(
          24,
        ),
        child:
            Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons
                  .error_outline_rounded,
              size: 52,
              color:
                  Colors.redAccent,
            ),
            const SizedBox(
              height: 14,
            ),
            const Text(
              "Unable to load packing report",
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed:
                  _loadReport,
              child:
                  const Text(
                "Try Again",
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

  Widget _buildEmpty() {
    return const Center(
      child:
          Padding(
        padding:
            EdgeInsets.all(
          30,
        ),
        child:
            Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 50,
              color:
                  Colors.grey,
            ),
            SizedBox(
              height: 12,
            ),
            Text(
              "No packing items found.",
              style:
                  TextStyle(
                fontSize: 14,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////
/// FULL SCREEN IMAGE VIEWER
///////////////////////////////////////////////////////////////

class _FullScreenImageViewer
    extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenImageViewer({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullScreenImageViewer>
      createState() =>
          _FullScreenImageViewerState();
}

class _FullScreenImageViewerState
    extends State<_FullScreenImageViewer> {
  late PageController _controller;

  late int _currentIndex;

  @override
  void initState() {
    super.initState();

    _currentIndex =
        widget.initialIndex;

    _controller =
        PageController(
      initialPage:
          widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Stack(
      children: [
        ///////////////////////////////////////////////////////
        /// IMAGES
        ///////////////////////////////////////////////////////

        SizedBox(
          height:
              MediaQuery.of(context)
                  .size
                  .height *
              .85,
          width:
              double.infinity,
          child:
              PageView.builder(
            controller:
                _controller,
            itemCount:
                widget.images.length,
            onPageChanged:
                (index) {
              setState(() {
                _currentIndex =
                    index;
              });
            },
            itemBuilder:
                (
              context,
              index,
            ) {
              return InteractiveViewer(
                minScale:
                    .5,
                maxScale:
                    4,
                child:
                    Image.network(
                  widget.images[index],
                  fit:
                      BoxFit.contain,
                  errorBuilder:
                      (
                    _,
                    __,
                    ___,
                  ) {
                    return const Center(
                      child:
                          Icon(
                        Icons
                            .broken_image_outlined,
                        size:
                            50,
                        color:
                            Colors.white,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),

        ///////////////////////////////////////////////////////
        /// COUNTER
        ///////////////////////////////////////////////////////

        Positioned(
          top: 12,
          left: 0,
          right: 0,
          child:
              Center(
            child:
                Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 11,
                vertical: 7,
              ),
              decoration:
                  BoxDecoration(
                color:
                    Colors.black
                        .withOpacity(
                  .65,
                ),
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),
              child:
                  Text(
                "${_currentIndex + 1} / ${widget.images.length}",
                style:
                    const TextStyle(
                  color:
                      Colors.white,
                  fontSize:
                      11,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
          ),
        ),

        ///////////////////////////////////////////////////////
        /// CLOSE
        ///////////////////////////////////////////////////////

        Positioned(
          top: 8,
          right: 8,
          child:
              Material(
            color:
                Colors.black
                    .withOpacity(
              .6,
            ),
            shape:
                const CircleBorder(),
            child:
                IconButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
              icon:
                  const Icon(
                Icons.close_rounded,
                color:
                    Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}