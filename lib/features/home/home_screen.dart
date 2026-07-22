import 'package:flutter/material.dart';

import '../splash/widgets/luxury_background.dart';
import './widgets/premium_app_bar.dart';
import './widgets/category_section.dart';
import '../../../models/category_model.dart';
import './widgets/home_banner.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LuxuryBackground(
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              /// Premium App Bar
              SliverToBoxAdapter(
                child: PremiumAppBar(
                  wishlistCount: 0,
                  cartCount: 0,
                  onMenuTap: () {
                    // TODO: Open Drawer
                  },
                  onWishlistTap: () {
                    // TODO: Wishlist Screen
                  },
                  onCartTap: () {
                    // TODO: Cart Screen
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

                    // Product filtering will be added later.
                  },
                ),
              ),

         const SliverToBoxAdapter(
  child: SizedBox(height: 30),
),

const SliverToBoxAdapter(
  child: HomeBanner(),
),

const SliverToBoxAdapter(
  child: SizedBox(height: 35),
),
            ],
          ),
        ),
      ),
    );
  }
}