import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/cart_provider.dart';
import '../../../models/cart_item_model.dart';
import 'quantity_selector.dart';

class CartItemCard extends StatelessWidget {
  final CartItemModel item;

  const CartItemCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFE91E63);

    final cart = context.read<CartProvider>();

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //////////////////////////////////////////////////////
          /// PRODUCT IMAGE
          //////////////////////////////////////////////////////

          ClipRRect(
            borderRadius: BorderRadius.circular(10),

            child: Image.network(
              item.image,
              width: 68,
              height: 68,
              fit: BoxFit.contain,

              errorBuilder: (_, __, ___) {
                return Container(
                  width: 68,
                  height: 68,
                  color: Colors.grey.shade100,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.grey.shade400,
                    size: 24,
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 10),

          //////////////////////////////////////////////////////
          /// PRODUCT DETAILS
          //////////////////////////////////////////////////////

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                //////////////////////////////////////////////////
                /// PRODUCT NAME
                //////////////////////////////////////////////////

                Text(
                  item.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff222222),
                  ),
                ),

                const SizedBox(height: 3),

                //////////////////////////////////////////////////
                /// PRODUCT CODE
                //////////////////////////////////////////////////

                if (item.productCode.isNotEmpty)
                  Text(
                    item.productCode,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                //////////////////////////////////////////////////
                /// VARIATION
                //////////////////////////////////////////////////

                if (item.hasVariation)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 4,
                    ),
                    child: Row(
                      children: [
                        if (item.color.isNotEmpty)
                          _miniTag(
                            item.color,
                          ),

                        if (item.color.isNotEmpty &&
                            item.size.isNotEmpty)
                          const SizedBox(
                            width: 5,
                          ),

                        if (item.size.isNotEmpty)
                          _miniTag(
                            item.size,
                          ),
                      ],
                    ),
                  ),

                const SizedBox(height: 7),

                //////////////////////////////////////////////////
                /// PRICE + QUANTITY
                //////////////////////////////////////////////////

                Row(
                  children: [
                    Text(
                      "₹${item.unitPrice.toStringAsFixed(0)}",

                      style: const TextStyle(
                        color: primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(width: 10),

                    QuantitySelector(
                      quantity: item.quantity,

                      onIncrease: () async {
                        try {
                          await cart.increaseQuantity(
                            item: item,
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString(),
                                ),
                              ),
                            );
                          }
                        }
                      },

                      onDecrease: () async {
                        try {
                          await cart.decreaseQuantity(
                            item: item,
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString(),
                                ),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          //////////////////////////////////////////////////////
          /// DELETE
          //////////////////////////////////////////////////////

          const SizedBox(width: 5),

          SizedBox(
            width: 34,
            height: 34,

            child: IconButton(
              padding: EdgeInsets.zero,

              tooltip: "Remove",

              icon: Icon(
                Icons.delete_outline_rounded,
                color: Colors.grey.shade500,
                size: 20,
              ),

              onPressed: () async {
                await cart.removeItem(
                  item.id,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  //////////////////////////////////////////////////////////////
  /// MINI TAG
  //////////////////////////////////////////////////////////////

  static Widget _miniTag(
    String text,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 3,
      ),

      decoration: BoxDecoration(
        color: const Color(0xffFCE4EC),
        borderRadius: BorderRadius.circular(6),
      ),

      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,

        style: const TextStyle(
          color: Color(0xffC2185B),
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}