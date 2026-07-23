import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../models/home_product_model.dart';
import '../../../services/latest_products_service.dart';
import '../../home/widgets/category_section.dart';
import '../../home/widgets/premium_app_bar.dart';
import '../../home/widgets/premium_product_card.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}
class _AllProductsScreenState extends State<AllProductsScreen> {
  //----------------------------------------------------------
  // SERVICES
  //----------------------------------------------------------

  final LatestProductsService _service = LatestProductsService();

  //----------------------------------------------------------
  // CONTROLLERS
  //----------------------------------------------------------

  final ScrollController _scrollController = ScrollController();

  //----------------------------------------------------------
  // DATA
  //----------------------------------------------------------

  final List<HomeProductModel> _products = [];

  /// Cursor for appProducts
  DocumentSnapshot? _lastAppProductDocument;

  /// Cursor for products
  DocumentSnapshot? _lastProductDocument;

  /// true = loading appProducts
  /// false = loading products
  bool _loadingAppProducts = true;

  String? _selectedCategory;

  //----------------------------------------------------------
  // STATE
  //----------------------------------------------------------

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  static const int _pageSize = 20;

  //----------------------------------------------------------
  // INIT
  //----------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _loadInitialProducts();

    _scrollController.addListener(_onScroll);
  }

  //----------------------------------------------------------
  // DISPOSE
  //----------------------------------------------------------

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  //----------------------------------------------------------
  // LOAD FIRST PAGE
  //----------------------------------------------------------

  Future<void> _loadInitialProducts() async {
    setState(() {
      _isLoading = true;

      _products.clear();

      _lastAppProductDocument = null;
      _lastProductDocument = null;

      _loadingAppProducts = true;
      _hasMore = true;
    });

    try {
      final result = await _service.getProductsPage(
        categoryId: _selectedCategory,
        loadAppProducts: true,
        startAfter: null,
        limit: _pageSize,
      );

      if (!mounted) return;

     setState(() {
  _products.addAll(result.products);

  _lastAppProductDocument = result.lastDocument;

  _loadingAppProducts =
      !result.appProductsCompleted;

  _hasMore =
      result.products.length == _pageSize ||
      !result.appProductsCompleted;
});

      // If there are no appProducts, immediately begin loading products.
    if (result.appProductsCompleted) {
  _loadingAppProducts = false;

  final productResult = await _service.getProductsPage(
    categoryId: _selectedCategory,
    loadAppProducts: false,
    startAfter: null,
    limit: _pageSize,
  );

  if (!mounted) return;

  setState(() {
    _products.addAll(productResult.products);

    _lastProductDocument = productResult.lastDocument;

    _hasMore =
        productResult.products.length == _pageSize;
  });
}
    } catch (e) {
      debugPrint(e.toString());
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  //----------------------------------------------------------
  // LOAD MORE
  //----------------------------------------------------------

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      //------------------------------------------------------
      // LOAD APP PRODUCTS
      //------------------------------------------------------

      if (_loadingAppProducts) {
        final result = await _service.getProductsPage(
          categoryId: _selectedCategory,
          loadAppProducts: true,
          startAfter: _lastAppProductDocument,
          limit: _pageSize,
        );

        if (!mounted) return;

        setState(() {
          _products.addAll(result.products);

          _lastAppProductDocument =
              result.lastDocument;

          if (result.appProductsCompleted) {
            _loadingAppProducts = false;
          }

          _hasMore = true;
        });

        // Switch immediately to products if appProducts are finished.
        if (result.appProductsCompleted) {
  _loadingAppProducts = false;

  // If this was the last appProducts page,
  // immediately load the first products page.
  if (result.products.length < _pageSize) {
    final productResult = await _service.getProductsPage(
      categoryId: _selectedCategory,
      loadAppProducts: false,
      startAfter: _lastProductDocument,
      limit: _pageSize,
    );

    if (!mounted) return;

    setState(() {
      _products.addAll(productResult.products);

      _lastProductDocument =
          productResult.lastDocument;

      _hasMore =
          productResult.products.length == _pageSize;
    });
  }
}
      }

      //------------------------------------------------------
      // LOAD PRODUCTS
      //------------------------------------------------------

      else {
        final result = await _service.getProductsPage(
          categoryId: _selectedCategory,
          loadAppProducts: false,
          startAfter: _lastProductDocument,
          limit: _pageSize,
        );

        if (!mounted) return;

        setState(() {
          _products.addAll(result.products);

          _lastProductDocument =
              result.lastDocument;

          _hasMore =
              result.products.length == _pageSize;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    if (!mounted) return;

    setState(() {
      _isLoadingMore = false;
    });
  }

  //----------------------------------------------------------
  // SCROLL LISTENER
  //----------------------------------------------------------

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent -
            300) {
      _loadMore();
    }
  }

//----------------------------------------------------------
// BUILD
//----------------------------------------------------------

@override
Widget build(BuildContext context) {
  final isTablet =
      MediaQuery.of(context).size.width > 700;

  return Scaffold(
    backgroundColor: const Color(0xffFCFCFC),

    body: SafeArea(
      child: Column(
        children: [
          //--------------------------------------------------
          // PREMIUM APP BAR
          //--------------------------------------------------

          PremiumAppBar(
            wishlistCount: 0,
            cartCount: 0,
            onMenuTap: () {},
            onWishlistTap: () {},
            onCartTap: () {},
          ),

          //--------------------------------------------------
          // CATEGORY SECTION
          //--------------------------------------------------

          CategorySection(
  onCategorySelected: (category) {
    setState(() {
      _selectedCategory = category?.id;
    });

    _loadInitialProducts();
  },
),

          //--------------------------------------------------
          // PRODUCTS
          //--------------------------------------------------

          Expanded(
            child: RefreshIndicator(
              color: const Color(0xffE91E63),
              onRefresh: _loadInitialProducts,
              child: Builder(
                builder: (context) {
                  //------------------------------------------------
                  // LOADING
                  //------------------------------------------------

                  if (_isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xffE91E63),
                      ),
                    );
                  }

                  //------------------------------------------------
                  // EMPTY
                  //------------------------------------------------

                  if (_products.isEmpty) {
                    return ListView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 180),
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 70,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: Text(
                            "No products found",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  //------------------------------------------------
                  // GRID
                  //------------------------------------------------

                  return GridView.builder(
                    controller: _scrollController,
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      30,
                    ),
                    itemCount: _products.length +
                        (_isLoadingMore ? 2 : 0),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          isTablet ? 3 : 2,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 22,
                      childAspectRatio:
                          isTablet ? 0.62 : 0.48,
                    ),
                    itemBuilder: (context, index) {
                      //------------------------------------------------
                      // BOTTOM LOADER
                      //------------------------------------------------

                      if (index >= _products.length) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xffE91E63),
                          ),
                        );
                      }

                      //------------------------------------------------
                      // PRODUCT CARD
                      //------------------------------------------------

                      return PremiumProductCard(
                        product: _products[index],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}