import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../splash/widgets/luxury_background.dart';

import '../../../services/admin_service.dart';

import '../widgets/admin_header.dart';
import '../widgets/dashboard_summary.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/recent_orders_widget.dart';
import '../widgets/recent_activity_widget.dart';

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

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  Future<void> _initialize() async {
    await AdminService.instance.refresh();

    await AdminService.instance.updateLastSeen();

    if (!mounted) return;

    setState(() {
      _loading = false;
    });
  }

  Future<void> _refresh() async {
    await _initialize();
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.popUntil(
      context,
      (route) => route.isFirst,
    );
  }
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

    body: LuxuryBackground(
      child: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xffE91E63),

          onRefresh: _refresh,

          child: CustomScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),

            slivers: [
                              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    18,
                    18,
                    0,
                  ),
                  child: AdminHeader(
                    onNotificationTap: () {
                      // TODO
                    },

                    onProfileTap: () {
                      // TODO
                    },
                  ),
                ),
              ),
                            const SliverToBoxAdapter(
                child: SizedBox(
                  height: 22,
                ),
              ),
                            const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18,
                  ),
                  child: DashboardSummary(),
                ),
              ),
                            const SliverToBoxAdapter(
                child: SizedBox(
                  height: 26,
                ),
              ),
                            const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18,
                  ),
                  child: QuickActionsGrid(),
                ),
              ),
                            const SliverToBoxAdapter(
                child: SizedBox(
                  height: 28,
                ),
              ),
                            const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18,
                  ),
                  child: RecentOrdersWidget(),
                ),
              ),
                            const SliverToBoxAdapter(
                child: SizedBox(
                  height: 28,
                ),
              ),
                            const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18,
                  ),
                  child: RecentActivityWidget(),
                ),
              ),
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

    floatingActionButton: FloatingActionButton.extended(
      backgroundColor: const Color(0xffE91E63),
      foregroundColor: Colors.white,
      elevation: 10,

      onPressed: _logout,

      icon: const Icon(Icons.logout),

      label: const Text(
        "Logout",
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
}