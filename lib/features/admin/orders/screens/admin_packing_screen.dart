import 'package:flutter/material.dart';

import '../services/admin_order_service.dart';

class AdminPackingScreen extends StatefulWidget {
  final String orderId;

  const AdminPackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<AdminPackingScreen> createState() =>
      _AdminPackingScreenState();
}

class _AdminPackingScreenState
    extends State<AdminPackingScreen> {

  bool _isLoading = true;

  List<Map<String, dynamic>> _items = [];

  ///////////////////////////////////////////////////////////
  /// PACKING STATUS
  ///////////////////////////////////////////////////////////

  final Map<int, String> _itemStatus = {};
final Map<int, TextEditingController>
    _codeControllers = {};

final Map<int, TextEditingController>
    _variantControllers = {};

final Map<int, TextEditingController>
    _noteControllers = {};
    final Map<int, PageController> _imageControllers = {};
final Map<int, int> _currentImageIndex = {};
  ///////////////////////////////////////////////////////////
  /// COUNTS
  ///////////////////////////////////////////////////////////
@override
void dispose() {
  for (final controller
      in _codeControllers.values) {
    controller.dispose();
  }

  for (final controller
      in _variantControllers.values) {
    controller.dispose();
  }

  for (final controller
      in _noteControllers.values) {
    controller.dispose();
  }

  for (final controller
      in _imageControllers.values) {
    controller.dispose();
  }

  super.dispose();
}
TextEditingController _codeController(
  int index,
  String value,
) {
  return _codeControllers.putIfAbsent(
    index,
    () => TextEditingController(
      text: value,
    ),
  );
}

TextEditingController _variantController(
  int index,
  String value,
) {
  return _variantControllers.putIfAbsent(
    index,
    () => TextEditingController(
      text: value,
    ),
  );
}

TextEditingController _noteController(
  int index,
  String value,
) {
  return _noteControllers.putIfAbsent(
    index,
    () => TextEditingController(
      text: value,
    ),
  );
}
  int get _totalItems {
    return _items.fold<int>(
      0,
      (sum, item) =>
          sum + (int.tryParse(
                "${item["quantity"] ?? 0}",
              ) ??
              0),
    );
  }

  int get _correctCount {
    return _itemStatus.values
        .where((status) => status == "correct")
        .length;
  }

  int get _wrongCount {
    return _itemStatus.values
        .where((status) => status == "wrong")
        .length;
  }

  int get _missingCount {
    return _itemStatus.values
        .where((status) => status == "missing")
        .length;
  }

  int get _pendingCount {
    return _items.length -
        _correctCount -
        _wrongCount -
        _missingCount;
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  ///////////////////////////////////////////////////////////
  /// LOAD ORDER ITEMS
  ///////////////////////////////////////////////////////////

  Future<void> _loadItems() async {
  try {
    setState(() {
      _isLoading = true;
    });

    /////////////////////////////////////////////////////////
    /// LOAD ORDER ITEMS
    /////////////////////////////////////////////////////////

    final items =
        await AdminOrderService.instance
            .getOrderItems(
      widget.orderId,
    );

    /////////////////////////////////////////////////////////
    /// LOAD SAVED PACKING DATA
    /////////////////////////////////////////////////////////

    final packingData =
        await AdminOrderService.instance
            .getPackingData(
      widget.orderId,
    );

    /////////////////////////////////////////////////////////
    /// RESTORE SAVED ITEM STATUS
    /////////////////////////////////////////////////////////

    final restoredStatuses =
        <int, String>{};

    final rawPackingItems =
        packingData["items"];

    if (rawPackingItems is List) {
      for (
        int i = 0;
        i < rawPackingItems.length;
        i++
      ) {
        final rawItem =
            rawPackingItems[i];

        if (rawItem is Map) {
          final status =
              (rawItem["status"] ?? "")
                  .toString();

          if (status.isNotEmpty) {
            restoredStatuses[i] =
                status;
          }
        }
      }
    }

    if (!mounted) return;

    setState(() {
      _items = items;

      _itemStatus.clear();

      _itemStatus.addAll(
        restoredStatuses,
      );

      _isLoading = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          "Failed to load packing items: $e",
        ),
      ),
    );
  }
}
Future<void> _saveQuantity(
  int index,
  int quantity,
) async {
  try {
    await AdminOrderService.instance
        .updatePackingItemDetails(
      orderId: widget.orderId,
      itemIndex: index,
      quantity: quantity,
    );

    await _loadItems();
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          "Failed to update quantity: $e",
        ),
      ),
    );
  }
}
Widget _buildMissingQuantityEditor({
  required int index,
  required Map<String, dynamic> item,
}) {
  final missingQuantity =
      int.tryParse(
            "${item["missingQuantity"] ?? 0}",
          ) ??
          0;

  return Container(
    padding:
        const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color:
          const Color(0xfffff8e1),
      borderRadius:
          BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.warning_amber_outlined,
          color: Colors.orange,
        ),

        const SizedBox(width: 10),

        const Expanded(
          child: Text(
            "Missing Quantity",
            style: TextStyle(
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),

        IconButton(
          onPressed:
              missingQuantity <= 0
                  ? null
                  : () {
                      _saveMissingQuantity(
                        index,
                        missingQuantity - 1,
                      );
                    },
          icon: const Icon(
            Icons.remove_circle_outline,
          ),
        ),

        Text(
          "$missingQuantity",
          style: const TextStyle(
            fontSize: 17,
            fontWeight:
                FontWeight.w800,
          ),
        ),

        IconButton(
          onPressed: () {
            _saveMissingQuantity(
              index,
              missingQuantity + 1,
            );
          },
          icon: const Icon(
            Icons.add_circle_outline,
          ),
        ),
      ],
    ),
  );
}
Future<void> _saveMissingQuantity(
  int index,
  int quantity,
) async {
  try {
    await AdminOrderService.instance
        .updatePackingItemDetails(
      orderId: widget.orderId,
      itemIndex: index,
      missingQuantity: quantity,
    );

    await _loadItems();
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          "Failed to update missing quantity: $e",
        ),
      ),
    );
  }
}

  ///////////////////////////////////////////////////////////
  /// SET ITEM STATUS
  ///////////////////////////////////////////////////////////

  Future<void> _setItemStatus(
  int index,
  String status,
) async {
  /////////////////////////////////////////////////////////
  /// UPDATE UI IMMEDIATELY
  /////////////////////////////////////////////////////////

  setState(() {
    _itemStatus[index] =
        status;
  });

  /////////////////////////////////////////////////////////
  /// SAVE TO FIRESTORE
  /////////////////////////////////////////////////////////

  try {
    await AdminOrderService.instance
        .savePackingItemStatus(
      orderId: widget.orderId,
      itemIndex: index,
      status: status,
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          "Failed to save packing status: $e",
        ),
      ),
    );
  }
}

  ///////////////////////////////////////////////////////////
  /// IMAGE
  ///////////////////////////////////////////////////////////

