import 'package:flutter/material.dart';

import '../../../models/home_product_model.dart';
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

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
final price = product.getPrice(
  role: UserRoleService.instance.role,
);
    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      scale: _pressed ? .98 : 1,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () {
          // TODO: Product Details
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

              //========================================================
              // IMAGE
              //========================================================

              Expanded(
                flex: 58,
                child: Stack(
                  children: [

                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
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
                                color: const Color(0xffFAF7FB),
                                child: const Center(
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xffE91E63),
                                  ),
                                ),
                              );
                            },
                            errorBuilder:
                                (_, __, ___) => Container(
                              color: const Color(0xffFAF7FB),
                              child: const Icon(
                                Icons.image_not_supported_rounded,
                                size: 42,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    //--------------------------------------
                    // Gradient Overlay
                    //--------------------------------------

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
                                Colors.black.withOpacity(.08),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    //--------------------------------------
                    // NEW ARRIVAL
                    //--------------------------------------

                    Positioned(
                      left: 14,
                      top: 14,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(50),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xffFF73AF),
                              Color(0xffE91E63),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xffE91E63)
                                  .withOpacity(.30),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 12,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "NEW",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight:
                                    FontWeight.w700,
                                letterSpacing: .6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    //--------------------------------------
                    // Wishlist
                    //--------------------------------------

                    Positioned(
                      top: 12,
                      right: 12,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(100),
                          onTap: () {
                            setState(() {
                              _liked = !_liked;
                            });
                          },
                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 250),
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.95),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.black.withOpacity(.08),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                            child: AnimatedSwitcher(
                              duration:
                                  const Duration(milliseconds: 250),
                              child: Icon(
                                _liked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                key: ValueKey(_liked),
                                color: _liked
                                    ? const Color(0xffE91E63)
                                    : Colors.black87,
                                size: 21,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                                        //--------------------------------------
                    // Luxury Bottom Fade
                    //--------------------------------------

                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(.10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              //========================================================
              // DETAILS
              //========================================================

              Expanded(
                flex: 42,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    14,
                    16,
                    16,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                          color: Color(0xff241B2F),
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "Code • ${product.code}",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const Spacer(),

                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.end,
                        children: [
                          const Text(
                            "₹",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xffE91E63),
                            ),
                          ),

                          const SizedBox(width: 2),

                          Text(
  price.toStringAsFixed(0),
  style: const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: Color(0xff241B2F),
    letterSpacing: -.8,
  ),
),
                        ],
                      ),

                      const SizedBox(height: 18),

                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 38,
                              decoration: BoxDecoration(
                                color: product.inStock
                                    ? const Color(
                                        0xffEEF9F2)
                                    : const Color(
                                        0xffFFF3F3),
                                borderRadius:
                                    BorderRadius.circular(
                                        30),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    product.inStock
                                        ? Icons
                                            .verified_rounded
                                        : Icons
                                            .cancel_rounded,
                                    size: 16,
                                    color: product.inStock
                                        ? const Color(
                                            0xff28A745)
                                        : Colors.red,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    product.inStock
                                        ? "Ready"
                                        : "Sold Out",
                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight.w700,
                                      fontSize: 13,
                                      color:
                                          product.inStock
                                              ? const Color(
                                                  0xff28A745)
                                              : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(
                                      18),
                              onTap: () {
                                // TODO
                              },
                              child: Ink(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius
                                          .circular(18),
                                  gradient:
                                      const LinearGradient(
                                    colors: [
                                      Color(0xffFF5FA2),
                                      Color(0xffE91E63),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                              0xffE91E63)
                                          .withOpacity(.30),
                                      blurRadius: 18,
                                      offset:
                                          const Offset(
                                              0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons
                                      .shopping_bag_outlined,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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