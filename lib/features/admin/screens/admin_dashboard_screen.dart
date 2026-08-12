import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../splash/widgets/luxury_background.dart';

import '../../../services/admin_service.dart';

import '../widgets/admin_header.dart';
import '../widgets/dashboard_summary.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/recent_orders_widget.dart';
import '../widgets/recent_activity_widget.dart';
import '../payments/screens/admin_payment_methods_screen.dart';
import '../orders/screens/order_list_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({
    super.key,
  });

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends State<AdminDashboardScreen> {
  bool _loading = true;

  ///////////////////////////////////////////////////////////
  /// INIT
  ///////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  ///////////////////////////////////////////////////////////
  /// INITIALIZE
  ///////////////////////////////////////////////////////////

  Future<void> _initialize() async {
    await AdminService.instance.refresh();

    await AdminService.instance.updateLastSeen();

    if (!mounted) return;

    setState(() {
      _loading = false;
    });
  }

  ///////////////////////////////////////////////////////////
  /// REFRESH
  ///////////////////////////////////////////////////////////

  Future<void> _refresh() async {
    await _initialize();
  }

  ///////////////////////////////////////////////////////////
  /// OPEN ORDERS
  ///////////////////////////////////////////////////////////

  void _openOrders() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const OrderListScreen(),
      ),
    );
  }
  ///////////////////////////////////////////////////////////
/// OPEN PAYMENT METHODS
///////////////////////////////////////////////////////////

void _openPaymentMethods() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>
          const AdminPaymentMethodsScreen(),
    ),
  );
}

  ///////////////////////////////////////////////////////////
  /// LOGOUT
  ///////////////////////////////////////////////////////////

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.popUntil(
      context,
      (route) => route.isFirst,
    );
  }

  ///////////////////////////////////////////////////////////
  /// BUILD
  ///////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xffE91E63),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,

      /////////////////////////////////////////////////////////
      /// BODY
      /////////////////////////////////////////////////////////

      body: LuxuryBackground(
        child: SafeArea(
          child: RefreshIndicator(
            color: const Color(0xffE91E63),

            onRefresh: _refresh,

            child: CustomScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(
                parent:
                    BouncingScrollPhysics(),
              ),

              slivers: [

                //////////////////////////////////////////////////
                /// ADMIN HEADER
                //////////////////////////////////////////////////

                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      18,
                      18,
                      18,
                      0,
                    ),
                    child: AdminHeader(
                      onNotificationTap: () {
                        // TODO:
                        // Notifications
                      },
                      onProfileTap: () {
                        // TODO:
                        // Admin profile
                      },
                    ),
                  ),
                ),

                //////////////////////////////////////////////////
                /// GAP
                //////////////////////////////////////////////////

                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 22,
                  ),
                ),

                //////////////////////////////////////////////////
                /// DASHBOARD SUMMARY
                //////////////////////////////////////////////////

                const SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    child:
                        DashboardSummary(),
                  ),
                ),

                //////////////////////////////////////////////////
                /// GAP
                //////////////////////////////////////////////////

                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 26,
                  ),
                ),

                //////////////////////////////////////////////////
                /// QUICK ACTIONS
                //////////////////////////////////////////////////

                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    child: QuickActionsGrid(
  onOrdersTap: _openOrders,
  onPaymentsTap: _openPaymentMethods,
),
                  ),
                ),

                //////////////////////////////////////////////////
                /// GAP
                //////////////////////////////////////////////////

                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 28,
                  ),
                ),

                //////////////////////////////////////////////////
                /// RECENT ORDERS HEADER
                //////////////////////////////////////////////////

                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    child: Row(
                      children: [

                        const Expanded(
                          child: Text(
                            "Recent Orders",
                            style: TextStyle(
                              color:
                                  Color(
                                0xff241B2F,
                              ),
                              fontSize: 19,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                        ),

                        TextButton(
                          onPressed:
                              _openOrders,
                          child: const Text(
                            "View All",
                            style:
                                TextStyle(
                              color:
                                  Color(
                                0xffE91E63,
                              ),
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                //////////////////////////////////////////////////
                /// RECENT ORDERS
                //////////////////////////////////////////////////

                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    child:
                        RecentOrdersWidget(
                      onViewAll:
                          _openOrders,
                    ),
                  ),
                ),

                //////////////////////////////////////////////////
                /// GAP
                //////////////////////////////////////////////////

                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 28,
                  ),
                ),

                //////////////////////////////////////////////////
                /// RECENT ACTIVITY
                //////////////////////////////////////////////////

                const SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    child:
                        RecentActivityWidget(),
                  ),
                ),

                //////////////////////////////////////////////////
                /// BOTTOM SPACE
                //////////////////////////////////////////////////

                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 120,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      /////////////////////////////////////////////////////////
      /// LOGOUT
      /////////////////////////////////////////////////////////

      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor:
            const Color(0xffE91E63),

        foregroundColor:
            Colors.white,

        elevation: 10,

        onPressed: _logout,

        icon: const Icon(
          Icons.logout,
        ),

        label: const Text(
          "Logout",
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }
}