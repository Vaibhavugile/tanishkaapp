import 'package:flutter/material.dart';

import '../../../models/home_product_model.dart';
import '../../../models/variation_model.dart';
import '../../../services/cart_service.dart';
import '../../../services/user_role_service.dart';
import '../../../models/cart_item_model.dart';

class PremiumProductCard extends StatefulWidget {
  final HomeProductModel product;

  const PremiumProductCard({
    super.key,
    required this.product,
  });

  @override
  State<PremiumProductCard> createState() =>
      _PremiumProductCardState();
}

class _PremiumProductCardState
    extends State<PremiumProductCard> {
  static const Color primary =
      Color(0xffE91E63);

  static const Color dark =
      Color(0xff241B2F);

  static const Color green =
      Color(0xff28A745);

  bool _liked = false;
  bool _pressed = false;

  int _quantity = 1;

  CartItemModel? _cartItem;

  VariationModel? _selectedVariation;

  @override
  void initState() {
    super.initState();

    if (widget.product.product.hasVariants &&
        widget.product.product.variations.isNotEmpty) {
      _selectedVariation =
          widget.product.product.variations.first;
    }

    _loadCartItem();
  }

  //////////////////////////////////////////////////////////////
  /// LOAD CART ITEM
  //////////////////////////////////////////////////////////////

  Future<void> _loadCartItem() async {
    final item =
        await CartService.instance.getCartItem(
      collectionId: product.collectionId,
      productId: product.product.id,
      subCollectionId:
          product.subCollection.id,
      variation: selectedVariation,
    );

    debugPrint(
      "Product: ${product.product.productName}"
      "\nHas Variants: $hasVariants"
      "\nVariation: ${selectedVariation?.label}"
      "\nFound Item: ${item != null}"
      "\nQuantity: ${item?.quantity}",
    );

    if (!mounted) return;

    setState(() {
      _cartItem = item;
      _quantity = item?.quantity ?? 1;
    });
  }

  //////////////////////////////////////////////////////////////
  /// GETTERS
  //////////////////////////////////////////////////////////////

  HomeProductModel get product =>
      widget.product;

  bool get hasVariants =>
      product.product.hasVariants;

  List<VariationModel> get variations =>
      product.product.variations;

  VariationModel? get selectedVariation =>
      hasVariants ? _selectedVariation : null;

  //////////////////////////////////////////////////////////////
  /// RESPONSIVE IMAGE HEIGHT
  //////////////////////////////////////////////////////////////

  double _imageHeight(BuildContext context) {
    final width =
        MediaQuery.of(context).size.width;

    if (width <= 350) {
      return 112;
    }

    if (width <= 380) {
      return 122;
    }

    if (width <= 420) {
      return 132;
    }

    return 145;
  }

  //////////////////////////////////////////////////////////////
  /// PRICE
  //////////////////////////////////////////////////////////////

  double get displayPrice {
    return product.getPrice(
      role: UserRoleService.instance.role,
      quantity: _quantity,
    );
  }

  //////////////////////////////////////////////////////////////
  /// STOCK
  //////////////////////////////////////////////////////////////

  int get displayStock {
    if (selectedVariation != null) {
      return selectedVariation!.quantity;
    }

    return product.stock;
  }

  bool get isAvailable =>
      displayStock > 0;

  String get stockLabel {
    if (displayStock <= 0) {
      return "Out of Stock";
    }

    if (displayStock <= 3) {
      return "Only $displayStock Left";
    }

    return "$displayStock In Stock";
  }

  Color get stockColor {
    if (displayStock <= 0) {
      return Colors.red;
    }

    if (displayStock <= 3) {
      return Colors.orange;
    }

    return green;
  }

  //////////////////////////////////////////////////////////////
  /// SELECT VARIATION
  //////////////////////////////////////////////////////////////

  Future<void> selectVariation(
    VariationModel variation,
  ) async {
    setState(() {
      _selectedVariation = variation;
      _quantity = 1;
      _cartItem = null;
    });

    await _loadCartItem();
  }

  //////////////////////////////////////////////////////////////
  /// FULLSCREEN IMAGE
  //////////////////////////////////////////////////////////////

  void _openProductImage() {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: Center(
                    child: Hero(
                      tag:
                          'fullscreen_${product.code}',
                      child: Image.network(
                        product.image,
                        fit: BoxFit.contain,
                        errorBuilder:
                            (_, __, ___) {
                          return const Icon(
                            Icons
                                .image_not_supported_rounded,
                            color: Colors.white,
                            size: 50,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 45,
                right: 18,
                child: Material(
                  color:
                      Colors.black.withOpacity(.55),
                  shape:
                      const CircleBorder(),
                  child: InkWell(
                    customBorder:
                        const CircleBorder(),
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 25,
                      ),
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

  //////////////////////////////////////////////////////////////
  /// VARIATION DROPDOWN
  //////////////////////////////////////////////////////////////

  void _showVariantDropdown() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(
              18,
              16,
              18,
              20,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select Variant",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w800,
                    color: dark,
                  ),
                ),

                const SizedBox(height: 12),

                ...variations.map(
                  (variation) {
                    final isSelected =
                        selectedVariation ==
                            variation;

                    final isAvailable =
                        variation.quantity > 0;

                    return InkWell(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                      onTap: isAvailable
                          ? () async {
                              Navigator.pop(
                                context,
                              );

                              await selectVariation(
                                variation,
                              );
                            }
                          : null,
                      child: Container(
                        width: double.infinity,
                        margin:
                            const EdgeInsets.only(
                          bottom: 7,
                        ),
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration:
                            BoxDecoration(
                          color: isSelected
                              ? const Color(
                                  0xffFFF1F7,
                                )
                              : Colors.white,
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                          border:
                              Border.all(
                            color: isSelected
                                ? primary
                                : Colors
                                    .grey
                                    .shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                variation.label,
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                  color: isAvailable
                                      ? dark
                                      : Colors
                                          .grey,
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 8,
                            ),

                            Text(
                              isAvailable
                                  ? "${variation.quantity} in stock"
                                  : "Out of stock",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight:
                                    FontWeight
                                        .w600,
                                color: isAvailable
                                    ? green
                                    : Colors.red,
                              ),
                            ),

                            if (isSelected)
                              const Padding(
                                padding:
                                    EdgeInsets.only(
                                  left: 7,
                                ),
                                child: Icon(
                                  Icons
                                      .check_circle_rounded,
                                  size: 18,
                                  color: primary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //////////////////////////////////////////////////////////////
  /// QUANTITY
  //////////////////////////////////////////////////////////////

  void increaseQuantity() {
    if (_quantity >= displayStock) {
      return;
    }

    setState(() {
      _quantity++;
    });
  }

  void decreaseQuantity() {
    if (_quantity <= 1) {
      return;
    }

    setState(() {
      _quantity--;
    });
  }

  //////////////////////////////////////////////////////////////
  /// ADD TO CART
  //////////////////////////////////////////////////////////////

  Future<void> _addToCart() async {
    if (!isAvailable) return;

    try {
      await CartService.instance.addToCart(
        product: product,
        variation: selectedVariation,
        quantity: _quantity,
      );

      await _loadCartItem();

      if (!mounted) return;

      // ScaffoldMessenger.of(context)
      //     .showSnackBar(
      //   SnackBar(
      //     behavior:
      //         SnackBarBehavior.floating,
      //     backgroundColor: green,
      //     content: Text(
      //       "${product.name} added to cart",
      //     ),
      //   ),
      // );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          behavior:
              SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  //////////////////////////////////////////////////////////////
  /// STOCK WIDGET
  //////////////////////////////////////////////////////////////

  Widget buildStockWidget() {
    return AnimatedContainer(
      duration:
          const Duration(milliseconds: 200),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color:
            stockColor.withOpacity(.09),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            isAvailable
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            size: 11,
            color: stockColor,
          ),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              stockLabel,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: TextStyle(
                color: stockColor,
                fontSize: 9.5,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //////////////////////////////////////////////////////////////
  /// CART CONTROL
  //////////////////////////////////////////////////////////////

  Widget buildCartControl() {
    return AnimatedSwitcher(
      duration:
          const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,

      child: _cartItem == null
          ? SizedBox(
              key: const ValueKey(
                "add",
              ),
              width: double.infinity,
              height: 36,
              child:
                  ElevatedButton.icon(
                onPressed: isAvailable
                    ? () async {
                        await _addToCart();
                      }
                    : null,
                style:
                    ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor:
                      primary,
                  foregroundColor:
                      Colors.white,
                  disabledBackgroundColor:
                      Colors.grey.shade300,
                  disabledForegroundColor:
                      Colors.grey.shade600,
                  padding:
                      EdgeInsets.zero,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                ),
                icon: const Icon(
                  Icons
                      .shopping_bag_outlined,
                  size: 17,
                ),
                label: const Text(
                  "Add to Cart",
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            )

          : Container(
              key: const ValueKey(
                "qty",
              ),
              height: 36,
              decoration:
                  BoxDecoration(
                color: primary,
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: IconButton(
                      padding:
                          EdgeInsets.zero,
                      visualDensity:
                          VisualDensity
                              .compact,
                      onPressed:
                          _cartItem == null
                              ? null
                              : () async {
                                  if (_cartItem ==
                                      null) {
                                    return;
                                  }

                                  await CartService
                                      .instance
                                      .decreaseQuantity(
                                    item:
                                        _cartItem!,
                                  );

                                  await _loadCartItem();
                                },
                      icon: const Icon(
                        Icons.remove,
                        color:
                            Colors.white,
                        size: 17,
                      ),
                    ),
                  ),

                  Text(
                    "$_quantity",
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),

                  Expanded(
                    child: IconButton(
                      padding:
                          EdgeInsets.zero,
                      visualDensity:
                          VisualDensity
                              .compact,
                      onPressed:
                          _cartItem == null ||
                                  _quantity >=
                                      displayStock
                              ? null
                              : () async {
                                  if (_cartItem ==
                                      null) {
                                    return;
                                  }

                                  await CartService
                                      .instance
                                      .increaseQuantity(
                                    item:
                                        _cartItem!,
                                  );

                                  await _loadCartItem();
                                },
                      icon: Icon(
                        Icons.add,
                        color:
                            _quantity >=
                                    displayStock
                                ? Colors
                                    .white38
                                : Colors.white,
                        size: 17,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  //////////////////////////////////////////////////////////////
  /// BUILD
  //////////////////////////////////////////////////////////////

  @override
  Widget build(
    BuildContext context,
  ) {
    final imageHeight =
        _imageHeight(context);

    return AnimatedScale(
      duration:
          const Duration(milliseconds: 180),
      scale: _pressed ? .98 : 1,

      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            _pressed = true;
          });
        },
        onTapUp: (_) {
          setState(() {
            _pressed = false;
          });
        },
        onTapCancel: () {
          setState(() {
            _pressed = false;
          });
        },

        onTap: () {
          // Product details navigation
          // can be added here.
        },

        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 250),
          curve: Curves.easeOut,

          decoration:
              BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(
              20,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(.045),
                blurRadius: 16,
                spreadRadius: 0,
                offset:
                    const Offset(0, 7),
              ),
            ],
          ),

          clipBehavior:
              Clip.antiAlias,

          child: Column(
            children: [
              //////////////////////////////////////////////////
              /// IMAGE
              //////////////////////////////////////////////////

              SizedBox(
                height: imageHeight,
                width: double.infinity,

                child: Stack(
                  children: [
                    //////////////////////////////////////////////////
                    /// PRODUCT IMAGE
                    //////////////////////////////////////////////////

                    Positioned.fill(
                      child:
                          Hero(
                        tag:
                            product.code,

                        child:
                            GestureDetector(
                          onTap:
                              _openProductImage,

                          child:
                              Image.network(
                            product.image,

                            fit:
                                BoxFit.cover,

                            width:
                                double.infinity,

                            height:
                                double.infinity,

                            loadingBuilder:
                                (
                              context,
                              child,
                              progress,
                            ) {
                              if (progress ==
                                  null) {
                                return AnimatedOpacity(
                                  opacity:
                                      1,
                                  duration:
                                      const Duration(
                                    milliseconds:
                                        250,
                                  ),
                                  child:
                                      child,
                                );
                              }

                              return Container(
                                color:
                                    const Color(
                                  0xffFAF7FB,
                                ),
                                child:
                                    const Center(
                                  child:
                                      SizedBox(
                                    width:
                                        22,
                                    height:
                                        22,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2,
                                      color:
                                          primary,
                                    ),
                                  ),
                                ),
                              );
                            },

                            errorBuilder:
                                (
                              _,
                              __,
                              ___,
                            ) {
                              return Container(
                                color:
                                    const Color(
                                  0xffFAF7FB,
                                ),
                                child:
                                    const Icon(
                                  Icons
                                      .image_not_supported_outlined,
                                  size:
                                      34,
                                  color:
                                      Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    //////////////////////////////////////////////////
                    /// IMAGE GRADIENT
                    //////////////////////////////////////////////////

                    Positioned.fill(
                      child:
                          IgnorePointer(
                        child:
                            DecoratedBox(
                          decoration:
                              BoxDecoration(
                            gradient:
                                LinearGradient(
                              begin:
                                  Alignment
                                      .topCenter,
                              end:
                                  Alignment
                                      .bottomCenter,
                              colors: [
                                Colors
                                    .transparent,
                                Colors
                                    .transparent,
                                Colors
                                    .black
                                    .withOpacity(
                                  .12,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    //////////////////////////////////////////////////
                    /// NEW BADGE
                    //////////////////////////////////////////////////

                    Positioned(
                      top: 8,
                      left: 8,

                      child:
                          Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),

                        decoration:
                            BoxDecoration(
                          gradient:
                              const LinearGradient(
                            colors: [
                              Color(
                                  0xffFF73AF),
                              primary,
                            ],
                          ),

                          borderRadius:
                              BorderRadius
                                  .circular(
                            20,
                          ),
                        ),

                        child:
                            const Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            Icon(
                              Icons
                                  .auto_awesome,
                              color:
                                  Colors.white,
                              size: 9,
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            Text(
                              "NEW",
                              style:
                                  TextStyle(
                                color:
                                    Colors.white,
                                fontWeight:
                                    FontWeight.bold,
                                fontSize:
                                    8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    //////////////////////////////////////////////////
                    /// WISHLIST
                    //////////////////////////////////////////////////

                    Positioned(
                      top: 8,
                      right: 8,

                      child:
                          Material(
                        color:
                            Colors.white
                                .withOpacity(
                          .94,
                        ),

                        shape:
                            const CircleBorder(),

                        child:
                            InkWell(
                          customBorder:
                              const CircleBorder(),

                          onTap: () {
                            setState(() {
                              _liked =
                                  !_liked;
                            });
                          },

                          child:
                              SizedBox(
                            width: 34,
                            height: 34,

                            child:
                                AnimatedSwitcher(
                              duration:
                                  const Duration(
                                milliseconds:
                                    180,
                              ),

                              child:
                                  Icon(
                                _liked
                                    ? Icons
                                        .favorite
                                    : Icons
                                        .favorite_border,

                                key:
                                    ValueKey(
                                  _liked,
                                ),

                                color:
                                    _liked
                                        ? primary
                                        : Colors
                                            .black87,

                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              //////////////////////////////////////////////////
              /// DETAILS
              //////////////////////////////////////////////////

              Expanded(
                child:
                    Padding(
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    10,
                    9,
                    10,
                    9,
                  ),

                  child:
                      Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [
                      //////////////////////////////////////////////////
                      /// NAME
                      //////////////////////////////////////////////////

                      Text(
                        product.name,
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w700,
                          color: dark,
                          height: 1.15,
                        ),
                      ),

                      const SizedBox(
                        height: 3,
                      ),

                      //////////////////////////////////////////////////
                      /// CODE
                      //////////////////////////////////////////////////

                      Text(
                        "Code • ${product.code}",
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            TextStyle(
                          color: Colors
                              .grey
                              .shade600,
                          fontSize: 9.5,
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      //////////////////////////////////////////////////
                      /// PRICE + STOCK
                      //////////////////////////////////////////////////

                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .center,

                        children: [
                          const Text(
                            "₹",
                            style:
                                TextStyle(
                              color:
                                  primary,
                              fontWeight:
                                  FontWeight
                                      .w700,
                              fontSize:
                                  11,
                            ),
                          ),

                          const SizedBox(
                            width: 1,
                          ),

                          Flexible(
                            child:
                                AnimatedSwitcher(
                              duration:
                                  const Duration(
                                milliseconds:
                                    180,
                              ),

                              child:
                                  Text(
                                displayPrice
                                    .toStringAsFixed(
                                  0,
                                ),

                                key:
                                    ValueKey(
                                  displayPrice,
                                ),

                                maxLines:
                                    1,

                                overflow:
                                    TextOverflow
                                        .ellipsis,

                                style:
                                    const TextStyle(
                                  fontSize:
                                      16,
                                  fontWeight:
                                      FontWeight
                                          .w800,
                                  letterSpacing:
                                      -.3,
                                  color:
                                      dark,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 5,
                          ),

                          if (displayStock >
                              0)
                            Flexible(
                              child:
                                  Align(
                                alignment:
                                    Alignment
                                        .centerRight,
                                child:
                                    Text(
                                  "$displayStock left",
                                  maxLines:
                                      1,
                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                  style:
                                      TextStyle(
                                    color:
                                        stockColor,
                                    fontSize:
                                        9,
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      //////////////////////////////////////////////////
                      /// VARIATION
                      //////////////////////////////////////////////////

                      if (hasVariants) ...[
                        const SizedBox(
                          height: 5,
                        ),

                        InkWell(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),

                          onTap:
                              _showVariantDropdown,

                          child:
                              Container(
                            width:
                                double.infinity,
                            height: 34,

                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal:
                                  8,
                            ),

                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.white,
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                10,
                              ),
                              border:
                                  Border.all(
                                color: Colors
                                    .grey
                                    .shade300,
                              ),
                            ),

                            child:
                                Row(
                              children: [
                                const Icon(
                                  Icons
                                      .tune_rounded,
                                  size: 14,
                                  color:
                                      Color(
                                    0xffD81B78,
                                  ),
                                ),

                                const SizedBox(
                                  width: 5,
                                ),

                                Expanded(
                                  child:
                                      Text(
                                    selectedVariation
                                            ?.label ??
                                        "Select Variant",
                                    maxLines:
                                        1,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                    style:
                                        const TextStyle(
                                      fontSize:
                                          10.5,
                                      fontWeight:
                                          FontWeight
                                              .w600,
                                      color:
                                          dark,
                                    ),
                                  ),
                                ),

                                const Icon(
                                  Icons
                                      .keyboard_arrow_down_rounded,
                                  size: 17,
                                  color:
                                      Colors
                                          .black54,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      //////////////////////////////////////////////////
                      /// SMALL FLEXIBLE GAP
                      //////////////////////////////////////////////////

                      const SizedBox(height: 8),

                      //////////////////////////////////////////////////
                      /// CART
                      //////////////////////////////////////////////////

                      buildCartControl(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}