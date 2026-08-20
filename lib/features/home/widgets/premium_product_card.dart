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
  Future<void> _loadCartItem() async {
 final item = await CartService.instance.getCartItem(
  collectionId: product.collectionId,
  productId: product.product.id,
  subCollectionId: product.subCollection.id,
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

  HomeProductModel get product => widget.product;

  bool get hasVariants =>
      product.product.hasVariants;

  List<VariationModel> get variations =>
      product.product.variations;

  VariationModel? get selectedVariation =>
      hasVariants ? _selectedVariation : null;

 double get displayPrice {
  return product.getPrice(
    role: UserRoleService.instance.role,
    quantity: _quantity,
  );
}

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

    return const Color(0xff28A745);
  }

  Future<void>  selectVariation(
  VariationModel variation,
) async {
  setState(() {
    _selectedVariation = variation;
  });

  await _loadCartItem();
}
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
            /////////////////////////////////////////////////////
            /// FULL SCREEN IMAGE
            /////////////////////////////////////////////////////

            Positioned.fill(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: Center(
                  child: Hero(
                    tag: 'fullscreen_${product.code}',
                    child: Image.network(
                      product.image,
                      fit: BoxFit.contain,
                      errorBuilder:
                          (_, __, ___) {
                        return const Icon(
                          Icons.image_not_supported_rounded,
                          color: Colors.white,
                          size: 50,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            /////////////////////////////////////////////////////
            /// CLOSE BUTTON
            /////////////////////////////////////////////////////

            Positioned(
              top: 45,
              right: 18,
              child: Material(
                color: Colors.black.withOpacity(.55),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
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
void _showVariantDropdown() {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Variant",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff241B2F),
                ),
              ),

              const SizedBox(height: 14),

              ...variations.map(
                (variation) {
                  final isSelected =
                      selectedVariation == variation;

                  final isAvailable =
                      variation.quantity > 0;

                  return InkWell(
                    borderRadius:
                        BorderRadius.circular(12),
                    onTap: isAvailable
                        ? () async {
                            Navigator.pop(context);

                            await selectVariation(
                              variation,
                            );
                          }
                        : null,
                    child: Container(
                      width: double.infinity,
                      margin:
                          const EdgeInsets.only(
                        bottom: 8,
                      ),
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(
                                0xffFFF1F7,
                              )
                            : Colors.white,
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                        border: Border.all(
                          color: isSelected
                              ? const Color(
                                  0xffE91E63,
                                )
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              variation.label,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    FontWeight.w600,
                                color: isAvailable
                                    ? const Color(
                                        0xff241B2F,
                                      )
                                    : Colors.grey,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          Text(
                            isAvailable
                                ? "${variation.quantity} in stock"
                                : "Out of stock",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w600,
                              color: isAvailable
                                  ? const Color(
                                      0xff28A745,
                                    )
                                  : Colors.red,
                            ),
                          ),

                          if (isSelected)
                            const Padding(
                              padding:
                                  EdgeInsets.only(
                                left: 8,
                              ),
                              child: Icon(
                                Icons
                                    .check_circle_rounded,
                                size: 18,
                                color:
                                    Color(0xffE91E63),
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

  void increaseQuantity() {
    if (_quantity >= displayStock) return;

    setState(() {
      _quantity++;
    });
  }

  void decreaseQuantity() {
    if (_quantity == 1) return;

    setState(() {
      _quantity--;
    });
  }

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              const Color(0xff28A745),
          content: Text(
            "${product.name} added to cart",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          content: Text(e.toString()),
        ),
      );
    }
  }
    Widget buildVariantChip(
    VariationModel variation,
  ) {
    final selected =
    selectedVariation == variation;

    final bool available = variation.inStock;

    return GestureDetector(
      onTap: available
          ? () => selectVariation(variation)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: selected
              ? const LinearGradient(
                  colors: [
                    Color(0xffFF6FAF),
                    Color(0xffE91E63),
                  ],
                )
              : null,
          color: selected
              ? null
              : Colors.white,
          border: Border.all(
            color: selected
                ? Colors.transparent
                : available
                    ? Colors.grey.shade300
                    : Colors.red.shade200,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xffE91E63)
                        .withOpacity(.25),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              variation.label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : available
                        ? Colors.black87
                        : Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (!available) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.block,
                size: 14,
                color: Colors.red,
              ),
            ]
          ],
        ),
      ),
    );
  }

  

  Widget buildStockWidget() {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 250),
    padding: const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 5,
    ),
    decoration: BoxDecoration(
      color: stockColor.withOpacity(.10),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: stockColor.withOpacity(.18),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isAvailable
              ? Icons.check_circle_rounded
              : Icons.cancel_rounded,
          size: 13,
          color: stockColor,
        ),

        const SizedBox(width: 4),

        Text(
          stockLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: stockColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
      ],
    ),
  );
}

 
  Widget buildCartControl() {
  return AnimatedSwitcher(
    duration: const Duration(milliseconds: 300),
    switchInCurve: Curves.easeOut,
    switchOutCurve: Curves.easeIn,

    child: _cartItem == null
        ? SizedBox(
            key: const ValueKey("add"),

            width: double.infinity,
            height: 42,

            child: ElevatedButton.icon(
              onPressed: isAvailable
    ? () async {
        await _addToCart();

      }
    : null,

              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xffE91E63),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),

              icon: const Icon(Icons.shopping_bag_outlined),

              label: const Text(
                "Add to Cart",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          )

        : Container(
            key: const ValueKey("qty"),

            height: 42,

            decoration: BoxDecoration(
              color: const Color(0xffE91E63),
              borderRadius: BorderRadius.circular(18),
            ),

            child: Row(
              children: [

                Expanded(
                  child: IconButton(
                    onPressed: () async {
  if (_cartItem == null) return;

 await CartService.instance.decreaseQuantity(
  item: _cartItem!,
);

await _loadCartItem();
},
                    icon: const Icon(
                      Icons.remove,
                      color: Colors.white,
                    ),
                  ),
                ),

                Text(
                  "$_quantity",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                Expanded(
                  child: IconButton(
                   onPressed: () async {
  if (_cartItem == null) return;

await CartService.instance.increaseQuantity(
  item: _cartItem!,
);

await _loadCartItem();
},
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
  );
}
    @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      scale: _pressed ? .98 : 1,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () {
          // TODO:
          // Navigate to Product Details
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
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
          child: Column(
            children: [

              /////////////////////////////////////////////////////////
              /// IMAGE
              /////////////////////////////////////////////////////////

              Expanded(
                flex: 42,
                child: Stack(
                  children: [

                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Hero(
  tag: product.code,
  child: GestureDetector(
    onTap: _openProductImage,
    child: Image.network(
      product.image,
      fit: BoxFit.cover,
      loadingBuilder:
          (context, child, progress) {
        if (progress == null) {
          return child;
        }

        return Container(
          color: const Color(0xffFAF7FB),
          child: const Center(
            child: CircularProgressIndicator(
              color: Color(0xffE91E63),
            ),
          ),
        );
      },
      errorBuilder:
          (_, __, ___) {
        return Container(
          color: const Color(0xffFAF7FB),
          child: const Icon(
            Icons.image_not_supported,
            size: 42,
          ),
        );
      },
    ),
  ),
),
                      ),
                    ),

                    /////////////////////////////////////////////////////////
                    /// Gradient
                    /////////////////////////////////////////////////////////

                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.transparent,
                                Colors.black.withOpacity(.15),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    /////////////////////////////////////////////////////////
                    /// NEW Badge
                    /////////////////////////////////////////////////////////

                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          gradient:
                              const LinearGradient(
                            colors: [
                              Color(0xffFF73AF),
                              Color(0xffE91E63),
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(40),
                        ),
                        child: const Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [

                            Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                              size: 12,
                            ),

                            SizedBox(width: 5),

                            Text(
                              "NEW",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    /////////////////////////////////////////////////////////
                    /// Wishlist
                    /////////////////////////////////////////////////////////

                    Positioned(
                      top: 12,
                      right: 12,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(
                                  100),
                          onTap: () {
                            setState(() {
                              _liked = !_liked;
                            });
                          },
                          child: AnimatedContainer(
                            duration:
                                const Duration(
                                    milliseconds:
                                        250),
                            width: 44,
                            height: 44,
                            decoration:
                                BoxDecoration(
                              color: Colors.white,
                              shape:
                                  BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(
                                          .08),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                            child:
                                AnimatedSwitcher(
                              duration:
                                  const Duration(
                                      milliseconds:
                                          250),
                              child: Icon(
                                _liked
                                    ? Icons.favorite
                                    : Icons
                                        .favorite_border,
                                key:
                                    ValueKey(_liked),
                                color: _liked
                                    ? const Color(
                                        0xffE91E63)
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    /////////////////////////////////////////////////////////
                    /// Stock Badge
                    /////////////////////////////////////////////////////////

                  
                  ],
                ),
              ),

              /////////////////////////////////////////////////////////
              /// DETAILS
              /////////////////////////////////////////////////////////

              Expanded(
                flex: 58,
                child: Padding(
                  padding:
                      const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                           Text(
  product.name,
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
  style: const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: Color(0xff241B2F),
    height: 1.2,
  ),
),

                    const SizedBox(height: 6),

                    Text(
                      "Code • ${product.code}",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
const SizedBox(height: 6),

/////////////////////////////////////////////////////////
/// PRICE + STOCK
/////////////////////////////////////////////////////////

Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [

    /////////////////////////////////////////////////////////
    /// PRICE
    /////////////////////////////////////////////////////////

    const Text(
      "₹",
      style: TextStyle(
        color: Color(0xffE91E63),
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
    ),

    const SizedBox(width: 2),

    AnimatedSwitcher(
      duration: const Duration(
        milliseconds: 200,
      ),
      child: Text(
        displayPrice.toStringAsFixed(0),
        key: ValueKey(
          displayPrice,
        ),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -.4,
          color: Color(0xff241B2F),
        ),
      ),
    ),

    const Spacer(),

    /////////////////////////////////////////////////////////
    /// QTY IN STOCK
    /////////////////////////////////////////////////////////

    if (displayStock > 0)
      Text(
        "$displayStock In Stock",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: stockColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
  ],
),

const SizedBox(height: 8),

                    //////////////////////////////////////////////////////
                    /// VARIANTS
                    //////////////////////////////////////////////////////

                    if (hasVariants) ...[
  InkWell(
    borderRadius: BorderRadius.circular(12),
    onTap: _showVariantDropdown,
    child: Container(
      width: double.infinity,
      height: 40,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.tune_rounded,
            size: 16,
            color: Color(0xffD81B78),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              selectedVariation?.label ??
                  "Select Variant",
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xff241B2F),
              ),
            ),
          ),

          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: Colors.black54,
          ),
        ],
      ),
    ),
  ),

  const SizedBox(height: 8),
],
                    //////////////////////////////////////////////////////
                    /// QUANTITY
                    //////////////////////////////////////////////////////

                    

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