import 'package:flutter/material.dart';

import '../../../models/home_product_model.dart';
import 'premium_product_card.dart';
import '../../products/screens/all_products_screen.dart';
class LatestProductsSection extends StatelessWidget {
  final Future<List<HomeProductModel>> future;

  /// View All callback
  final VoidCallback? onViewAll;

  const LatestProductsSection({
    super.key,
    required this.future,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HomeProductModel>>(
      future: future,
      builder: (context, snapshot) {
        //----------------------------------------------------------
        // LOADING
        //----------------------------------------------------------

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xffE91E63),
              ),
            ),
          );
        }

        //----------------------------------------------------------
        // ERROR
        //----------------------------------------------------------

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(30),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "Something went wrong",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        //----------------------------------------------------------
        // DATA
        //----------------------------------------------------------

        final products = snapshot.data ?? [];
        final productCount = products.length;

        if (products.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.diamond_outlined,
                    size: 55,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No products available",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final width = MediaQuery.of(context).size.width;
        final isTablet = width > 700;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //-------------------------------------------------------
              // HEADER
              //-------------------------------------------------------

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 5,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xffFF4F9A),
                          Color(0xffE91E63),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Latest Collection",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xff241B2F),
                            letterSpacing: -.3,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          "$productCount latest products curated for you",
                          style: const TextStyle(
                            color: Color(0xff8B8193),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(30),
                      onTap: onViewAll,
                      child: Ink(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.05),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "View All",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .primaryColor,
                                fontWeight:
                                    FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: Theme.of(context)
                                  .primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              //-------------------------------------------------------
              // GRID
              //-------------------------------------------------------
                            GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                clipBehavior: Clip.none,
                itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: isTablet ? 3 : 2,
  crossAxisSpacing: 14,
  mainAxisSpacing: 14,
  childAspectRatio: isTablet ? 0.66 : 0.45,
),
                itemBuilder: (context, index) {
                  return PremiumProductCard(
                    product: products[index],
                  );
                },
              ),

              const SizedBox(height: 20),

///////////////////////////////////////////////////////////
/// BOTTOM VIEW ALL
///////////////////////////////////////////////////////////

Center(
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onViewAll,
      child: Ink(
        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Theme.of(context)
                .primaryColor
                .withOpacity(.15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "View All Products",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),

            const SizedBox(width: 7),

            Icon(
              Icons.arrow_forward_rounded,
              size: 17,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    ),
  ),
),

const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}