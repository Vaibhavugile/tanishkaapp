import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderSummaryCard extends StatelessWidget {
  final String orderId;

  const OrderSummaryCard({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<
        DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection("orders")
          .doc(orderId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: LinearProgressIndicator(),
          );
        }

        if (!snapshot.data!.exists) {
          return const SizedBox();
        }

        final data = snapshot.data!.data()!;

        final items =
            List.from(data["items"] ?? []);

        final subtotal =
            (data["subtotal"] ?? 0).toDouble();

        final shipping =
            (data["shippingFee"] ?? 0).toDouble();

        final total =
            (data["totalAmount"] ?? 0).toDouble();

        final orderStatus =
            data["status"] ?? "Placed";

        final paymentStatus =
            data["paymentStatus"] ?? "Pending";

        return Card(
          elevation: 0,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),
          child: Padding(
            padding:
                const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  "Order Summary",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 18),

                _row(
                  "Order ID",
                  orderId,
                ),

                _row(
                  "Items",
                  "${items.length}",
                ),

                _row(
                  "Subtotal",
                  "₹${subtotal.toStringAsFixed(0)}",
                ),

                _row(
                  "Shipping",
                  "₹${shipping.toStringAsFixed(0)}",
                ),

                const Divider(height: 28),

                _row(
                  "Total",
                  "₹${total.toStringAsFixed(0)}",
                  bold: true,
                ),

                const SizedBox(height: 18),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _statusChip(
                      orderStatus,
                      Colors.blue,
                    ),

                    _statusChip(
                      paymentStatus,
                      Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _row(
    String title,
    String value, {
    bool bold = false,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold
                  ? FontWeight.bold
                  : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(
    String text,
    Color color,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius:
            BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }
}