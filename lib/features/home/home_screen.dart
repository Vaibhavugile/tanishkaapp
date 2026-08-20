import 'package:flutter/material.dart';

import '../splash/widgets/luxury_background.dart';

import '../../../models/category_model.dart';
import '../../../models/home_product_model.dart';

import '../../../services/latest_products_service.dart';
import '../products/screens/all_products_screen.dart';
import '../cart/screens/cart_screen.dart';

import 'widgets/category_section.dart';
import 'widgets/home_banner.dart';
import 'widgets/latest_products_section.dart';
import 'widgets/premium_app_bar.dart';
import '../../../services/user_role_service.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<HomeProductModel>> _latestProductsFuture;

  /// Currently selected category
  CategoryModel? _selectedCategory;

@override
void initState() {
  super.initState();

  _loadProducts(); // Initialize the Future immediately
  _initialize();
}

Future<void> _initialize() async {
  await UserRoleService.instance.loadUserRole();

  if (!mounted) return;

  setState(() {
    _loadProducts(); // Reload products after the user role is available
  });
}

  void _loadProducts() {
    _latestProductsFuture = LatestProductsService().getLatestProducts(
      categoryId: _selectedCategory?.id,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _loadProducts();
    });

    await _latestProductsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LuxuryBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                /// Premium App Bar
                SliverToBoxAdapter(
  child: PremiumAppBar(
    wishlistCount: 0,
    onMenuTap: () {
      // TODO: Open menu/drawer
    },
    onWishlistTap: () {
      // TODO: Navigate to Wishlist
    },
    onCartTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CartScreen(),
        ),
      );
    },
  ),
),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 28),
                ),

                /// Categories
                SliverToBoxAdapter(
                  child: CategorySection(
                    onCategorySelected: (CategoryModel? category) {
                      debugPrint(
                        "Selected Category : ${category?.title ?? "All"}",
                      );

                      setState(() {
                        _selectedCategory = category;
                        _loadProducts();
                      });
                    },
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 30),
                ),

                /// Banner
               

                

                /// Latest Products
                SliverToBoxAdapter(
                  child: LatestProductsSection(
  future: _latestProductsFuture,
  onViewAll: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AllProductsScreen(),
      ),
    );
  },
),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 30),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}