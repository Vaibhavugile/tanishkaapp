import 'package:flutter/material.dart';

import '../../../models/home_product_model.dart';
import '../../../models/variation_model.dart';
import '../../../services/cart_service.dart';
import '../../../services/user_role_service.dart';

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

  VariationModel? _selectedVariation;

  @override
  void initState() {
    super.initState();

    if (widget.product.product.hasVariants &&
        widget.product.product.variations.isNotEmpty) {
      _selectedVariation =
          widget.product.product.variations.first;
    }
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

  void selectVariation(
    VariationModel variation,
  ) {
    setState(() {
      _selectedVariation = variation;
      _quantity = 1;
    });
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

  Widget buildQuantitySelector() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          IconButton(
            splashRadius: 20,
            onPressed: decreaseQuantity,
            icon: const Icon(Icons.remove),
          ),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              "$_quantity",
              key: ValueKey(_quantity),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),

          IconButton(
            splashRadius: 20,
            onPressed: increaseQuantity,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget buildStockWidget() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: stockColor.withOpacity(.10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          Icon(
            isAvailable
                ? Icons.check_circle
                : Icons.cancel,
            size: 16,
            color: stockColor,
          ),

          const SizedBox(width: 6),

          Text(
            stockLabel,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: stockColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAddToCartButton() {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: isAvailable
              ? const LinearGradient(
                  colors: [
                    Color(0xffFF5FA2),
                    Color(0xffE91E63),
                  ],
                )
              : LinearGradient(
                  colors: [
                    Colors.grey.shade400,
                    Colors.grey.shade500,
                  ],
                ),
          boxShadow: [
            BoxShadow(
              color: isAvailable
                  ? const Color(0xffE91E63)
                      .withOpacity(.28)
                  : Colors.black12,
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius:
                BorderRadius.circular(18),
            onTap: isAvailable
                ? _addToCart
                : null,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [

                  Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                  ),

                  SizedBox(width: 10),

                  Text(
                    "Add to Cart",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                flex: 50,
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
                          child: Image.network(
                            product.image,
                            fit: BoxFit.cover,
                            loadingBuilder:
                                (context, child, progress) {
                              if (progress == null) {
                                return child;
                              }

                              return Container(
                                color:
                                    const Color(0xffFAF7FB),
                                child: const Center(
                                  child:
                                      CircularProgressIndicator(
                                    color:
                                        Color(0xffE91E63),
                                  ),
                                ),
                              );
                            },
                            errorBuilder:
                                (_, __, ___) => Container(
                              color:
                                  const Color(0xffFAF7FB),
                              child: const Icon(
                                Icons
                                    .image_not_supported,
                                size: 42,
                              ),
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

                    Positioned(
                      left: 14,
                      bottom: 14,
                      child: buildStockWidget(),
                    ),
                  ],
                ),
              ),

              /////////////////////////////////////////////////////////
              /// DETAILS
              /////////////////////////////////////////////////////////

              Expanded(
                flex: 50,
                child: Padding(
                  padding:
                      const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                                          Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xff241B2F),
                        height: 1.3,
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

                    const SizedBox(height: 08),

                    //////////////////////////////////////////////////////
                    /// PRICE
                    //////////////////////////////////////////////////////

                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.end,
                      children: [

                        const Text(
                          "₹",
                          style: TextStyle(
                            color: Color(0xffE91E63),
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(width: 2),

                        AnimatedSwitcher(
                          duration: const Duration(
                              milliseconds: 250),
                          child: Text(
                            displayPrice
                                .toStringAsFixed(0),
                            key: ValueKey(
                                displayPrice),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight:
                                  FontWeight.w900,
                              letterSpacing: -.8,
                              color:
                                  Color(0xff241B2F),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    //////////////////////////////////////////////////////
                    /// VARIANTS
                    //////////////////////////////////////////////////////

                    if (hasVariants) ...[
                      SizedBox(
                        height: 42,
                        child: ListView.builder(
                          scrollDirection:
                              Axis.horizontal,
                          itemCount:
                              variations.length,
                          itemBuilder:
                              (context, index) {
                            return buildVariantChip(
                              variations[index],
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 10),
                    ],

                    //////////////////////////////////////////////////////
                    /// QUANTITY
                    //////////////////////////////////////////////////////

                    Row(
                      children: [

                        const Text(
                          "Quantity",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),

                        const Spacer(),

                        buildQuantitySelector(),
                      ],
                    ),

                    const Spacer(),

                    //////////////////////////////////////////////////////
                    /// ADD TO CART
                    //////////////////////////////////////////////////////

                    buildAddToCartButton(),
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