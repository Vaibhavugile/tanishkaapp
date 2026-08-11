import 'package:flutter/material.dart';

class OrderStatusChip extends StatelessWidget {
  final String status;

  const OrderStatusChip({
    super.key,
    required this.status,
  });

  Color get color {
    switch (status.toLowerCase()) {
      case "placed":
        return Colors.orange;

      case "confirmed":
        return Colors.blue;

      case "packing":
        return Colors.deepPurple;

      case "packed":
        return Colors.indigo;

      case "shipped":
        return Colors.teal;

      case "delivered":
        return Colors.green;

      case "cancelled":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (status.toLowerCase()) {
      case "placed":
        return Icons.shopping_bag_outlined;

      case "confirmed":
        return Icons.verified_outlined;

      case "packing":
        return Icons.inventory_2_outlined;

      case "packed":
        return Icons.all_inbox_outlined;

      case "shipped":
        return Icons.local_shipping_outlined;

      case "delivered":
        return Icons.check_circle_outline;

      case "cancelled":
        return Icons.cancel_outlined;

      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 15,
          ),

          const SizedBox(width: 5),

          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}