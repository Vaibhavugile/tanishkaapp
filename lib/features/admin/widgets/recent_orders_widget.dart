import 'package:flutter/material.dart';

import 'dashboard_card.dart';

class RecentOrdersWidget extends StatelessWidget {
  const RecentOrdersWidget({
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
            "Recent Orders",
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
          itemCount: 5,
          separatorBuilder: (_, __) =>
              const SizedBox(height: 14),
          itemBuilder: (_, index) {
            return const _RecentOrderTile();
          },
        ),
      ],
    );
  }
}

class _RecentOrderTile extends StatelessWidget {
  const _RecentOrderTile();

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      onTap: () {
        // TODO:
        // Open Order Workspace
      },

      child: Row(
        children: [

          //////////////////////////////////////////////////////
          /// IMAGE
          //////////////////////////////////////////////////////

          ClipRRect(
            borderRadius:
                BorderRadius.circular(18),
            child: Container(
              width: 72,
              height: 72,
              color: const Color(0xffF8F2F5),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 32,
                color: Color(0xffE91E63),
              ),
            ),
          ),

          const SizedBox(width: 18),

          //////////////////////////////////////////////////////
          /// DETAILS
          //////////////////////////////////////////////////////

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                const Text(
                  "#ORD10241",
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w800,
                    fontSize: 17,
                    color:
                        Color(0xff241B2F),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "Vaibhav Sharma",
                  style: TextStyle(
                    color:
                        Colors.grey.shade700,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange
                            .withOpacity(.12),
                        borderRadius:
                            BorderRadius.circular(
                                30),
                      ),
                      child: const Text(
                        "Pending",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red
                            .withOpacity(.12),
                        borderRadius:
                            BorderRadius.circular(
                                30),
                      ),
                      child: const Text(
                        "Payment Pending",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          //////////////////////////////////////////////////////
          /// PRICE
          //////////////////////////////////////////////////////

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [

              const Text(
                "₹5,420",
                style: TextStyle(
                  fontWeight:
                      FontWeight.w900,
                  fontSize: 18,
                  color:
                      Color(0xff241B2F),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "2 mins ago",
                style: TextStyle(
                  color:
                      Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 8),

              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xffE91E63),
              ),
            ],
          ),
        ],
      ),
    );
  }
}