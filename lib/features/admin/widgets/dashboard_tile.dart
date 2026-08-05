import 'package:flutter/material.dart';

import 'dashboard_card.dart';

class DashboardTile extends StatelessWidget {
  final IconData icon;

  final String title;

  final String? subtitle;

  final Color color;

  final int? badge;

  final VoidCallback onTap;

  const DashboardTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.badge,
    this.color = const Color(0xffE91E63),
  });

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color.withOpacity(.10),
                  borderRadius:
                      BorderRadius.circular(18),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),

              const Spacer(),

              if (badge != null && badge! > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius:
                        BorderRadius.circular(30),
                  ),
                  child: Text(
                    "$badge",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              color: Color(0xff241B2F),
            ),
          ),

          if (subtitle != null) ...[
            const SizedBox(height: 6),

            Text(
              subtitle!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}