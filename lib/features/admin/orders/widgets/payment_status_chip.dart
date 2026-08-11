import 'package:flutter/material.dart';

class PaymentStatusChip extends StatelessWidget {
  final String status;

  const PaymentStatusChip({
    super.key,
    required this.status,
  });

  Color get color {
    switch (status.toLowerCase()) {
      case "paid":
        return Colors.green;

      case "pending":
        return Colors.orange;

      case "failed":
        return Colors.red;

      default:
        return Colors.grey;
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
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}