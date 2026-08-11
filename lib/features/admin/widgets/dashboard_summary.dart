import 'package:flutter/material.dart';

import '../../../models/dashboard_stats_model.dart';
import '../../../services/dashboard_stats_service.dart';

import 'dashboard_card.dart';

class DashboardSummary extends StatelessWidget {
  const DashboardSummary({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DashboardStatsModel>(
      stream: DashboardStatsService.instance.statsStream(),
      builder: (context, snapshot) {
        final stats =
            snapshot.data ??
            const DashboardStatsModel();

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: "Today's Orders",
                    value: "${stats.todayOrders}",
                    icon: Icons.shopping_bag_outlined,
                    color: const Color(0xffE91E63),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: _SummaryCard(
                    title: "Pending Orders",
                    value: "${stats.pendingOrders}",
                    icon: Icons.pending_actions,
                    color: const Color(0xffFF9800),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: "Packing",
                    value: "${stats.packingOrders}",
                    icon: Icons.inventory_2_outlined,
                    color: const Color(0xff4CAF50),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: _SummaryCard(
                    title: "Today's Revenue",
                    value:
                        "₹${stats.todayRevenue.toStringAsFixed(0)}",
                    icon: Icons.currency_rupee,
                    color: const Color(0xff673AB7),
                  ),
                ),
              ],
            ),
          ],
        );
      },
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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