Widget _buildProductImage(
  Map<String, dynamic> item,
  int index,
) {
  /////////////////////////////////////////////////////////
  /// GET ALL IMAGES
  /////////////////////////////////////////////////////////

  final imagesRaw = item["images"];

  List<String> images = [];

  if (imagesRaw is List) {
    images = imagesRaw
        .map(
          (e) => e.toString().trim(),
        )
        .where(
          (e) => e.isNotEmpty,
        )
        .toList();
  }

  /////////////////////////////////////////////////////////
  /// FALLBACK IMAGE
  /////////////////////////////////////////////////////////

  final singleImage =
      (item["image"] ?? "")
          .toString()
          .trim();

  if (images.isEmpty &&
      singleImage.isNotEmpty) {
    images.add(singleImage);
  }

  /////////////////////////////////////////////////////////
  /// NO IMAGE
  /////////////////////////////////////////////////////////

  if (images.isEmpty) {
    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 50,
          color: Colors.grey,
        ),
      ),
    );
  }

  /////////////////////////////////////////////////////////
  /// CONTROLLER
  /////////////////////////////////////////////////////////

  final controller =
      _imageControllers.putIfAbsent(
    index,
    () => PageController(),
  );

  final currentIndex =
      _currentImageIndex[index] ?? 0;

  /////////////////////////////////////////////////////////
  /// SLIDER
  /////////////////////////////////////////////////////////

  return Column(
    children: [

      Stack(
        children: [

          ClipRRect(
            borderRadius:
                BorderRadius.circular(18),
            child: SizedBox(
              height: 280,
              width: double.infinity,
              child: PageView.builder(
                controller: controller,
                itemCount:
                    images.length,
                onPageChanged: (page) {
                  setState(() {
                    _currentImageIndex[index] =
                        page;
                  });
                },
                itemBuilder:
                    (context, imageIndex) {
                  return Image.network(
                    images[imageIndex],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder:
                        (_, __, ___) {
                      return Container(
                        color:
                            Colors.grey.shade100,
                        child:
                            const Center(
                          child: Icon(
                            Icons
                                .broken_image_outlined,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                    loadingBuilder:
                        (
                      context,
                      child,
                      progress,
                    ) {
                      if (progress ==
                          null) {
                        return child;
                      }

                      return Container(
                        color:
                            Colors.grey.shade100,
                        child:
                            const Center(
                          child:
                              CircularProgressIndicator(),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          /////////////////////////////////////////////////////
          /// IMAGE COUNT
          /////////////////////////////////////////////////////

          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.black
                    .withOpacity(.65),
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Text(
                "${currentIndex + 1} / ${images.length}",
                style:
                    const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
          ),

          /////////////////////////////////////////////////////
          /// PREVIOUS
          /////////////////////////////////////////////////////

          if (images.length > 1 &&
              currentIndex > 0)
            Positioned(
              left: 10,
              top: 0,
              bottom: 0,
              child: Center(
                child: _imageArrow(
                  icon:
                      Icons.chevron_left_rounded,
                  onTap: () {
                    controller.previousPage(
                      duration:
                          const Duration(
                        milliseconds: 220,
                      ),
                      curve:
                          Curves.easeOut,
                    );
                  },
                ),
              ),
            ),

          /////////////////////////////////////////////////////
          /// NEXT
          /////////////////////////////////////////////////////

          if (images.length > 1 &&
              currentIndex <
                  images.length - 1)
            Positioned(
              right: 10,
              top: 0,
              bottom: 0,
              child: Center(
                child: _imageArrow(
                  icon:
                      Icons.chevron_right_rounded,
                  onTap: () {
                    controller.nextPage(
                      duration:
                          const Duration(
                        milliseconds: 220,
                      ),
                      curve:
                          Curves.easeOut,
                    );
                  },
                ),
              ),
            ),
        ],
      ),

      /////////////////////////////////////////////////////////
      /// DOTS
      /////////////////////////////////////////////////////////

      if (images.length > 1)
        Padding(
          padding:
              const EdgeInsets.only(
            top: 10,
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (dotIndex) {
                final selected =
                    dotIndex ==
                        currentIndex;

                return AnimatedContainer(
                  duration:
                      const Duration(
                    milliseconds: 180,
                  ),
                  margin:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 3,
                  ),
                  width:
                      selected ? 18 : 6,
                  height: 6,
                  decoration:
                      BoxDecoration(
                    color: selected
                        ? Colors.black
                        : Colors.grey
                            .shade300,
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
    ],
  );
}
Widget _imageArrow({
  required IconData icon,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.black.withOpacity(.55),
    shape: const CircleBorder(),
    child: InkWell(
      customBorder:
          const CircleBorder(),
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.all(6),
        child: Icon(
          icon,
          color: Colors.white,
          size: 25,
        ),
      ),
    ),
  );
}

  ///////////////////////////////////////////////////////////
  /// VARIANT
  ///////////////////////////////////////////////////////////

  String _getVariant(
    Map<String, dynamic> item,
  ) {
    final label =
        (item["variationLabel"] ?? "")
            .toString()
            .trim();

    if (label.isNotEmpty) {
      return label;
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
  /// STATUS BUTTON
  ///////////////////////////////////////////////////////////

  Widget _statusButton({
    required int index,
    required String status,
    required String label,
    required IconData icon,
  }) {
    final selected =
        _itemStatus[index] == status;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _setItemStatus(
            index,
            status,
          );
        },
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 8,
          ),
          decoration: BoxDecoration(
            color: selected
                ? Colors.black
                : Colors.white,
            borderRadius:
                BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? Colors.black
                  : Colors.grey.shade300,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 21,
                color: selected
                    ? Colors.white
                    : Colors.black87,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight:
                      FontWeight.w700,
                  fontSize: 12,
                  color: selected
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ],
          ),
        ),
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
    final productName =
        (item["productName"] ?? "Product")
            .toString();

    final productCode =
        (item["productCode"] ?? "N/A")
            .toString();

    final quantity =
        item["quantity"] ?? 0;

    final variant =
        _getVariant(item);

    final status =
        _itemStatus[index];

    return Container(
      margin:
          const EdgeInsets.only(bottom: 20),
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(.06),
            blurRadius: 20,
            offset:
                const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          /////////////////////////////////////////////////////////
          /// IMAGE
          /////////////////////////////////////////////////////////

          _buildProductImage(
  item,
  index,
),

          const SizedBox(height: 16),

          /////////////////////////////////////////////////////////
          /// PRODUCT NAME
          /////////////////////////////////////////////////////////

          Text(
            productName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          /////////////////////////////////////////////////////////
          /// CODE
          /////////////////////////////////////////////////////////

          _infoRow(
            Icons.qr_code_2,
            "Code",
            productCode,
          ),

          const SizedBox(height: 8),

          /////////////////////////////////////////////////////////
          /// VARIANT
          /////////////////////////////////////////////////////////

          _infoRow(
            Icons.tune,
            "Variant",
            variant,
          ),

          const SizedBox(height: 8),

          /////////////////////////////////////////////////////////
          /// QUANTITY
          /////////////////////////////////////////////////////////

          _infoRow(
            Icons.inventory_2_outlined,
            "Quantity",
            "$quantity",
          ),
const SizedBox(height: 18),

///////////////////////////////////////////////////////////
/// EDITABLE CODE
///////////////////////////////////////////////////////////

_editableField(
  controller:
      _codeController(
    index,
    productCode,
  ),
  label: "Product Code",
  icon: Icons.qr_code_2,
  onChanged: (value) {
    AdminOrderService.instance
        .updatePackingItemDetails(
      orderId: widget.orderId,
      itemIndex: index,
      productCode: value,
    );
  },
),

const SizedBox(height: 12),

///////////////////////////////////////////////////////////
/// EDITABLE VARIANT
///////////////////////////////////////////////////////////

_editableField(
  controller:
      _variantController(
    index,
    variant,
  ),
  label: "Variant",
  icon: Icons.tune,
  onChanged: (value) {
    AdminOrderService.instance
        .updatePackingItemDetails(
      orderId: widget.orderId,
      itemIndex: index,
      variant: value,
    );
  },
),

const SizedBox(height: 12),

///////////////////////////////////////////////////////////
/// QUANTITY
///////////////////////////////////////////////////////////

_buildQuantityEditor(
  index: index,
  item: item,
),

const SizedBox(height: 12),

///////////////////////////////////////////////////////////
/// MISSING QUANTITY
///////////////////////////////////////////////////////////

_buildMissingQuantityEditor(
  index: index,
  item: item,
),

const SizedBox(height: 12),

///////////////////////////////////////////////////////////
/// ADMIN NOTE
///////////////////////////////////////////////////////////

_editableField(
  controller:
      _noteController(
    index,
    "",
  ),
  label: "Admin Note",
  icon: Icons.notes_outlined,
  maxLines: 3,
  onChanged: (value) {
    AdminOrderService.instance
        .updatePackingItemDetails(
      orderId: widget.orderId,
      itemIndex: index,
      adminNote: value,
    );
  },
),
          const SizedBox(height: 18),

          /////////////////////////////////////////////////////////
          /// CURRENT STATUS
          /////////////////////////////////////////////////////////

          if (status != null)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 12,
              ),
              decoration: BoxDecoration(
                color: status == "correct"
                    ? Colors.green
                        .withOpacity(.10)
                    : status == "wrong"
                        ? Colors.red
                            .withOpacity(.10)
                        : Colors.orange
                            .withOpacity(.10),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Text(
                status == "correct"
                    ? "✓ Item marked Correct"
                    : status == "wrong"
                        ? "✕ Item marked Wrong"
                        : "⚠ Item marked Missing",
                style: TextStyle(
                  fontWeight:
                      FontWeight.w800,
                  color: status == "correct"
                      ? Colors.green.shade700
                      : status == "wrong"
                          ? Colors.red.shade700
                          : Colors.orange.shade700,
                ),
              ),
            ),

          if (status != null)
            const SizedBox(height: 12),

          /////////////////////////////////////////////////////////
          /// RIGHT / WRONG / MISSING
          /////////////////////////////////////////////////////////

          Row(
            children: [
              _statusButton(
                index: index,
                status: "correct",
                label: "Correct",
                icon:
                    Icons.check_circle_outline,
              ),

              const SizedBox(width: 8),

              _statusButton(
                index: index,
                status: "wrong",
                label: "Wrong",
                icon:
                    Icons.cancel_outlined,
              ),

              const SizedBox(width: 8),

              _statusButton(
                index: index,
                status: "missing",
                label: "Missing",
                icon:
                    Icons.warning_amber_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// INFO ROW
  ///////////////////////////////////////////////////////////
Widget _buildQuantityEditor({
  required int index,
  required Map<String, dynamic> item,
}) {
  final quantity =
      int.tryParse(
            "${item["quantity"] ?? 0}",
          ) ??
          0;

  return Container(
    padding:
        const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xffF7F7F7),
      borderRadius:
          BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.inventory_2_outlined,
        ),

        const SizedBox(width: 10),

        const Expanded(
          child: Text(
            "Quantity",
            style: TextStyle(
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),

        IconButton(
          onPressed: quantity <= 0
              ? null
              : () {
                  final newQuantity =
                      quantity - 1;

                  _saveQuantity(
                    index,
                    newQuantity,
                  );
                },
          icon: const Icon(
            Icons.remove_circle_outline,
          ),
        ),

        Text(
          "$quantity",
          style: const TextStyle(
            fontSize: 17,
            fontWeight:
                FontWeight.w800,
          ),
        ),

        IconButton(
          onPressed: () {
            final newQuantity =
                quantity + 1;

            _saveQuantity(
              index,
              newQuantity,
            );
          },
          icon: const Icon(
            Icons.add_circle_outline,
          ),
        ),
      ],
    ),
  );
}
  Widget _infoRow(
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
          size: 18,
          color: Colors.grey.shade700,
        ),
        const SizedBox(width: 8),
        Text(
          "$title: ",
          style: const TextStyle(
            fontWeight:
                FontWeight.w700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color:
                  Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
  ///////////////////////////////////////////////////////////
/// EDITABLE FIELD
///////////////////////////////////////////////////////////

Widget _editableField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  required ValueChanged<String> onChanged,
  int maxLines = 1,
}) {
  return TextField(
    controller: controller,

    maxLines: maxLines,

    onChanged: onChanged,

    decoration: InputDecoration(
      prefixIcon: Icon(
        icon,
        color: Colors.black87,
      ),

      labelText: label,

      labelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),

      filled: true,

      fillColor:
          const Color(0xffF7F7F7),

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),

        borderSide:
            BorderSide.none,
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),

        borderSide:
            BorderSide(
          color:
              Colors.grey.shade200,
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),

        borderSide:
            const BorderSide(
          color: Colors.black,
          width: 1.2,
        ),
      ),
    ),
  );
}

  ///////////////////////////////////////////////////////////
  /// SUMMARY
  ///////////////////////////////////////////////////////////

  Widget _buildSummary() {
    return Container(
      padding:
          const EdgeInsets.all(18),
      margin:
          const EdgeInsets.only(
        bottom: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius:
            BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          const Text(
            "Packing Summary",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              _summaryItem(
                "Total",
                "$_totalItems",
              ),
              _summaryItem(
                "Correct",
                "$_correctCount",
              ),
              _summaryItem(
                "Wrong",
                "$_wrongCount",
              ),
              _summaryItem(
                "Missing",
                "$_missingCount",
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            "Pending: $_pendingCount",
            style: const TextStyle(
              color: Colors.white70,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// SUMMARY ITEM
  ///////////////////////////////////////////////////////////

  Widget _summaryItem(
    String title,
    String value,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
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
          const Color(0xffF7F7F7),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Packing",
          style: TextStyle(
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ),

      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : _items.isEmpty
              ? const Center(
                  child: Text(
                    "No items found in this order.",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadItems,
                  child: ListView(
                    padding:
                        const EdgeInsets.all(16),
                    children: [

                      /////////////////////////////////////////////////////
                      /// ORDER ID
                      /////////////////////////////////////////////////////

                      Text(
                        "Order: ${widget.orderId}",
                        style: TextStyle(
                          color:
                              Colors.grey.shade700,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 16),

                      /////////////////////////////////////////////////////
                      /// SUMMARY
                      /////////////////////////////////////////////////////

                      _buildSummary(),

                      /////////////////////////////////////////////////////
                      /// ITEMS
                      /////////////////////////////////////////////////////

                      ...List.generate(
                        _items.length,
                        (index) {
                          return _buildItemCard(
                            _items[index],
                            index,
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}