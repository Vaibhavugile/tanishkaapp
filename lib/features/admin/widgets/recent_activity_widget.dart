import 'package:flutter/material.dart';

import 'dashboard_card.dart';

class RecentActivityWidget extends StatelessWidget {
  const RecentActivityWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        const Padding(
          padding: EdgeInsets.only(
            left: 4,
            bottom: 16,
          ),
          child: Text(
            "Recent Activity",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xff241B2F),
            ),
          ),
        ),

        ListView.separated(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          itemCount: _activities.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: 12),
          itemBuilder: (_, index) {
            return _ActivityTile(
              activity: _activities[index],
            );
          },
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final Activity activity;

  const _ActivityTile({
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Row(
        children: [

          //////////////////////////////////////////////////////
          /// ICON
          //////////////////////////////////////////////////////

          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color:
                  activity.color.withOpacity(.12),
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: Icon(
              activity.icon,
              color: activity.color,
            ),
          ),

          const SizedBox(width: 16),

          //////////////////////////////////////////////////////
          /// DETAILS
          //////////////////////////////////////////////////////

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        Color(0xff241B2F),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  activity.subtitle,
                  style: TextStyle(
                    color:
                        Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          Text(
            activity.time,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class Activity {
  final IconData icon;

  final Color color;

  final String title;

  final String subtitle;

  final String time;

  const Activity({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}

const List<Activity> _activities = [

  Activity(
    icon: Icons.payments,
    color: Colors.green,
    title: "Payment Verified",
    subtitle:
        "Rahul verified Order #ORD10241",
    time: "2m",
  ),

  Activity(
    icon: Icons.inventory,
    color: Colors.orange,
    title: "Packing Completed",
    subtitle:
        "Priya packed Necklace Set",
    time: "8m",
  ),

  Activity(
    icon: Icons.local_shipping,
    color: Colors.deepPurple,
    title: "Order Dispatched",
    subtitle:
        "Blue Dart Tracking Generated",
    time: "15m",
  ),

  Activity(
    icon: Icons.chat,
    color: Colors.blue,
    title: "Customer Message",
    subtitle:
        "Customer uploaded payment proof",
    time: "20m",
  ),

  Activity(
    icon: Icons.shopping_bag,
    color: Color(0xffE91E63),
    title: "New Order",
    subtitle:
        "New jewellery order received",
    time: "25m",
  ),
];