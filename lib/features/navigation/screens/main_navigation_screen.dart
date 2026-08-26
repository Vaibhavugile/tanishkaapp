import 'package:flutter/material.dart';

import '../../home/home_screen.dart';
import '../../cart/screens/cart_screen.dart';
import '../../order_chat/screens/order_chat_list_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../status/screens/status_screen.dart';
import '../../products/screens/all_products_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex;
  }

  late final List<Widget> _screens = [
    //////////////////////////////////////////////////////////
    /// 0 — HOME
    //////////////////////////////////////////////////////////

    const HomeScreen(),

    //////////////////////////////////////////////////////////
    /// 1 — STATUS
    //////////////////////////////////////////////////////////

    const StatusScreen(),

    //////////////////////////////////////////////////////////
    /// 2 — ALL PRODUCTS
    //////////////////////////////////////////////////////////

    // const AllProductsScreen(),

    //////////////////////////////////////////////////////////
    /// 3 — ORDERS
    //////////////////////////////////////////////////////////

    OrderChatListScreen(),

    //////////////////////////////////////////////////////////
    /// 4 — CART
    //////////////////////////////////////////////////////////

    const CartScreen(),

    //////////////////////////////////////////////////////////
    /// 5 — PROFILE
    //////////////////////////////////////////////////////////

    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      //////////////////////////////////////////////////////////
      /// MAIN BOTTOM NAVIGATION
      //////////////////////////////////////////////////////////

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,

        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        destinations: const [

          //////////////////////////////////////////////////////
          /// HOME
          //////////////////////////////////////////////////////

          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
            ),
            label: "Home",
          ),

          //////////////////////////////////////////////////////
          /// STATUS
          //////////////////////////////////////////////////////

          NavigationDestination(
            icon: Icon(
              Icons.auto_stories_outlined,
            ),
            selectedIcon: Icon(
              Icons.auto_stories,
            ),
            label: "Status",
          ),

          //////////////////////////////////////////////////////
          /// PRODUCTS
          //////////////////////////////////////////////////////

          // NavigationDestination(
          //   icon: Icon(
          //     Icons.grid_view_outlined,
          //   ),
          //   selectedIcon: Icon(
          //     Icons.grid_view_rounded,
          //   ),
          //   label: "Products",
          // ),

          //////////////////////////////////////////////////////
          /// ORDERS
          //////////////////////////////////////////////////////

          NavigationDestination(
            icon: Icon(
              Icons.chat_bubble_outline,
            ),
            selectedIcon: Icon(
              Icons.chat,
            ),
            label: "Orders",
          ),

          //////////////////////////////////////////////////////
          /// CART
          //////////////////////////////////////////////////////

          NavigationDestination(
            icon: Icon(
              Icons.shopping_cart_outlined,
            ),
            selectedIcon: Icon(
              Icons.shopping_cart,
            ),
            label: "Cart",
          ),

          //////////////////////////////////////////////////////
          /// PROFILE
          //////////////////////////////////////////////////////

          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
            ),
            selectedIcon: Icon(
              Icons.person,
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}