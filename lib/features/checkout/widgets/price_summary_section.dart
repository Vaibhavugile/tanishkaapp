import 'package:flutter/material.dart';

class PriceSummarySection extends StatelessWidget {
  final double subtotal;
  final double shipping;
  final double discount;
  final double gst;

  const PriceSummarySection({
    super.key,
    required this.subtotal,
    required this.shipping,
    required this.discount,
    required this.gst,
  });

  @override
  Widget build(BuildContext context) {
    final total =
        subtotal + shipping + gst - discount;

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
        children: [

          const Row(
            children: [

              Icon(
                Icons.receipt_long_rounded,
                color: Color(0xffE91E63),
              ),

              SizedBox(width: 10),

              Text(
                "Price Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _row(
            "Subtotal",
            "₹${subtotal.toStringAsFixed(0)}",
          ),

          const SizedBox(height: 12),

          _row(
            "Shipping",
            shipping == 0
                ? "FREE"
                : "₹${shipping.toStringAsFixed(0)}",
          ),

          const SizedBox(height: 12),

          _row(
            "Discount",
            "- ₹${discount.toStringAsFixed(0)}",
            valueColor: Colors.green,
          ),

          const SizedBox(height: 12),

          _row(
            "GST",
            "₹${gst.toStringAsFixed(0)}",
          ),

          const Padding(
            padding:
                EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),

          _row(
            "Grand Total",
            "₹${total.toStringAsFixed(0)}",
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _row(
    String title,
    String value, {
    Color? valueColor,
    bool isTotal = false,
  }) {
    return Row(
      children: [

        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 17 : 15,
              fontWeight: isTotal
                  ? FontWeight.bold
                  : FontWeight.w500,
            ),
          ),
        ),

        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 15,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}