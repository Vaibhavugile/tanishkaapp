import 'package:flutter/material.dart';

import '../../../services/admin_service.dart';
import 'dashboard_tile.dart';
import 'permission_gate.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({
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
            "Quick Actions",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xff241B2F),
            ),
          ),
        ),

        GridView.count(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),

          crossAxisCount: 2,

          crossAxisSpacing: 16,

          mainAxisSpacing: 16,

          childAspectRatio: 1.05,

          children: [

            //////////////////////////////////////////////////////
            /// Orders
            //////////////////////////////////////////////////////

            PermissionGate(
              allow: (admin) =>
                  admin.canViewOrders,
              child: DashboardTile(
                icon:
                    Icons.shopping_bag_outlined,
                title: "Orders",
                subtitle:
                    "Manage customer orders",
                badge: 12,
                onTap: () {
                  // TODO
                },
              ),
            ),

            //////////////////////////////////////////////////////
            /// Chats
            //////////////////////////////////////////////////////

            PermissionGate(
              allow: (admin) =>
                  admin.canChat,
              child: DashboardTile(
                icon:
                    Icons.chat_bubble_outline,
                title: "Chats",
                subtitle:
                    "Customer conversations",
                badge: 4,
                color: Colors.blue,
                onTap: () {
                  // TODO
                },
              ),
            ),

            //////////////////////////////////////////////////////
            /// Packing
            //////////////////////////////////////////////////////

            PermissionGate(
              allow: (admin) =>
                  admin.canPackOrders,
              child: DashboardTile(
                icon:
                    Icons.inventory_2_outlined,
                title: "Packing",
                subtitle:
                    "Packing workspace",
                badge: 9,
                color: Colors.orange,
                onTap: () {
                  // TODO
                },
              ),
            ),

            //////////////////////////////////////////////////////
            /// Payments
            //////////////////////////////////////////////////////

            PermissionGate(
              allow: (admin) =>
                  admin.canVerifyPayments,
              child: DashboardTile(
                icon:
                    Icons.payments_outlined,
                title: "Payments",
                subtitle:
                    "Verify customer payments",
                badge: 5,
                color: Colors.green,
                onTap: () {
                  // TODO
                },
              ),
            ),

            //////////////////////////////////////////////////////
            /// Shipping
            //////////////////////////////////////////////////////

            PermissionGate(
              allow: (admin) =>
                  admin.canShipOrders,
              child: DashboardTile(
                icon:
                    Icons.local_shipping_outlined,
                title: "Shipping",
                subtitle:
                    "Dispatch orders",
                color: Colors.deepPurple,
                onTap: () {
                  // TODO
                },
              ),
            ),

            //////////////////////////////////////////////////////
            /// Inventory
            //////////////////////////////////////////////////////

            PermissionGate(
              allow: (admin) =>
                  admin.canManageInventory,
              child: DashboardTile(
                icon:
                    Icons.warehouse_outlined,
                title: "Inventory",
                subtitle:
                    "Stock management",
                color: Colors.teal,
                onTap: () {
                  // TODO
                },
              ),
            ),

            //////////////////////////////////////////////////////
            /// Reports
            //////////////////////////////////////////////////////

            PermissionGate(
              allow: (admin) =>
                  admin.canViewReports,
              child: DashboardTile(
                icon:
                    Icons.bar_chart_rounded,
                title: "Reports",
                subtitle:
                    "Business analytics",
                color: Colors.indigo,
                onTap: () {
                  // TODO
                },
              ),
            ),

            //////////////////////////////////////////////////////
            /// Staff
            //////////////////////////////////////////////////////

            PermissionGate(
              allow: (admin) =>
                  admin.canManageAdmins,
              child: DashboardTile(
                icon:
                    Icons.people_alt_outlined,
                title: "Staff",
                subtitle:
                    "Manage administrators",
                color: Colors.pink,
                onTap: () {
                  // TODO
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}