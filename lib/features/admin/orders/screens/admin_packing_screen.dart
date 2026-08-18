import 'package:flutter/material.dart';
import '../services/admin_order_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  ///////////////////////////////////////////////////////////
  /// STATE
  ///////////////////////////////////////////////////////////

  bool _isLoading = true;
  bool _isSaving = false;

  List<Map<String, dynamic>> _items = [];
///////////////////////////////////////////////////////////
/// ADMIN NAME CACHE
///////////////////////////////////////////////////////////

final Map<String, String> _adminNames = {};
  ///////////////////////////////////////////////////////////
  /// CONTROLLERS
  ///////////////////////////////////////////////////////////

  final Map<int, TextEditingController>
      _codeControllers = {};

  final Map<int, TextEditingController>
      _variantControllers = {};

  final Map<int, TextEditingController>
      _noteControllers = {};

  ///////////////////////////////////////////////////////////
  /// IMAGE CONTROLLERS
  ///////////////////////////////////////////////////////////

  final Map<int, PageController>
      _imageControllers = {};

  final Map<int, int>
      _currentImageIndex = {};

  ///////////////////////////////////////////////////////////
  /// INITIALIZE
  ///////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();

    _loadItems();
  }

  ///////////////////////////////////////////////////////////
  /// DISPOSE
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

  ///////////////////////////////////////////////////////////
  /// CONTROLLER HELPERS
  ///////////////////////////////////////////////////////////

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

  ///////////////////////////////////////////////////////////
  /// QUANTITY HELPERS
  ///////////////////////////////////////////////////////////

  int _toInt(dynamic value) {
    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  int _orderedQuantity(
    Map<String, dynamic> item,
  ) {
    return _toInt(
      item["orderedQuantity"] ??
          item["quantity"],
    );
  }

  int _receivedQuantity(
    Map<String, dynamic> item,
  ) {
    return _toInt(
      item["receivedQuantity"],
    );
  }

  int _missingQuantity(
    Map<String, dynamic> item,
  ) {
    return _toInt(
      item["missingQuantity"],
    );
  }

  ///////////////////////////////////////////////////////////
  /// COMPLETE = RECEIVED + MISSING == ORDERED
  ///
  /// IMPORTANT:
  /// Complete does NOT mean Confirmed.
  ///////////////////////////////////////////////////////////

  bool _isItemComplete(
    Map<String, dynamic> item,
  ) {
    final ordered =
        _orderedQuantity(item);

    final received =
        _receivedQuantity(item);

    final missing =
        _missingQuantity(item);

    return ordered >= 0 &&
        received >= 0 &&
        missing >= 0 &&
        received + missing == ordered;
  }
///////////////////////////////////////////////////////////
/// GET ADMIN NAME
///////////////////////////////////////////////////////////

Future<String> _getAdminName(
  String adminId,
) async {
  final id = adminId.trim();

  if (id.isEmpty) {
    return "Unknown Admin";
  }

  // Already loaded
  if (_adminNames.containsKey(id)) {
    return _adminNames[id]!;
  }

  try {
    final adminDoc = await FirebaseFirestore
        .instance
        .collection("admins")
        .doc(id)
        .get();

    if (adminDoc.exists) {
      final data =
          adminDoc.data() ?? {};

      final fullName =
          (data["fullName"] ?? "")
              .toString()
              .trim();

      if (fullName.isNotEmpty) {
        _adminNames[id] = fullName;
        return fullName;
      }

      final email =
          (data["email"] ?? "")
              .toString()
              .trim();

      if (email.isNotEmpty) {
        _adminNames[id] = email;
        return email;
      }
    }
  } catch (_) {}

  _adminNames[id] = id;

  return id;
}
  ///////////////////////////////////////////////////////////
  /// CONFIRMED
  ///////////////////////////////////////////////////////////

  bool _isItemConfirmed(
    Map<String, dynamic> item,
  ) {
    return item["packingStatus"]
            ?.toString()
            .trim()
            .toLowerCase() ==
        "confirmed";
  }

  ///////////////////////////////////////////////////////////
  /// TOTAL ORDERED
  ///////////////////////////////////////////////////////////

  int get _totalItems {
    return _items.fold<int>(
      0,
      (sum, item) =>
          sum + _orderedQuantity(item),
    );
  }

  ///////////////////////////////////////////////////////////
  /// TOTAL RECEIVED
  ///////////////////////////////////////////////////////////

  int get _receivedItems {
    return _items.fold<int>(
      0,
      (sum, item) =>
          sum + _receivedQuantity(item),
    );
  }

  ///////////////////////////////////////////////////////////
  /// TOTAL MISSING
  ///////////////////////////////////////////////////////////

  int get _missingItems {
    return _items.fold<int>(
      0,
      (sum, item) =>
          sum + _missingQuantity(item),
    );
  }

  ///////////////////////////////////////////////////////////
  /// CONFIRMED COUNT
  ///
  /// IMPORTANT:
  /// Only actual "confirmed" status counts.
  ///////////////////////////////////////////////////////////

  int get _confirmedCount {
    return _items
        .where(_isItemConfirmed)
        .length;
  }

  ///////////////////////////////////////////////////////////
  /// PENDING COUNT
  ///////////////////////////////////////////////////////////

  int get _pendingCount {
    return _items.length -
        _confirmedCount;
  }

  ///////////////////////////////////////////////////////////
  /// READY TO CONFIRM
  ///////////////////////////////////////////////////////////

  int get _readyToConfirmCount {
    return _items
        .where(
          (item) =>
              _isItemComplete(item) &&
              !_isItemConfirmed(item),
        )
        .length;
  }

  ///////////////////////////////////////////////////////////
  /// TOTAL PRODUCT LINES
  ///////////////////////////////////////////////////////////

  int get _totalProductLines {
    return _items.length;
  }

  ///////////////////////////////////////////////////////////
  /// LOAD EVERYTHING
  ///////////////////////////////////////////////////////////

  Future<void> _loadItems() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      final originalItems =
          await AdminOrderService.instance
              .getOrderItems(
        widget.orderId,
      );

      final packingData =
          await AdminOrderService.instance
              .getPackingData(
        widget.orderId,
      );

      final rawPackingItems =
          packingData["items"];

      final List<dynamic>
          savedPackingItems =
          rawPackingItems is List
              ? rawPackingItems
              : [];

      final mergedItems =
          <Map<String, dynamic>>[];

      /////////////////////////////////////////////////////////
      /// MERGE ORIGINAL ORDER + PACKING DATA
      /////////////////////////////////////////////////////////

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
        /// ORDERED IS ALWAYS FROM ORIGINAL ORDER
        ///////////////////////////////////////////////////////

        final ordered =
            _toInt(
          original["quantity"],
        );

        original["orderedQuantity"] =
            ordered;

        ///////////////////////////////////////////////////////
        /// DEFAULT VALUES
        ///////////////////////////////////////////////////////

        int received = 0;
        int missing = 0;

        String packingStatus = "";

        ///////////////////////////////////////////////////////
        /// LOAD SAVED PACKING DATA
        ///////////////////////////////////////////////////////

        if (
          index <
          savedPackingItems.length
        ) {
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

            if (
              savedMap["productCode"] !=
              null
            ) {
              original["productCode"] =
                  savedMap[
                    "productCode"
                  ];
            }

            ///////////////////////////////////////////////////
            /// VARIANT
            ///////////////////////////////////////////////////

            if (
              savedMap["variant"] !=
              null
            ) {
              original[
                    "variationLabel"] =
                  savedMap[
                    "variant"
                  ];
            }

            ///////////////////////////////////////////////////
            /// RECEIVED
            ///
            /// Backward compatibility:
            /// old "quantity" is treated as received.
            ///////////////////////////////////////////////////

            if (
              savedMap["quantity"] !=
              null
            ) {
              received =
                  _toInt(
                savedMap[
                  "quantity"
                ],
              );
            }

            ///////////////////////////////////////////////////
            /// NEW RECEIVED QUANTITY
            ///////////////////////////////////////////////////

            if (
              savedMap[
                    "receivedQuantity"
                  ] !=
                  null
            ) {
              received =
                  _toInt(
                savedMap[
                  "receivedQuantity"
                ],
              );
            }

            ///////////////////////////////////////////////////
            /// MISSING
            ///////////////////////////////////////////////////

            if (
              savedMap[
                    "missingQuantity"
                  ] !=
                  null
            ) {
              missing =
                  _toInt(
                savedMap[
                  "missingQuantity"
                ],
              );
            }

            ///////////////////////////////////////////////////
            /// ADMIN NOTE
            ///////////////////////////////////////////////////

            if (
              savedMap[
                    "adminNote"
                  ] !=
                  null
            ) {
              original[
                    "adminNote"] =
                  savedMap[
                    "adminNote"
                  ];
            }

            ///////////////////////////////////////////////////
            /// STATUS
            ///////////////////////////////////////////////////

            packingStatus =
                (
                  savedMap["status"] ??
                      savedMap[
                        "packingStatus"
                      ] ??
                      ""
                )
                    .toString()
                    .trim();

            ///////////////////////////////////////////////////
            /// CONFIRMATION META
            ///
            /// These are loaded if the service already
            /// stores them.
            ///////////////////////////////////////////////////

            if (
              savedMap[
                    "confirmedBy"
                  ] !=
                  null
            ) {
              original[
                    "confirmedBy"] =
                  savedMap[
                    "confirmedBy"
                  ];
            }

            if (
              savedMap[
                    "confirmedAt"
                  ] !=
                  null
            ) {
              original[
                    "confirmedAt"] =
                  savedMap[
                    "confirmedAt"
                  ];
            }

            ///////////////////////////////////////////////////
            /// UPDATED META
            ///////////////////////////////////////////////////

            if (
              savedMap[
                    "updatedBy"
                  ] !=
                  null
            ) {
              original[
                    "updatedBy"] =
                  savedMap[
                    "updatedBy"
                  ];
            }

            if (
              savedMap[
                    "updatedAt"
                  ] !=
                  null
            ) {
              original[
                    "updatedAt"] =
                  savedMap[
                    "updatedAt"
                  ];
            }
          }
        }

        ///////////////////////////////////////////////////////
        /// SANITIZE VALUES
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
        /// NEVER ALLOW RECEIVED + MISSING > ORDERED
        ///////////////////////////////////////////////////////

        if (
          received + missing >
          ordered
        ) {
          missing =
              ordered - received;

          if (missing < 0) {
            missing = 0;
          }
        }

        ///////////////////////////////////////////////////////
        /// STORE LOCAL VALUES
        ///////////////////////////////////////////////////////

        original[
              "receivedQuantity"] =
            received;

        original[
              "missingQuantity"] =
            missing;

        original[
              "packingStatus"] =
            packingStatus;

        mergedItems.add(
          original,
        );
      }

      if (!mounted) return;

      setState(() {
        _items = mergedItems;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showError(
        "Failed to load packing items: $e",
      );
    }
  }

  ///////////////////////////////////////////////////////////
  /// ERROR
  ///////////////////////////////////////////////////////////

  void _showError(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        behavior:
            SnackBarBehavior.floating,
        backgroundColor:
            const Color(0xff241B2F),
        margin:
            const EdgeInsets.all(16),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
        ),
        content:
            Text(
          message,
          style:
              const TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// SUCCESS
  ///////////////////////////////////////////////////////////

  void _showSuccess(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        behavior:
            SnackBarBehavior.floating,
        backgroundColor:
            Colors.green.shade700,
        margin:
            const EdgeInsets.all(16),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
        ),
        content:
            Text(
          message,
          style:
              const TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// SAVE RECEIVED QUANTITY
  ///////////////////////////////////////////////////////////

  Future<void> _saveReceivedQuantity(
    int index,
    int quantity,
  ) async {
    if (
      index < 0 ||
      index >= _items.length ||
      quantity < 0
    ) {
      return;
    }

    final item =
        _items[index];

    final ordered =
        _orderedQuantity(item);

    final missing =
        _missingQuantity(item);

    /////////////////////////////////////////////////////////
    /// VALIDATION
    /////////////////////////////////////////////////////////

    if (
      quantity + missing >
      ordered
    ) {
      _showError(
        "Received + Missing cannot exceed Ordered quantity.",
      );
      return;
    }

    final previousReceived =
        _receivedQuantity(item);

    final previousStatus =
        item["packingStatus"];

    final wasConfirmed =
        _isItemConfirmed(item);

    /////////////////////////////////////////////////////////
    /// OPTIMISTIC UI
    /////////////////////////////////////////////////////////

    setState(() {
      item["receivedQuantity"] =
          quantity;

      ///////////////////////////////////////////////////////
      /// If a confirmed item is edited, it becomes pending.
      ///////////////////////////////////////////////////////

      if (wasConfirmed) {
        item["packingStatus"] =
            "";
      }
    });

    try {
      /////////////////////////////////////////////////////////
      /// SAVE RECEIVED
      /////////////////////////////////////////////////////////

      await AdminOrderService.instance
          .updatePackingItemDetails(
        orderId: widget.orderId,
        itemIndex: index,
        quantity: quantity,
      );

      /////////////////////////////////////////////////////////
      /// IF PREVIOUSLY CONFIRMED, RESET STATUS
      /////////////////////////////////////////////////////////

      if (wasConfirmed) {
        await AdminOrderService.instance
            .savePackingItemStatus(
          orderId: widget.orderId,
          itemIndex: index,
          status: "pending",
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        item["receivedQuantity"] =
            previousReceived;

        item["packingStatus"] =
            previousStatus;
      });

      _showError(
        "Failed to update received quantity: $e",
      );
    }
  }

  ///////////////////////////////////////////////////////////
  /// SAVE MISSING QUANTITY
  ///////////////////////////////////////////////////////////

  Future<void> _saveMissingQuantity(
    int index,
    int quantity,
  ) async {
    if (
      index < 0 ||
      index >= _items.length ||
      quantity < 0
    ) {
      return;
    }

    final item =
        _items[index];

    final ordered =
        _orderedQuantity(item);

    final received =
        _receivedQuantity(item);

    /////////////////////////////////////////////////////////
    /// VALIDATION
    /////////////////////////////////////////////////////////

    if (
      received + quantity >
      ordered
    ) {
      _showError(
        "Received + Missing cannot exceed Ordered quantity.",
      );
      return;
    }

    final previousMissing =
        _missingQuantity(item);

    final previousStatus =
        item["packingStatus"];

    final wasConfirmed =
        _isItemConfirmed(item);

    /////////////////////////////////////////////////////////
    /// OPTIMISTIC UI
    /////////////////////////////////////////////////////////

    setState(() {
      item["missingQuantity"] =
          quantity;

      if (wasConfirmed) {
        item["packingStatus"] =
            "";
      }
    });

    try {
      /////////////////////////////////////////////////////////
      /// SAVE MISSING
      /////////////////////////////////////////////////////////

      await AdminOrderService.instance
          .updatePackingItemDetails(
        orderId: widget.orderId,
        itemIndex: index,
        missingQuantity: quantity,
      );

      /////////////////////////////////////////////////////////
      /// RESET CONFIRMED STATUS
      /////////////////////////////////////////////////////////

      if (wasConfirmed) {
        await AdminOrderService.instance
            .savePackingItemStatus(
          orderId: widget.orderId,
          itemIndex: index,
          status: "pending",
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        item["missingQuantity"] =
            previousMissing;

        item["packingStatus"] =
            previousStatus;
      });

      _showError(
        "Failed to update missing quantity: $e",
      );
    }
  }

  ///////////////////////////////////////////////////////////
  /// CONFIRM ITEM
  ///////////////////////////////////////////////////////////

  ///////////////////////////////////////////////////////////
/// CONFIRM ITEM
///////////////////////////////////////////////////////////

Future<void> _confirmItem(
  int index,
) async {
  if (
    index < 0 ||
    index >= _items.length
  ) {
    return;
  }

  if (_isSaving) {
    return;
  }

  final item = _items[index];

  final ordered =
      _orderedQuantity(item);

  final received =
      _receivedQuantity(item);

  final missing =
      _missingQuantity(item);

  /////////////////////////////////////////////////////////
  /// VALIDATE
  /////////////////////////////////////////////////////////

  if (
    received + missing !=
    ordered
  ) {
    _showError(
      "Received + Missing must equal Ordered quantity before confirming.",
    );
    return;
  }

  /////////////////////////////////////////////////////////
  /// ALREADY CONFIRMED
  /////////////////////////////////////////////////////////

  if (_isItemConfirmed(item)) {
    return;
  }

  /////////////////////////////////////////////////////////
  /// SAVE LOCK
  /////////////////////////////////////////////////////////

  setState(() {
    _isSaving = true;
  });

  try {
    /////////////////////////////////////////////////////////
    /// CONFIRM THROUGH SERVICE
    ///
    /// IMPORTANT:
    /// This saves:
    /// confirmedBy
    /// confirmedAt
    /// status = confirmed
    /////////////////////////////////////////////////////////

    await AdminOrderService.instance
        .confirmPackingItem(
      orderId: widget.orderId,
      itemIndex: index,
    );

    if (!mounted) return;

    /////////////////////////////////////////////////////////
    /// LOCAL STATUS
    /////////////////////////////////////////////////////////

    setState(() {
      item["packingStatus"] =
          "confirmed";

      // Keep local confirmation
      // information visible immediately.
      //
      // The actual confirmedBy / confirmedAt
      // values are saved by Firestore service.
    });

    _showSuccess(
      "Item confirmed successfully.",
    );

    /////////////////////////////////////////////////////////
    /// RELOAD
    ///
    /// This makes sure confirmedBy,
    /// confirmedAt and overall counts
    /// are loaded from Firestore.
    /////////////////////////////////////////////////////////

    await _loadItems();

  } catch (e) {
    if (!mounted) return;

    _showError(
      "Failed to confirm item: $e",
    );
  } finally {
    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });
  }
}

  ///////////////////////////////////////////////////////////
  /// SAVE CODE
  ///////////////////////////////////////////////////////////

  Future<void> _saveProductCode(
    int index,
    String value,
  ) async {
    try {
      await AdminOrderService.instance
          .updatePackingItemDetails(
        orderId: widget.orderId,
        itemIndex: index,
        productCode: value,
      );
    } catch (e) {
      _showError(
        "Failed to save product code: $e",
      );
    }
  }

  ///////////////////////////////////////////////////////////
  /// SAVE VARIANT
  ///////////////////////////////////////////////////////////

  Future<void> _saveVariant(
    int index,
    String value,
  ) async {
    try {
      await AdminOrderService.instance
          .updatePackingItemDetails(
        orderId: widget.orderId,
        itemIndex: index,
        variant: value,
      );
    } catch (e) {
      _showError(
        "Failed to save variant: $e",
      );
    }
  }

  ///////////////////////////////////////////////////////////
  /// SAVE NOTE
  ///////////////////////////////////////////////////////////

  Future<void> _saveNote(
    int index,
    String value,
  ) async {
    try {
      await AdminOrderService.instance
          .updatePackingItemDetails(
        orderId: widget.orderId,
        itemIndex: index,
        adminNote: value,
      );
    } catch (e) {
      _showError(
        "Failed to save admin note: $e",
      );
    }
  }

  ///////////////////////////////////////////////////////////
  /// VARIANT TEXT
  ///////////////////////////////////////////////////////////

  String _getVariant(
    Map<String, dynamic> item,
  ) {
    final packingVariant =
        (item["packingVariant"] ??
                "")
            .toString()
            .trim();

    if (packingVariant.isNotEmpty) {
      return packingVariant;
    }

    final variationLabel =
        (item["variationLabel"] ??
                "")
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
  /// IMAGES
  ///////////////////////////////////////////////////////////

  List<String> _getImages(
    Map<String, dynamic> item,
  ) {
    final imagesRaw =
        item["images"];

    final images =
        <String>[];

    /////////////////////////////////////////////////////////
    /// MULTIPLE IMAGES
    /////////////////////////////////////////////////////////

    if (imagesRaw is List) {
      for (
        final image
        in imagesRaw
      ) {
        final url =
            image
                .toString()
                .trim();

        if (url.isNotEmpty) {
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

    if (
      images.isEmpty &&
      singleImage.isNotEmpty
    ) {
      images.add(
        singleImage,
      );
    }

    return images;
  }

  ///////////////////////////////////////////////////////////
  /// PRODUCT IMAGE
  ///////////////////////////////////////////////////////////

  Widget _buildProductImage(
    Map<String, dynamic> item,
    int index,
  ) {
    final images =
        _getImages(item);

    /////////////////////////////////////////////////////////
    /// NO IMAGE
    /////////////////////////////////////////////////////////

    if (images.isEmpty) {
      return Container(
        height: 280,
        width: double.infinity,
        decoration:
            BoxDecoration(
          color:
              const Color(
            0xffF5F2F3,
          ),
          borderRadius:
              BorderRadius.circular(
            20,
          ),
        ),
        child:
            const Center(
          child: Icon(
            Icons
                .image_not_supported_outlined,
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
        _imageControllers
            .putIfAbsent(
      index,
      () => PageController(),
    );

    final currentIndex =
        _currentImageIndex[
                index] ??
            0;

    /////////////////////////////////////////////////////////
    /// IMAGE VIEW
    /////////////////////////////////////////////////////////

    return Column(
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
              child: SizedBox(
                height: 280,
                width:
                    double.infinity,
                child:
                    PageView.builder(
                  controller:
                      controller,
                  itemCount:
                      images.length,
                  onPageChanged:
                      (page) {
                    if (!mounted) {
                      return;
                    }

                    setState(() {
                      _currentImageIndex[
                              index] =
                          page;
                    });
                  },
                  itemBuilder:
                      (
                    context,
                    imageIndex,
                  ) {
                    return GestureDetector(
                      onTap: () {
                        _showFullImage(
                          images,
                          imageIndex,
                        );
                      },
                      child:
                          Image.network(
                        images[
                            imageIndex],
                        fit:
                            BoxFit.cover,
                        width:
                            double.infinity,
                        errorBuilder:
                            (
                          _,
                          __,
                          ___,
                        ) {
                          return Container(
                            color:
                                const Color(
                              0xffF5F2F3,
                            ),
                            child:
                                const Center(
                              child:
                                  Icon(
                                Icons
                                    .broken_image_outlined,
                                size:
                                    50,
                                color:
                                    Colors.grey,
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
                                const Color(
                              0xffF5F2F3,
                            ),
                            child:
                                const Center(
                              child:
                                  CircularProgressIndicator(),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),

            ///////////////////////////////////////////////////
            /// IMAGE COUNTER
            ///////////////////////////////////////////////////

            Positioned(
              top: 12,
              right: 12,
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
                    .68,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child:
                    Text(
                  "${currentIndex + 1} / ${images.length}",
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

            ///////////////////////////////////////////////////
            /// PREVIOUS
            ///////////////////////////////////////////////////

            if (
              images.length > 1 &&
              currentIndex > 0
            )
              Positioned(
                left: 10,
                top: 0,
                bottom: 0,
                child:
                    Center(
                  child:
                      _imageArrow(
                    icon: Icons
                        .chevron_left_rounded,
                    onTap: () {
                      controller
                          .previousPage(
                        duration:
                            const Duration(
                          milliseconds:
                              220,
                        ),
                        curve:
                            Curves.easeOut,
                      );
                    },
                  ),
                ),
              ),

            ///////////////////////////////////////////////////
            /// NEXT
            ///////////////////////////////////////////////////

            if (
              images.length > 1 &&
              currentIndex <
                  images.length - 1
            )
              Positioned(
                right: 10,
                top: 0,
                bottom: 0,
                child:
                    Center(
                  child:
                      _imageArrow(
                    icon: Icons
                        .chevron_right_rounded,
                    onTap: () {
                      controller
                          .nextPage(
                        duration:
                            const Duration(
                          milliseconds:
                              220,
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

        ///////////////////////////////////////////////////////
        /// DOTS
        ///////////////////////////////////////////////////////

        if (images.length > 1)
          Padding(
            padding:
                const EdgeInsets.only(
              top: 10,
            ),
            child:
                Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .center,
              children:
                  List.generate(
                images.length,
                (dotIndex) {
                  final selected =
                      dotIndex ==
                          currentIndex;

                  return AnimatedContainer(
                    duration:
                        const Duration(
                      milliseconds:
                          180,
                    ),
                    margin:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 3,
                    ),
                    width:
                        selected
                            ? 18
                            : 6,
                    height: 6,
                    decoration:
                        BoxDecoration(
                      color: selected
                          ? Colors.black
                          : Colors
                              .grey
                              .shade300,
                      borderRadius:
                          BorderRadius
                              .circular(
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

  ///////////////////////////////////////////////////////////
  /// IMAGE ARROW
  ///////////////////////////////////////////////////////////

  Widget _imageArrow({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color:
          Colors.black.withOpacity(
        .55,
      ),
      shape:
          const CircleBorder(),
      child:
          InkWell(
        customBorder:
            const CircleBorder(),
        onTap:
            onTap,
        child:
            Padding(
          padding:
              const EdgeInsets.all(
            6,
          ),
          child:
              Icon(
            icon,
            color:
                Colors.white,
            size: 25,
          ),
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// FULL IMAGE DIALOG
  ///////////////////////////////////////////////////////////

  void _showFullImage(
    List<String> images,
    int initialIndex,
  ) {
    showDialog(
      context: context,
      barrierColor:
          Colors.black.withOpacity(
        .88,
      ),
      builder: (_) {
        return Dialog(
          backgroundColor:
              Colors.transparent,
          insetPadding:
              const EdgeInsets.all(
            14,
          ),
          child:
              Stack(
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
                child:
                    InteractiveViewer(
                  child:
                      Image.network(
                    images[
                        initialIndex],
                    fit:
                        BoxFit.contain,
                    errorBuilder:
                        (
                      _,
                      __,
                      ___,
                    ) {
                      return Container(
                        height:
                            400,
                        color:
                            Colors.white,
                        child:
                            const Center(
                          child:
                              Icon(
                            Icons
                                .broken_image_outlined,
                            size: 50,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              Positioned(
                top: 10,
                right: 10,
                child:
                    Material(
                  color:
                      Colors.black
                          .withOpacity(
                    .55,
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
                      Icons
                          .close_rounded,
                      color:
                          Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  ///////////////////////////////////////////////////////////
  /// EDITABLE FIELD
  ///////////////////////////////////////////////////////////

  Widget _editableField({
    required TextEditingController
        controller,
    required String label,
    required IconData icon,
    required ValueChanged<String>
        onChanged,
    int maxLines = 1,
    TextInputType? keyboardType,
    VoidCallback? onEditingComplete,
  }) {
    return TextField(
      controller:
          controller,
      maxLines:
          maxLines,
      keyboardType:
          keyboardType,
      onChanged:
          onChanged,
      onEditingComplete:
          onEditingComplete,
      textInputAction:
          maxLines > 1
              ? TextInputAction
                  .newline
              : TextInputAction
                  .done,
      decoration:
          InputDecoration(
        prefixIcon:
            Icon(
          icon,
          color:
              const Color(
            0xff6A5962,
          ),
        ),
        labelText:
            label,
        labelStyle:
            const TextStyle(
          fontSize: 12,
          fontWeight:
              FontWeight.w600,
        ),
        filled:
            true,
        fillColor:
            const Color(
          0xffF7F4F5,
        ),
        contentPadding:
            const EdgeInsets
                .symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          borderSide:
              BorderSide.none,
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          borderSide:
              const BorderSide(
            color:
                Color(
              0xffECE3E7,
            ),
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          borderSide:
              const BorderSide(
            color:
                Colors.black,
            width: 1.1,
          ),
        ),
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// INFO ROW
  ///////////////////////////////////////////////////////////

  Widget _infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment
              .start,
      children: [
        Icon(
          icon,
          size: 18,
          color:
              const Color(
            0xff76656D,
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Text(
          "$title: ",
          style:
              const TextStyle(
            fontSize: 12,
            fontWeight:
                FontWeight.w800,
          ),
        ),
        Expanded(
          child:
              Text(
            value,
            style:
                const TextStyle(
              fontSize: 12,
              color:
                  Color(
                0xff76656D,
              ),
            ),
          ),
        ),
      ],
    );
  }

  ///////////////////////////////////////////////////////////
  /// ORDERED QUANTITY
  ///////////////////////////////////////////////////////////

  Widget _buildOrderedQuantity({
    required Map<String, dynamic>
        item,
  }) {
    final quantity =
        _orderedQuantity(item);

    return _staticQuantityCard(
      icon:
          Icons.shopping_cart_outlined,
      title:
          "Ordered Quantity",
      value:
          quantity,
      color:
          const Color(
        0xffF3F0F2,
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// RECEIVED QUANTITY
  ///////////////////////////////////////////////////////////

  Widget _buildReceivedQuantityEditor({
    required int index,
    required Map<String, dynamic>
        item,
  }) {
    final received =
        _receivedQuantity(item);

    final ordered =
        _orderedQuantity(item);

    final missing =
        _missingQuantity(item);

    final maxReceived =
        ordered - missing;

    return _counterCard(
      icon:
          Icons.inventory_2_outlined,
      title:
          "Received Quantity",
      value:
          received,
      color:
          const Color(
        0xffEEF8F1,
      ),
      iconColor:
          Colors.green.shade700,
      onMinus:
          received > 0
              ? () =>
                  _saveReceivedQuantity(
                    index,
                    received - 1,
                  )
              : null,
      onPlus:
          received < maxReceived
              ? () =>
                  _saveReceivedQuantity(
                    index,
                    received + 1,
                  )
              : null,
    );
  }

  ///////////////////////////////////////////////////////////
  /// MISSING QUANTITY
  ///////////////////////////////////////////////////////////

  Widget _buildMissingQuantityEditor({
    required int index,
    required Map<String, dynamic>
        item,
  }) {
    final missing =
        _missingQuantity(item);

    final ordered =
        _orderedQuantity(item);

    final received =
        _receivedQuantity(item);

    final maxMissing =
        ordered - received;

    return _counterCard(
      icon:
          Icons.warning_amber_outlined,
      title:
          "Missing Quantity",
      value:
          missing,
      color:
          const Color(
        0xfffff8e1,
      ),
      iconColor:
          Colors.orange.shade700,
      onMinus:
          missing > 0
              ? () =>
                  _saveMissingQuantity(
                    index,
                    missing - 1,
                  )
              : null,
      onPlus:
          missing < maxMissing
              ? () =>
                  _saveMissingQuantity(
                    index,
                    missing + 1,
                  )
              : null,
    );
  }

  ///////////////////////////////////////////////////////////
  /// STATIC QUANTITY CARD
  ///////////////////////////////////////////////////////////

  Widget _staticQuantityCard({
    required IconData icon,
    required String title,
    required int value,
    required Color color,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(
        13,
      ),
      decoration:
          BoxDecoration(
        color: color,
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
      child:
          Row(
        children: [
          Icon(
            icon,
            color:
                const Color(
              0xff4E4348,
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
                fontSize: 12,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),
          Text(
            "$value",
            style:
                const TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// COUNTER CARD
  ///////////////////////////////////////////////////////////

  Widget _counterCard({
    required IconData icon,
    required String title,
    required int value,
    required Color color,
    Color? iconColor,
    required VoidCallback? onMinus,
    required VoidCallback? onPlus,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(
        13,
      ),
      decoration:
          BoxDecoration(
        color: color,
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
      child:
          Row(
        children: [
          Icon(
            icon,
            color:
                iconColor ??
                    const Color(
                  0xff4E4348,
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
                fontSize: 12,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),

          ///////////////////////////////////////////////////
          /// MINUS
          ///////////////////////////////////////////////////

          IconButton(
            visualDensity:
                VisualDensity
                    .compact,
            onPressed:
                onMinus,
            icon:
                const Icon(
              Icons
                  .remove_circle_outline,
            ),
          ),

          ///////////////////////////////////////////////////
          /// VALUE
          ///////////////////////////////////////////////////

          Text(
            "$value",
            style:
                const TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          ///////////////////////////////////////////////////
          /// PLUS
          ///////////////////////////////////////////////////

          IconButton(
            visualDensity:
                VisualDensity
                    .compact,
            onPressed:
                onPlus,
            icon:
                const Icon(
              Icons
                  .add_circle_outline,
            ),
          ),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// CONFIRMATION META
  ///////////////////////////////////////////////////////////

  ///////////////////////////////////////////////////////////
/// CONFIRMATION + UPDATE META
///////////////////////////////////////////////////////////

Widget _buildConfirmationInfo(
  Map<String, dynamic> item,
) {
  final confirmed =
      _isItemConfirmed(item);

  /////////////////////////////////////////////////////////
  /// CONFIRMED DATA
  /////////////////////////////////////////////////////////

  final confirmedById =
    (item["confirmedBy"] ?? "")
        .toString()
        .trim();

  final confirmedAt =
      item["confirmedAt"];

  /////////////////////////////////////////////////////////
  /// UPDATED DATA
  /////////////////////////////////////////////////////////

 final updatedById =
    (item["updatedBy"] ?? "")
        .toString()
        .trim();

  final updatedAt =
      item["updatedAt"];

  /////////////////////////////////////////////////////////
  /// NOTHING YET
  /////////////////////////////////////////////////////////

  if (!confirmed &&
    updatedById.isEmpty &&
    updatedAt == null) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xffF7F4F5),
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xffECE3E7),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.pending_actions,
            size: 18,
            color: Color(0xff76656D),
          ),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              "Not confirmed yet",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xff76656D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /////////////////////////////////////////////////////////
  /// CARD
  /////////////////////////////////////////////////////////

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: confirmed
          ? const Color(0xffF0F9F2)
          : const Color(0xffF7F4F5),
      borderRadius:
          BorderRadius.circular(14),
      border: Border.all(
        color: confirmed
            ? Colors.green.shade200
            : const Color(0xffECE3E7),
      ),
    ),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        ///////////////////////////////////////////////////
        /// STATUS
        ///////////////////////////////////////////////////

        Row(
          children: [
            Icon(
              confirmed
                  ? Icons.check_circle_rounded
                  : Icons.pending_actions,
              size: 19,
              color: confirmed
                  ? Colors.green.shade700
                  : const Color(0xff76656D),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Text(
                confirmed
                    ? "Confirmed"
                    : "Pending Confirmation",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: confirmed
                      ? const Color(0xff256B36)
                      : const Color(0xff76656D),
                ),
              ),
            ),
          ],
        ),

        ///////////////////////////////////////////////////
        /// CONFIRMED BY
        ///////////////////////////////////////////////////

        if (confirmedById.isNotEmpty) ...[
  const SizedBox(height: 10),

  FutureBuilder<String>(
    future: _getAdminName(confirmedById),
    builder: (
      context,
      snapshot,
    ) {
      return _infoRow(
        Icons.person_outline,
        "Confirmed By",
        snapshot.data ?? "Loading...",
      );
    },
  ),
],

        ///////////////////////////////////////////////////
        /// CONFIRMED AT
        ///////////////////////////////////////////////////

        if (confirmedAt != null) ...[
          const SizedBox(height: 8),

          _infoRow(
            Icons.schedule_outlined,
            "Confirmed At",
            _formatDateTime(
              confirmedAt,
            ),
          ),
        ],

        ///////////////////////////////////////////////////
        /// DIVIDER
        ///////////////////////////////////////////////////

        if (updatedById.isNotEmpty ||
    updatedAt != null) ...[
          const SizedBox(height: 12),

          Divider(
            height: 1,
            color: confirmed
                ? Colors.green.shade200
                : const Color(0xffE5DDE1),
          ),

          const SizedBox(height: 12),
        ],

        ///////////////////////////////////////////////////
        /// LAST UPDATED
        ///////////////////////////////////////////////////
if (updatedById.isNotEmpty) ...[
  FutureBuilder<String>(
    future: _getAdminName(updatedById),
    builder: (
      context,
      snapshot,
    ) {
      return _infoRow(
        Icons.edit_outlined,
        "Last Updated By",
        snapshot.data ?? "Loading...",
      );
    },
  ),
],

        ///////////////////////////////////////////////////
        /// LAST UPDATED AT
        ///////////////////////////////////////////////////

        if (updatedAt != null) ...[
          const SizedBox(height: 8),

          _infoRow(
            Icons.update_outlined,
            "Last Updated At",
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
  /// FORMAT DATE
  ///////////////////////////////////////////////////////////

  ///////////////////////////////////////////////////////////
/// FORMAT DATE TIME
///////////////////////////////////////////////////////////

String _formatDateTime(
  dynamic value,
) {
  if (value == null) {
    return "N/A";
  }

  try {
    DateTime? date;

    /////////////////////////////////////////////////////////
    /// FIRESTORE TIMESTAMP
    /////////////////////////////////////////////////////////

    if (value is Timestamp) {
      date = value.toDate();
    }

    /////////////////////////////////////////////////////////
    /// DATETIME
    /////////////////////////////////////////////////////////

    else if (value is DateTime) {
      date = value;
    }

    /////////////////////////////////////////////////////////
    /// STRING
    /////////////////////////////////////////////////////////

    else if (value is String) {
      date = DateTime.tryParse(value);
    }

    /////////////////////////////////////////////////////////
    /// FORMAT
    /////////////////////////////////////////////////////////

    if (date != null) {
      return _formatDate(date);
    }
  } catch (_) {}

  return "N/A";
}

  String _formatDate(
    DateTime date,
  ) {
    final day =
        date.day
            .toString()
            .padLeft(2, '0');

    final month =
        date.month
            .toString()
            .padLeft(2, '0');

    final year =
        date.year
            .toString();

    final hour =
        date.hour
            .toString()
            .padLeft(2, '0');

    final minute =
        date.minute
            .toString()
            .padLeft(2, '0');

    return "$day/$month/$year $hour:$minute";
  }

  ///////////////////////////////////////////////////////////
  /// ITEM CARD
  ///////////////////////////////////////////////////////////

  Widget _buildItemCard(
    Map<String, dynamic> item,
    int index,
  ) {
    final productName =
        (item["productName"] ??
                "Product")
            .toString();

    final productCode =
        (item["productCode"] ??
                "N/A")
            .toString();

    final variant =
        _getVariant(item);

    final ordered =
        _orderedQuantity(item);

    final received =
        _receivedQuantity(item);

    final missing =
        _missingQuantity(item);

    final complete =
        _isItemComplete(item);

    final confirmed =
        _isItemConfirmed(item);

    final adminNote =
        (item["adminNote"] ??
                "")
            .toString();

    final codeController =
        _codeController(
      index,
      productCode,
    );

    final variantController =
        _variantController(
      index,
      variant,
    );

    final noteController =
        _noteController(
      index,
      adminNote,
    );

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 20,
      ),
      padding:
          const EdgeInsets.all(
        16,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          22,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xffEEE7EA,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black
                    .withOpacity(
              .045,
            ),
            blurRadius: 18,
            offset:
                const Offset(
              0,
              7,
            ),
          ),
        ],
      ),
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [

          ///////////////////////////////////////////////////
          /// IMAGE
          ///////////////////////////////////////////////////

          _buildProductImage(
            item,
            index,
          ),

          const SizedBox(
            height: 18,
          ),

          ///////////////////////////////////////////////////
          /// PRODUCT NAME
          ///////////////////////////////////////////////////

          Text(
            productName,
            style:
                const TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w900,
              color:
                  Color(
                0xff241B2F,
              ),
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          ///////////////////////////////////////////////////
          /// BASIC INFO
          ///////////////////////////////////////////////////

          _infoRow(
            Icons.qr_code_2,
            "Code",
            productCode,
          ),

          const SizedBox(
            height: 8,
          ),

          _infoRow(
            Icons.tune,
            "Variant",
            variant,
          ),

          const SizedBox(
            height: 8,
          ),

          _infoRow(
            Icons
                .shopping_cart_outlined,
            "Ordered",
            "$ordered",
          ),

          const SizedBox(
            height: 18,
          ),

          ///////////////////////////////////////////////////
          /// PRODUCT CODE
          ///////////////////////////////////////////////////

          _editableField(
            controller:
                codeController,
            label:
                "Product Code",
            icon:
                Icons.qr_code_2,
            onChanged:
                (_) {},
            onEditingComplete:
                () {
              _saveProductCode(
                index,
                codeController
                    .text,
              );

              FocusScope.of(
                context,
              ).unfocus();
            },
          ),

          const SizedBox(
            height: 12,
          ),

          ///////////////////////////////////////////////////
          /// VARIANT
          ///////////////////////////////////////////////////

          _editableField(
            controller:
                variantController,
            label:
                "Variant",
            icon:
                Icons.tune,
            onChanged:
                (_) {},
            onEditingComplete:
                () {
              _saveVariant(
                index,
                variantController
                    .text,
              );

              FocusScope.of(
                context,
              ).unfocus();
            },
          ),

          const SizedBox(
            height: 12,
          ),

          ///////////////////////////////////////////////////
          /// ORDERED
          ///////////////////////////////////////////////////

          _buildOrderedQuantity(
            item: item,
          ),

          const SizedBox(
            height: 12,
          ),

          ///////////////////////////////////////////////////
          /// RECEIVED
          ///////////////////////////////////////////////////

          _buildReceivedQuantityEditor(
            index: index,
            item: item,
          ),

          const SizedBox(
            height: 12,
          ),

          ///////////////////////////////////////////////////
          /// MISSING
          ///////////////////////////////////////////////////

          _buildMissingQuantityEditor(
            index: index,
            item: item,
          ),

          const SizedBox(
            height: 12,
          ),

          ///////////////////////////////////////////////////
          /// PROGRESS
          ///////////////////////////////////////////////////

          _buildPackingProgress(
            ordered:
                ordered,
            received:
                received,
            missing:
                missing,
          ),

          const SizedBox(
            height: 12,
          ),

          ///////////////////////////////////////////////////
          /// ADMIN NOTE
          ///////////////////////////////////////////////////

          _editableField(
            controller:
                noteController,
            label:
                "Admin Note",
            icon:
                Icons.notes_outlined,
            maxLines: 3,
            onChanged:
                (_) {},
            onEditingComplete:
                () {
              _saveNote(
                index,
                noteController
                    .text,
              );

              FocusScope.of(
                context,
              ).unfocus();
            },
          ),

          const SizedBox(
            height: 12,
          ),

          ///////////////////////////////////////////////////
          /// CONFIRMATION INFORMATION
          ///////////////////////////////////////////////////

          _buildConfirmationInfo(
            item,
          ),

          const SizedBox(
            height: 18,
          ),

          ///////////////////////////////////////////////////
          /// CONFIRM BUTTON
          ///////////////////////////////////////////////////

          SizedBox(
            width:
                double.infinity,
            child:
                ElevatedButton.icon(
              onPressed:
                  complete &&
                          !confirmed &&
                          !_isSaving
                      ? () =>
                          _confirmItem(
                            index,
                          )
                      : null,

              icon:
                  _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2,
                            color:
                                Colors.white,
                          ),
                        )
                      : Icon(
                          confirmed
                              ? Icons
                                  .check_circle_rounded
                              : complete
                                  ? Icons
                                      .check_circle_outline
                                  : Icons
                                      .lock_outline_rounded,
                        ),

              label:
                  Text(
                _isSaving
                    ? "Saving..."
                    : confirmed
                        ? "Confirmed"
                        : complete
                            ? "Confirm"
                            : "Complete Received + Missing to Confirm",
              ),

              style:
                  ElevatedButton
                      .styleFrom(
                elevation: 0,

                backgroundColor:
                    confirmed
                        ? Colors
                            .green
                            .shade100
                        : complete
                            ? const Color(
                                0xff241B2F,
                              )
                            : const Color(
                                0xffE9E5E7,
                              ),

                foregroundColor:
                    confirmed
                        ? Colors
                            .green
                            .shade800
                        : complete
                            ? Colors.white
                            : const Color(
                                0xff8A7C82,
                              ),

                disabledBackgroundColor:
                    confirmed
                        ? Colors
                            .green
                            .shade100
                        : const Color(
                            0xffE9E5E7,
                          ),

                disabledForegroundColor:
                    confirmed
                        ? Colors
                            .green
                            .shade800
                        : const Color(
                            0xff8A7C82,
                          ),

                padding:
                    const EdgeInsets
                        .symmetric(
                  vertical: 15,
                ),

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// PACKING PROGRESS
  ///////////////////////////////////////////////////////////

  Widget _buildPackingProgress({
    required int ordered,
    required int received,
    required int missing,
  }) {
    final total =
        received + missing;

    final complete =
        total == ordered;

    final progress =
        ordered <= 0
            ? 1.0
            : (total / ordered)
                .clamp(
                0.0,
                1.0,
              );

    return Container(
      padding:
          const EdgeInsets.all(
        13,
      ),
      decoration:
          BoxDecoration(
        color: complete
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
          color: complete
              ? Colors
                  .green
                  .shade200
              : const Color(
                  0xffECE3E7,
                ),
        ),
      ),
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Row(
            children: [
              Icon(
                complete
                    ? Icons
                        .check_circle_outline
                    : Icons
                        .pending_actions,
                size: 19,
                color: complete
                    ? Colors
                        .green
                        .shade700
                    : const Color(
                        0xff6A5962,
                      ),
              ),

              const SizedBox(
                width: 8,
              ),

              Expanded(
                child:
                    Text(
                  complete
                      ? "Ready to confirm"
                      : "Packing progress",
                  style:
                      const TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),

              Text(
                "$total / $ordered",
                style:
                    const TextStyle(
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 10,
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
              minHeight: 7,
              backgroundColor:
                  Colors.white,
              valueColor:
                  AlwaysStoppedAnimation<
                      Color>(
                complete
                    ? Colors
                        .green
                        .shade600
                    : const Color(
                        0xff241B2F,
                      ),
              ),
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            "Received: $received   •   Missing: $missing",
            style:
                const TextStyle(
              fontSize: 11,
              color:
                  Color(
                0xff76656D,
              ),
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// SUMMARY
  ///////////////////////////////////////////////////////////

  Widget _buildSummary() {
    final allConfirmed =
        _items.isNotEmpty &&
            _confirmedCount ==
                _items.length;

    final allReady =
        _items.isNotEmpty &&
            _readyToConfirmCount ==
                _items.length;

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 20,
      ),
      padding:
          const EdgeInsets.all(
        18,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xff241B2F,
        ),
        borderRadius:
            BorderRadius.circular(
          22,
        ),
      ),
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          ///////////////////////////////////////////////////
          /// TITLE
          ///////////////////////////////////////////////////

          const Text(
            "Packing Summary",
            style:
                TextStyle(
              color:
                  Colors.white,
              fontSize: 18,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            "$_totalProductLines product lines • $_totalItems ordered units",
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

          ///////////////////////////////////////////////////
          /// STATS
          ///////////////////////////////////////////////////

          Row(
            children: [
              _summaryItem(
                "Lines",
                "$_totalProductLines",
              ),
              _summaryItem(
                "Received",
                "$_receivedItems",
              ),
              _summaryItem(
                "Missing",
                "$_missingItems",
              ),
              _summaryItem(
                "Confirmed",
                "$_confirmedCount",
              ),
            ],
          ),

          const SizedBox(
            height: 15,
          ),

          ///////////////////////////////////////////////////
          /// STATUS
          ///////////////////////////////////////////////////

          Container(
            width:
                double.infinity,
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration:
                BoxDecoration(
              color:
                  Colors.white
                      .withOpacity(
                .08,
              ),
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child:
                Row(
              children: [
                Icon(
                  allConfirmed
                      ? Icons
                          .check_circle_outline
                      : allReady
                          ? Icons
                              .task_alt
                          : Icons
                              .pending_actions,
                  size: 17,
                  color:
                      Colors.white70,
                ),

                const SizedBox(
                  width: 8,
                ),

                Expanded(
                  child:
                      Text(
                    allConfirmed
                        ? "All items confirmed"
                        : allReady
                            ? "All items ready to confirm"
                            : "Pending: $_pendingCount",
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontWeight:
                          FontWeight.w700,
                      fontSize: 12,
                    ),
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
  /// SUMMARY ITEM
  ///////////////////////////////////////////////////////////

  Widget _summaryItem(
    String title,
    String value,
  ) {
    return Expanded(
      child:
          Column(
        children: [
          Text(
            value,
            style:
                const TextStyle(
              color:
                  Colors.white,
              fontSize: 20,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            title,
            style:
                const TextStyle(
              color:
                  Colors.white70,
              fontSize: 10,
              fontWeight:
                  FontWeight.w600,
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
          const Color(
        0xffF7F5F6,
      ),

      /////////////////////////////////////////////////////////
      /// APP BAR
      /////////////////////////////////////////////////////////

      appBar:
          AppBar(
        elevation: 0,

        backgroundColor:
            Colors.white,

        foregroundColor:
            const Color(
          0xff241B2F,
        ),

        title:
            const Text(
          "Packing",
          style:
              TextStyle(
            fontSize: 19,
            fontWeight:
                FontWeight.w900,
          ),
        ),

        actions: [
          IconButton(
            tooltip:
                "Refresh",

            onPressed:
                _isLoading
                    ? null
                    : _loadItems,

            icon:
                const Icon(
              Icons
                  .refresh_rounded,
            ),
          ),
        ],
      ),

      /////////////////////////////////////////////////////////
      /// BODY
      /////////////////////////////////////////////////////////

      body:
          _isLoading
              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )
              : _items.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh:
                          _loadItems,
                      child:
                          ListView(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        padding:
                            const EdgeInsets
                                .fromLTRB(
                          16,
                          16,
                          16,
                          30,
                        ),
                        children: [

                          ///////////////////////////////////////////////////
                          /// ORDER HEADER
                          ///////////////////////////////////////////////////

                          Container(
                            padding:
                                const EdgeInsets
                                    .all(
                              14,
                            ),
                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.white,
                              borderRadius:
                                  BorderRadius.circular(
                                16,
                              ),
                              border:
                                  Border.all(
                                color:
                                    const Color(
                                  0xffECE5E8,
                                ),
                              ),
                            ),
                            child:
                                Row(
                              children: [
                                Container(
                                  width:
                                      42,
                                  height:
                                      42,
                                  decoration:
                                      BoxDecoration(
                                    color:
                                        const Color(
                                      0xffFFF0F5,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(
                                      13,
                                    ),
                                  ),
                                  child:
                                      const Icon(
                                    Icons
                                        .inventory_2_outlined,
                                    color:
                                        Color(
                                      0xffE91E63,
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  width: 12,
                                ),

                                Expanded(
                                  child:
                                      Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Packing Order",
                                        style:
                                            TextStyle(
                                          fontSize: 11,
                                          color:
                                              Color(
                                            0xff8A7881,
                                          ),
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 3,
                                      ),

                                      Text(
                                        widget.orderId,
                                        maxLines:
                                            1,
                                        overflow:
                                            TextOverflow.ellipsis,
                                        style:
                                            const TextStyle(
                                          fontSize: 14,
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

                          const SizedBox(
                            height: 16,
                          ),

                          ///////////////////////////////////////////////////
                          /// SUMMARY
                          ///////////////////////////////////////////////////

                          _buildSummary(),

                          ///////////////////////////////////////////////////
                          /// ITEMS
                          ///////////////////////////////////////////////////

                          ...List.generate(
                            _items.length,
                            (index) {
                              return _buildItemCard(
                                _items[
                                    index],
                                index,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
    );
  }

  ///////////////////////////////////////////////////////////
  /// EMPTY
  ///////////////////////////////////////////////////////////

  Widget _buildEmptyState() {
    return Center(
      child:
          Padding(
        padding:
            const EdgeInsets.all(
          30,
        ),
        child:
            Column(
          mainAxisAlignment:
              MainAxisAlignment
                  .center,
          children: [
            Container(
              width: 75,
              height: 75,
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xffF0EAED,
                ),
                borderRadius:
                    BorderRadius.circular(
                  22,
                ),
              ),
              child:
                  const Icon(
                Icons
                    .inventory_2_outlined,
                size: 36,
                color:
                    Color(
                  0xff75656D,
                ),
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            const Text(
              "No items found",
              style:
                  TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w900,
              ),
            ),

            const SizedBox(
              height: 7,
            ),

            const Text(
              "This order does not contain any packing items.",
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                color:
                    Color(
                  0xff82727A,
                ),
                fontSize: 13,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            OutlinedButton.icon(
              onPressed:
                  _loadItems,
              icon:
                  const Icon(
                Icons
                    .refresh_rounded,
              ),
              label:
                  const Text(
                "Try Again",
              ),
            ),
          ],
        ),
      ),
    );
  }
}