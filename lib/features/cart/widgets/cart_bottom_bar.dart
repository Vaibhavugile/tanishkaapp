import 'package:flutter/material.dart';

class CartBottomBar extends StatelessWidget {
  final int totalItems;
  final double totalPrice;
  final VoidCallback onCheckout;

  const CartBottomBar({
    super.key,
    required this.totalItems,
    required this.totalPrice,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xffE91E63);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          14,
          10,
          14,
          10,
        ),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.10),
              blurRadius: 18,
              offset: const Offset(0, -5),
            ),
          ],
        ),

        child: Row(
          children: [
            //////////////////////////////////////////////////////
            /// TOTAL SECTION
            //////////////////////////////////////////////////////

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        "$totalItems item${totalItems == 1 ? "" : "s"}",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(width: 6),

                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(width: 6),

                      Text(
                        "Cart total",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 2),

                  Text(
                    "₹${totalPrice.toStringAsFixed(0)}",
                    style: const TextStyle(
                      color: primary,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                ],
              ),
            ),

            //////////////////////////////////////////////////////
            /// CHECKOUT BUTTON
            //////////////////////////////////////////////////////

            SizedBox(
              height: 46,

              child: ElevatedButton(
                onPressed: onCheckout,

                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,

                  elevation: 0,

                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),

                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 19,
                    ),

                    SizedBox(width: 7),

                    Text(
                      "Checkout",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    SizedBox(width: 4),

                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}