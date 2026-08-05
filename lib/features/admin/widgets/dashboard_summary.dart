import 'package:flutter/material.dart';

import 'dashboard_card.dart';

class DashboardSummary extends StatelessWidget {
  const DashboardSummary({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Row(
          children: const [

            Expanded(
              child: _SummaryCard(
                title: "Today's Orders",
                value: "18",
                icon: Icons.shopping_bag_outlined,
                color: Color(0xffE91E63),
              ),
            ),

            SizedBox(width: 14),

            Expanded(
              child: _SummaryCard(
                title: "Pending",
                value: "7",
                icon: Icons.pending_actions,
                color: Color(0xffFF9800),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Row(
          children: const [

            Expanded(
              child: _SummaryCard(
                title: "Packing",
                value: "11",
                icon: Icons.inventory_2_outlined,
                color: Color(0xff4CAF50),
              ),
            ),

            SizedBox(width: 14),

            Expanded(
              child: _SummaryCard(
                title: "Revenue",
                value: "₹84K",
                icon: Icons.currency_rupee,
                color: Color(0xff673AB7),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;

  final String value;

  final IconData icon;

  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(.10),
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xff241B2F),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}