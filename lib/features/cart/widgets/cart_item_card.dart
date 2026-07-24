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

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                item.image,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey.shade200,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    item.productCode,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),

                  if (item.hasVariation)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 8,
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Chip(
                            visualDensity:
                                VisualDensity.compact,
                            label: Text(item.color),
                          ),
                          Chip(
                            visualDensity:
                                VisualDensity.compact,
                            label: Text(item.size),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 10),

                  Text(
                    "₹${item.unitPrice.toStringAsFixed(0)}",
                    style: const TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
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

                      const Spacer(),

                      IconButton(
                        tooltip: "Remove",
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          await cart.removeItem(item.id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}