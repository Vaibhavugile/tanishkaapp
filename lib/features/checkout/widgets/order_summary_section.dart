import 'package:flutter/material.dart';

import '../../../models/cart_item_model.dart';

class OrderSummarySection extends StatelessWidget {
  final List<CartItemModel> items;

  const OrderSummarySection({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          const Row(
            children: [

              Icon(
                Icons.shopping_bag_outlined,
                color: Color(0xffE91E63),
              ),

              SizedBox(width: 10),

              Text(
                "Order Summary",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          ...items.map(
            (item) => Padding(
  padding: const EdgeInsets.only(bottom: 18),
  child: Column(
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              item.image,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image),
              ),
            ),
          ),

          const SizedBox(width: 16),

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
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [

                    if (item.color.isNotEmpty)
                      _chip(
                        item.color,
                        Icons.palette_outlined,
                      ),

                    if (item.size.isNotEmpty)
                      _chip(
                        item.size,
                        Icons.straighten,
                      ),

                    _chip(
                      "Qty ${item.quantity}",
                      Icons.shopping_bag_outlined,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  "Unit Price ₹${item.unitPrice.toStringAsFixed(0)}",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Text(
            "₹${item.totalPrice.toStringAsFixed(0)}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xffE91E63),
            ),
          ),
        ],
      ),

      const SizedBox(height: 18),

      const Divider(height: 1),
    ],
  ),
),
          ),
        ],
      ),
    );
  }
  Widget _chip(
  String text,
  IconData icon,
) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 6,
    ),
    decoration: BoxDecoration(
      color: const Color(0xffF6F6F6),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: const Color(0xffE91E63),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}
}