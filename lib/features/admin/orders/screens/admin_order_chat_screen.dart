import 'package:flutter/material.dart';
import '../widgets/order_summary_card.dart';
class AdminOrderChatScreen extends StatefulWidget {
  final String orderId;

  const AdminOrderChatScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<AdminOrderChatScreen> createState() =>
      _AdminOrderChatScreenState();
}

class _AdminOrderChatScreenState
    extends State<AdminOrderChatScreen> {

  @override
  void initState() {
    super.initState();

    // Mark unread count as 0
    // AdminOrderService.instance.markAdminRead(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffF6F7FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        titleSpacing: 0,
        title: const Text(
          "Order Chat",
          style: TextStyle(
            color: Color(0xff241B2F),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [

            ////////////////////////////////////////////////////
            /// ORDER SUMMARY
            ////////////////////////////////////////////////////

            // Next Step

            ////////////////////////////////////////////////////
            /// CHAT
            ////////////////////////////////////////////////////

            Expanded(
  child: Column(
    children: [
      OrderSummaryCard(
        orderId: widget.orderId,
      ),

      const Expanded(
        child: Center(
          child: Text(
            "Messages Coming Next...",
          ),
        ),
      ),
    ],
  ),
),

            ////////////////////////////////////////////////////
            /// INPUT
            ////////////////////////////////////////////////////

            // Next Step
          ],
        ),
      ),
    );
  }
}