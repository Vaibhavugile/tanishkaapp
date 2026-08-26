import 'package:flutter/material.dart';

import '../../../models/cart_item_model.dart';
import '../../../models/category_model.dart';
import '../../../models/home_product_model.dart';
import '../../../models/variation_model.dart';
import '../../../services/cart_service.dart';
import '../../../services/latest_products_service.dart';

class StatusViewerScreen extends StatefulWidget {
  final CategoryModel category;

  const StatusViewerScreen({
    super.key,
    required this.category,
  });

  @override
  State<StatusViewerScreen> createState() =>
      _StatusViewerScreenState();
}

class _StatusViewerScreenState
    extends State<StatusViewerScreen> {
  static const Color primary =
      Color(0xffE91E63);

  final LatestProductsService _productService =
      LatestProductsService();

  final PageController _pageController =
      PageController();

  final List<HomeProductModel> _products = [];

  int _currentIndex = 0;

  bool _loading = true;
  bool _loadingMore = false;

  String? _error;

  dynamic _productsCursor;
  dynamic _appProductsCursor;

  bool _productsHasMore = true;
  bool _appProductsHasMore = true;

  bool _productsLoaded = false;
  bool _appProductsLoaded = false;

  //////////////////////////////////////////////////////////////
  /// INIT
  //////////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();

    _loadInitialProducts();
  }

  //////////////////////////////////////////////////////////////
  /// DISPOSE
  //////////////////////////////////////////////////////////////

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  //////////////////////////////////////////////////////////////
  /// INITIAL LOAD
  //////////////////////////////////////////////////////////////

  Future<void> _loadInitialProducts() async {
    try {
      if (mounted) {
        setState(() {
          _loading = true;
          _error = null;
        });
      }

      //////////////////////////////////////////////////////////
      /// LOAD FIRST PAGE
      //////////////////////////////////////////////////////////

      await _loadNextPage(
        loadAppProducts: false,
      );

      //////////////////////////////////////////////////////////
      /// IF PRODUCTS < 20
      /// LOAD FROM APP PRODUCTS
      //////////////////////////////////////////////////////////

      if (_products.length < 20 &&
          _appProductsHasMore) {
        await _loadNextPage(
          loadAppProducts: true,
        );
      }

      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      //////////////////////////////////////////////////////////
      /// NOTHING AVAILABLE
      //////////////////////////////////////////////////////////

      if (_products.isEmpty) {
        setState(() {
          _error =
              "No products are currently available in this collection.";
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  //////////////////////////////////////////////////////////////
  /// LOAD NEXT PAGE
  //////////////////////////////////////////////////////////////

  Future<void> _loadNextPage({
    required bool loadAppProducts,
  }) async {
    if (_loadingMore) return;

    ////////////////////////////////////////////////////////////
    /// PAGINATION STATE
    ////////////////////////////////////////////////////////////

    if (loadAppProducts) {
      if (_appProductsLoaded &&
          !_appProductsHasMore) {
        return;
      }
    } else {
      if (_productsLoaded &&
          !_productsHasMore) {
        return;
      }
    }

    if (!mounted) return;

    setState(() {
      _loadingMore = true;
    });

    try {
      final result =
          await _productService.getProductsPage(
        categoryId: widget.category.id,
        loadAppProducts: loadAppProducts,
        startAfter: loadAppProducts
            ? _appProductsCursor
            : _productsCursor,
        limit: 20,
      );

      if (!mounted) return;

      //////////////////////////////////////////////////////////
      /// REMOVE DUPLICATES
      //////////////////////////////////////////////////////////

      final existingIds = _products
          .map(
            (item) =>
                _uniqueProductKey(item),
          )
          .toSet();

      final newProducts =
          result.products.where(
        (item) =>
            !existingIds.contains(
          _uniqueProductKey(item),
        ),
      );

      //////////////////////////////////////////////////////////
      /// ADD PRODUCTS IMMEDIATELY
      //////////////////////////////////////////////////////////

      setState(() {
        _products.addAll(
          newProducts,
        );

        if (loadAppProducts) {
          _appProductsLoaded = true;

          _appProductsCursor =
              result.lastDocument;

          _appProductsHasMore =
              result.hasMore;
        } else {
          _productsLoaded = true;

          _productsCursor =
              result.lastDocument;

          _productsHasMore =
              result.hasMore;
        }

        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingMore = false;
        _error = e.toString();
      });
    }
  }

  //////////////////////////////////////////////////////////////
  /// UNIQUE PRODUCT KEY
  //////////////////////////////////////////////////////////////

  String _uniqueProductKey(
    HomeProductModel item,
  ) {
    return "${item.source}_${item.collectionId}_${item.product.id}";
  }

  //////////////////////////////////////////////////////////////
  /// LOAD MORE
  //////////////////////////////////////////////////////////////

  Future<void> _checkLoadMore(
    int index,
  ) async {
    if (_loadingMore) return;

    ////////////////////////////////////////////////////////////
    /// LOAD WHEN 5 PRODUCTS ARE LEFT
    ////////////////////////////////////////////////////////////

    if (index >= _products.length - 5) {
      //////////////////////////////////////////////////////////
      /// CONTINUE PRODUCTS
      //////////////////////////////////////////////////////////

      if (_productsHasMore) {
        await _loadNextPage(
          loadAppProducts: false,
        );
      }

      //////////////////////////////////////////////////////////
      /// THEN APP PRODUCTS
      //////////////////////////////////////////////////////////

      if (!_productsHasMore &&
          _appProductsHasMore) {
        await _loadNextPage(
          loadAppProducts: true,
        );
      }
    }
  }

  //////////////////////////////////////////////////////////////
  /// PAGE CHANGE
  //////////////////////////////////////////////////////////////

  void _onPageChanged(
    int index,
  ) {
    if (!mounted) return;

    setState(() {
      _currentIndex = index;
    });

    _checkLoadMore(index);
  }

  //////////////////////////////////////////////////////////////
  /// NEXT
  //////////////////////////////////////////////////////////////

  void _next() {
    if (_currentIndex <
        _products.length - 1) {
      _pageController.nextPage(
        duration:
            const Duration(
          milliseconds: 280,
        ),
        curve: Curves.easeOut,
      );

      return;
    }

    _checkLoadMore(
      _currentIndex,
    );
  }

  //////////////////////////////////////////////////////////////
  /// PREVIOUS
  //////////////////////////////////////////////////////////////

  void _previous() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration:
            const Duration(
          milliseconds: 280,
        ),
        curve: Curves.easeOut,
      );
    }
  }

  //////////////////////////////////////////////////////////////
  /// ADD TO CART
  //////////////////////////////////////////////////////////////

  Future<void> _addToCart({
    required HomeProductModel item,
    required VariationModel? variation,
    required int quantity,
  }) async {
    try {
      //////////////////////////////////////////////////////////
      /// STOCK
      //////////////////////////////////////////////////////////

      final availableStock =
          variation?.quantity ??
              item.product.totalStock;

      if (availableStock <= 0) {
        _showMessage(
          "This product is currently out of stock.",
          isError: true,
        );

        return;
      }

      //////////////////////////////////////////////////////////
      /// QUANTITY VALIDATION
      //////////////////////////////////////////////////////////

      if (quantity <= 0) {
        _showMessage(
          "Please select a valid quantity.",
          isError: true,
        );

        return;
      }

      if (quantity > availableStock) {
        _showMessage(
          "Only $availableStock available.",
          isError: true,
        );

        return;
      }

      //////////////////////////////////////////////////////////
      /// CART SERVICE
      //////////////////////////////////////////////////////////

      await CartService.instance.addToCart(
        product: item,
        variation: variation,
        quantity: quantity,
      );

      if (!mounted) return;

      //////////////////////////////////////////////////////////
      /// SUCCESS
      //////////////////////////////////////////////////////////

      _showMessage(
        variation == null
            ? "${item.product.productName} × $quantity added to cart"
            : "${item.product.productName} • ${variation.label} × $quantity added to cart",
        isError: false,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst(
          "Exception: ",
          "",
        ),
        isError: true,
      );
    }
  }

  //////////////////////////////////////////////////////////////
  /// MESSAGE
  //////////////////////////////////////////////////////////////

  void _showMessage(
    String message, {
    required bool isError,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).hideCurrentSnackBar();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline
                  : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor:
            isError
                ? Colors.red.shade700
                : Colors.green.shade700,
        behavior:
            SnackBarBehavior.floating,
        margin:
            const EdgeInsets.all(16),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(14),
        ),
        duration:
            const Duration(
          seconds: 2,
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////////////
  /// BUILD
  //////////////////////////////////////////////////////////////

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          Colors.black,

      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  //////////////////////////////////////////////////////////////
  /// BODY
  //////////////////////////////////////////////////////////////

  Widget _buildBody() {
    ////////////////////////////////////////////////////////////
    /// INITIAL LOADING
    ////////////////////////////////////////////////////////////

    if (_loading &&
        _products.isEmpty) {
      return _buildInitialLoader();
    }

    ////////////////////////////////////////////////////////////
    /// EMPTY
    ////////////////////////////////////////////////////////////

    if (_products.isEmpty) {
      return _buildEmpty();
    }

    ////////////////////////////////////////////////////////////
    /// PRODUCTS
    ////////////////////////////////////////////////////////////

    return Stack(
      children: [
        ////////////////////////////////////////////////////////
        /// PRODUCT PAGE VIEW
        ////////////////////////////////////////////////////////

        PageView.builder(
          controller:
              _pageController,

          itemCount:
              _products.length,

          onPageChanged:
              _onPageChanged,

          physics:
              const BouncingScrollPhysics(),

          itemBuilder:
              (context, index) {
            final item =
                _products[index];

            return _StatusProductPage(
              key: ValueKey(
                _uniqueProductKey(item),
              ),
              item: item,

              onAddToCart:
                  ({
                    required variation,
                    required quantity,
                  }) {
                return _addToCart(
                  item: item,
                  variation: variation,
                  quantity: quantity,
                );
              },
            );
          },
        ),

        ////////////////////////////////////////////////////////
        /// TOP GRADIENT
        ////////////////////////////////////////////////////////

        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 145,

          child:
              IgnorePointer(
            child:
                DecoratedBox(
              decoration:
                  BoxDecoration(
                gradient:
                    LinearGradient(
                  begin:
                      Alignment.topCenter,
                  end:
                      Alignment.bottomCenter,
                  colors: [
                    Colors.black
                        .withOpacity(.78),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        ////////////////////////////////////////////////////////
        /// PROGRESS
        ////////////////////////////////////////////////////////

        Positioned(
          top: 10,
          left: 12,
          right: 12,

          child: Row(
            children:
                List.generate(
              _products.length,
              (index) {
                final completed =
                    index <
                        _currentIndex;

                final active =
                    index ==
                        _currentIndex;

                return Expanded(
                  child:
                      Container(
                    height: 3,
                    margin:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 2,
                    ),
                    decoration:
                        BoxDecoration(
                      borderRadius:
                          BorderRadius
                              .circular(
                        10,
                      ),
                      color:
                          completed ||
                                  active
                              ? Colors.white
                              : Colors.white
                                  .withOpacity(
                                  .35,
                                ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        ////////////////////////////////////////////////////////
        /// HEADER
        ////////////////////////////////////////////////////////

        Positioned(
          top: 25,
          left: 16,
          right: 12,

          child: Row(
            children: [
              //////////////////////////////////////////////////
              /// COLLECTION IMAGE
              //////////////////////////////////////////////////

              Container(
                width: 42,
                height: 42,

                decoration:
                    const BoxDecoration(
                  shape:
                      BoxShape.circle,
                  color:
                      Colors.white,
                ),

                padding:
                    const EdgeInsets
                        .all(2),

                child:
                    ClipOval(
                  child:
                      _NetworkImage(
                    url: widget
                        .category
                        .image,
                    fit:
                        BoxFit.cover,
                    icon:
                        Icons
                            .collections_outlined,
                  ),
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              //////////////////////////////////////////////////
              /// TITLE
              //////////////////////////////////////////////////

              Expanded(
                child: Text(
                  widget.category
                      .title,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),

              //////////////////////////////////////////////////
              /// LOADING MORE
              //////////////////////////////////////////////////

              if (_loadingMore)
                Container(
                  width: 24,
                  height: 24,
                  margin:
                      const EdgeInsets
                          .only(
                    right: 5,
                  ),
                  child:
                      const CircularProgressIndicator(
                    strokeWidth: 2,
                    color:
                        Colors.white,
                  ),
                ),

              //////////////////////////////////////////////////
              /// CLOSE
              //////////////////////////////////////////////////

              IconButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },
                icon:
                    const Icon(
                  Icons.close,
                  color:
                      Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),

        ////////////////////////////////////////////////////////
        /// LEFT TAP
        ////////////////////////////////////////////////////////

        Positioned(
          left: 0,
          top: 100,
          bottom: 150,
          width:
              MediaQuery.of(
                    context,
                  ).size.width *
                  .30,

          child:
              GestureDetector(
            behavior:
                HitTestBehavior
                    .translucent,
            onTap:
                _previous,
          ),
        ),

        ////////////////////////////////////////////////////////
        /// RIGHT TAP
        ////////////////////////////////////////////////////////

        Positioned(
          right: 0,
          top: 100,
          bottom: 150,
          width:
              MediaQuery.of(
                    context,
                  ).size.width *
                  .30,

          child:
              GestureDetector(
            behavior:
                HitTestBehavior
                    .translucent,
            onTap:
                _next,
          ),
        ),
      ],
    );
  }

  //////////////////////////////////////////////////////////////
  /// INITIAL LOADER
  //////////////////////////////////////////////////////////////

  Widget _buildInitialLoader() {
    return Container(
      decoration:
          const BoxDecoration(
        gradient:
            LinearGradient(
          begin:
              Alignment.topCenter,
          end:
              Alignment.bottomCenter,
          colors: [
            Color(0xff161616),
            Colors.black,
          ],
        ),
      ),

      child: Center(
        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            Container(
              width: 70,
              height: 70,

              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,
                color: Colors.white
                    .withOpacity(.08),
                border:
                    Border.all(
                  color: Colors.white
                      .withOpacity(.15),
                ),
              ),

              child:
                  const Padding(
                padding:
                    EdgeInsets.all(
                  21,
                ),
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              "Loading ${widget.category.title}",
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 7,
            ),

            const Text(
              "Getting products ready...",
              style:
                  TextStyle(
                color:
                    Colors.white54,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////////////
  /// EMPTY
  //////////////////////////////////////////////////////////////

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          30,
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment
                  .center,

          children: [
            const Icon(
              Icons
                  .inventory_2_outlined,
              color:
                  Colors.white70,
              size: 70,
            ),

            const SizedBox(
              height: 20,
            ),

            const Text(
              "No products available",
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                color:
                    Colors.white,
                fontSize: 20,
                fontWeight:
                    FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              _error ??
                  "This collection currently has no products in stock.",
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    Colors.white70,
                fontSize: 14,
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            OutlinedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },

              style:
                  OutlinedButton
                      .styleFrom(
                foregroundColor:
                    Colors.white,
                side:
                    const BorderSide(
                  color:
                      Colors.white54,
                ),
              ),

              child:
                  const Text(
                "Go Back",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////
/// PRODUCT PAGE
////////////////////////////////////////////////////////////////

class _StatusProductPage
    extends StatefulWidget {
  static const Color primary =
      Color(0xffE91E63);

  final HomeProductModel item;

  final Future<void> Function({
    required VariationModel? variation,
    required int quantity,
  }) onAddToCart;

  const _StatusProductPage({
    super.key,
    required this.item,
    required this.onAddToCart,
  });

  @override
  State<_StatusProductPage> createState() =>
      _StatusProductPageState();
}

class _StatusProductPageState
    extends State<_StatusProductPage> {
  static const Color primary =
      Color(0xffE91E63);

  VariationModel? _selectedVariation;

  int _quantity = 1;

  bool _addingToCart = false;
  bool _inCart = false;
  bool _updatingCartQuantity = false;

  //////////////////////////////////////////////////////////////
  /// PRODUCT
  //////////////////////////////////////////////////////////////

  HomeProductModel get item =>
      widget.item;

  //////////////////////////////////////////////////////////////
  /// AVAILABLE VARIATIONS
  //////////////////////////////////////////////////////////////

  List<VariationModel>
      get _availableVariations {
    return item.product.variations
        .where(
          (variation) =>
              variation.quantity > 0,
        )
        .toList();
  }

  //////////////////////////////////////////////////////////////
  /// CURRENT STOCK
  //////////////////////////////////////////////////////////////

  int get _currentStock {
    if (item.product.hasVariants) {
      return _selectedVariation
              ?.quantity ??
          0;
    }

    return item.product.totalStock;
  }

  //////////////////////////////////////////////////////////////
  /// INIT
  //////////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();

    ////////////////////////////////////////////////////////////
    /// SIMPLE PRODUCT
    ////////////////////////////////////////////////////////////

    if (!item.product.hasVariants) {
      _quantity = 1;
    }

    ////////////////////////////////////////////////////////////
    /// VARIANT PRODUCT
    ////////////////////////////////////////////////////////////

    else {
      final variations =
          _availableVariations;

      if (variations.length == 1) {
        _selectedVariation =
            variations.first;
      }
    }

    _restoreCartState();
  }

  Future<void> _restoreCartState() async {
    try {
      final items = await CartService.instance.cartStream().first;
      if (!mounted) return;

      final variationKey = _selectedVariation == null
          ? ""
          : "${_selectedVariation!.color}_${_selectedVariation!.size}";

      CartItemModel? existing;
      for (final cartItem in items) {
        if (cartItem.productId == item.product.id &&
            cartItem.subCollectionId == item.subCollection.id &&
            cartItem.variationKey == variationKey) {
          existing = cartItem;
          break;
        }
      }

      if (!mounted || existing == null) return;

      final safeQuantity = existing.quantity.clamp(
        1,
        _currentStock > 0 ? _currentStock : existing.quantity,
      ).toInt();

      setState(() {
        _quantity = safeQuantity;
        _inCart = true;
      });
    } catch (_) {
      // Cart restoration is optional; product viewer still works.
    }
  }

  //////////////////////////////////////////////////////////////
  /// CHANGE VARIATION
  //////////////////////////////////////////////////////////////

  Future<void> _selectVariation(
    VariationModel variation,
  ) async {
    setState(() {
      _selectedVariation = variation;
      _quantity = 1;
      _inCart = false;
    });

    await _restoreCartState();
  }

  //////////////////////////////////////////////////////////////
  /// DECREASE
  //////////////////////////////////////////////////////////////

  Future<CartItemModel?> _getCurrentCartItem() async {
    final items = await CartService.instance.cartStream().first;
    final variationKey = _selectedVariation == null
        ? ""
        : "${_selectedVariation!.color}_${_selectedVariation!.size}";

    for (final cartItem in items) {
      if (cartItem.productId == item.product.id &&
          cartItem.subCollectionId == item.subCollection.id &&
          cartItem.variationKey == variationKey) {
        return cartItem;
      }
    }
    return null;
  }

  Future<void> _decreaseQuantity() async {
    if (!_inCart || _quantity <= 0 || _updatingCartQuantity) return;

    final nextQuantity = _quantity - 1;
    setState(() => _updatingCartQuantity = true);

    try {
      final cartItem = await _getCurrentCartItem();
      if (cartItem == null) {
        if (mounted) setState(() { _quantity = 1; _inCart = false; });
        return;
      }

      await CartService.instance.updateQuantity(
        item: cartItem,
        quantity: nextQuantity,
      );

      if (!mounted) return;
      setState(() {
        if (nextQuantity <= 0) {
          _quantity = 1;
          _inCart = false;
        } else {
          _quantity = nextQuantity;
        }
      });
    } catch (e) {
      if (mounted) _showMessage(e.toString().replaceFirst("Exception: ", ""), isError: true);
    } finally {
      if (mounted) setState(() => _updatingCartQuantity = false);
    }
  }

  Future<void> _increaseQuantity() async {
    if (!_inCart || _currentStock <= 0 || _quantity >= _currentStock || _updatingCartQuantity) return;

    final nextQuantity = _quantity + 1;
    setState(() => _updatingCartQuantity = true);

    try {
      final cartItem = await _getCurrentCartItem();
      if (cartItem == null) {
        if (mounted) setState(() { _inCart = false; _quantity = 1; });
        return;
      }

      await CartService.instance.updateQuantity(
        item: cartItem,
        quantity: nextQuantity,
      );

      if (!mounted) return;
      setState(() => _quantity = nextQuantity);
    } catch (e) {
      if (mounted) _showMessage(e.toString().replaceFirst("Exception: ", ""), isError: true);
    } finally {
      if (mounted) setState(() => _updatingCartQuantity = false);
    }
  }

  //////////////////////////////////////////////////////////////
  /// ADD TO CART
  //////////////////////////////////////////////////////////////

  Future<void> _handleAddToCart() async {
    if (item.product.hasVariants && _selectedVariation == null) {
      _showMessage("Please select a variation.", isError: true);
      return;
    }

    if (_currentStock <= 0) {
      _showMessage("This product is currently out of stock.", isError: true);
      return;
    }

    setState(() => _addingToCart = true);

    try {
      // First tap always creates exactly one cart item.
      await widget.onAddToCart(
        variation: _selectedVariation,
        quantity: 1,
      );

      if (!mounted) return;
      setState(() {
        _quantity = 1;
        _inCart = true;
      });
    } catch (e) {
      if (mounted) {
        _showMessage(e.toString().replaceFirst("Exception: ", ""), isError: true);
      }
    } finally {
      if (mounted) setState(() => _addingToCart = false);
    }
  }

  //////////////////////////////////////////////////////////////
  /// MESSAGE
  //////////////////////////////////////////////////////////////

  void _showMessage(
    String message, {
    required bool isError,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).hideCurrentSnackBar();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline
                  : Icons.check_circle,
              color: Colors.white,
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        backgroundColor:
            isError
                ? Colors.red.shade700
                : Colors.green.shade700,

        behavior:
            SnackBarBehavior.floating,

        margin:
            const EdgeInsets.all(16),

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////////////
  /// BUILD
  //////////////////////////////////////////////////////////////

  @override
  Widget build(
    BuildContext context,
  ) {
    final product =
        item.product;

    final stock =
        product.hasVariants
            ? product.totalStock
            : product.totalStock;

    return Stack(
      fit: StackFit.expand,

      children: [
        ////////////////////////////////////////////////////////
        /// PRODUCT IMAGE
        ////////////////////////////////////////////////////////

        _ProductImage(
          url: product.image,
        ),

        ////////////////////////////////////////////////////////
        /// DARK GRADIENT
        ////////////////////////////////////////////////////////

        Container(
          decoration:
              BoxDecoration(
            gradient:
                LinearGradient(
              begin:
                  Alignment.topCenter,

              end:
                  Alignment.bottomCenter,

              colors: [
                Colors.transparent,
                Colors.black
                    .withOpacity(.08),
                Colors.black
                    .withOpacity(.92),
              ],

              stops: const [
                .20,
                .48,
                1,
              ],
            ),
          ),
        ),

        ////////////////////////////////////////////////////////
        /// PRODUCT INFORMATION
        ////////////////////////////////////////////////////////

        Positioned(
          left: 18,
          right: 18,
          bottom: 20,

          child: SafeArea(
            top: false,

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                //////////////////////////////////////////////////
                /// PRODUCT CODE
                //////////////////////////////////////////////////

                if (product
                    .productCode
                    .isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),

                    decoration:
                        BoxDecoration(
                      color: Colors.white
                          .withOpacity(
                        .16,
                      ),

                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),
                    ),

                    child:
                        Text(
                      product
                          .productCode,

                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),

                const SizedBox(
                  height: 9,
                ),

                //////////////////////////////////////////////////
                /// PRODUCT NAME
                //////////////////////////////////////////////////

                Text(
                  product
                      .productName,

                  maxLines: 2,

                  overflow:
                      TextOverflow
                          .ellipsis,

                  style:
                      const TextStyle(
                    color:
                        Colors.white,

                    fontSize: 24,

                    height: 1.12,

                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 7,
                ),

                //////////////////////////////////////////////////
                /// STOCK
                //////////////////////////////////////////////////

                Row(
                  children: [
                    const Icon(
                      Icons
                          .inventory_2_outlined,
                      color:
                          Colors.white70,
                      size: 17,
                    ),

                    const SizedBox(
                      width: 6,
                    ),

                    Text(
                      product.hasVariants
                          ? "$stock total available"
                          : "$stock available",

                      style:
                          const TextStyle(
                        color:
                            Colors.white70,
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                //////////////////////////////////////////////////
                /// VARIATIONS
                //////////////////////////////////////////////////

                if (product.hasVariants) ...[
                  const SizedBox(
                    height: 13,
                  ),

                  const Text(
                    "SELECT VARIATION",
                    style:
                        TextStyle(
                      color:
                          Colors.white,
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w900,
                      letterSpacing:
                          .7,
                    ),
                  ),

                  const SizedBox(
                    height: 7,
                  ),

                  if (_availableVariations
                      .isEmpty)
                    Container(
                      width:
                          double.infinity,

                      padding:
                          const EdgeInsets
                              .all(
                        12,
                      ),

                      decoration:
                          BoxDecoration(
                        color: Colors
                            .white
                            .withOpacity(
                          .10,
                        ),

                        borderRadius:
                            BorderRadius
                                .circular(
                          13,
                        ),
                      ),

                      child:
                          const Text(
                        "No variants available",
                        style:
                            TextStyle(
                          color:
                              Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection:
                          Axis.horizontal,

                      child: Row(
                        children:
                            _availableVariations
                                .map(
                          (
                            variation,
                          ) {
                            final selected =
                                _selectedVariation ==
                                    variation;

                            return Padding(
                              padding:
                                  const EdgeInsets
                                      .only(
                                right: 8,
                              ),

                              child:
                                  GestureDetector(
                                onTap: () {
                                  _selectVariation(
                                    variation,
                                  );
                                },

                                child:
                                    AnimatedContainer(
                                  duration:
                                      const Duration(
                                    milliseconds:
                                        180,
                                  ),

                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal:
                                        14,
                                    vertical:
                                        9,
                                  ),

                                  decoration:
                                      BoxDecoration(
                                    color:
                                        selected
                                            ? primary
                                            : Colors
                                                .white
                                                .withOpacity(
                                                .12,
                                              ),

                                    border:
                                        Border.all(
                                      color:
                                          selected
                                              ? Colors
                                                  .white
                                              : Colors
                                                  .white
                                                  .withOpacity(
                                                  .25,
                                                ),

                                      width:
                                          selected
                                              ? 1.7
                                              : 1,
                                    ),

                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      13,
                                    ),
                                  ),

                                  child:
                                      Column(
                                    mainAxisSize:
                                        MainAxisSize
                                            .min,

                                    children: [
                                      Text(
                                        variation
                                            .label,

                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.white,
                                          fontSize:
                                              12,
                                          fontWeight:
                                              FontWeight.w800,
                                        ),
                                      ),

                                      const SizedBox(
                                        height:
                                            2,
                                      ),

                                      Text(
                                        "${variation.quantity} left",

                                        style:
                                            TextStyle(
                                          color:
                                              Colors.white.withOpacity(
                                            .72,
                                          ),
                                          fontSize:
                                              9,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                ],

                //////////////////////////////////////////////////
                /// QUANTITY
                //////////////////////////////////////////////////

                const SizedBox(
                  height: 13,
                ),

                Row(
                  children: [
                    const Text(
                      "QUANTITY",
                      style:
                          TextStyle(
                        color:
                            Colors.white,
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w900,
                        letterSpacing:
                            .7,
                      ),
                    ),

                    const Spacer(),

                    Container(
                      height: 42,

                      decoration:
                          BoxDecoration(
                        color: Colors
                            .white
                            .withOpacity(
                          .12,
                        ),

                        borderRadius:
                            BorderRadius
                                .circular(
                          14,
                        ),

                        border:
                            Border.all(
                          color: Colors
                              .white
                              .withOpacity(
                            .20,
                          ),
                        ),
                      ),

                      child: Row(
                        children: [
                          //////////////////////////////////////////////////
                          /// MINUS
                          //////////////////////////////////////////////////

                          IconButton(
                            onPressed:
                                _quantity > 1
                                    ? _decreaseQuantity
                                    : null,

                            icon:
                                const Icon(
                              Icons.remove,
                              color:
                                  Colors.white,
                              size: 19,
                            ),

                            padding:
                                EdgeInsets.zero,

                            constraints:
                                const BoxConstraints(
                              minWidth: 42,
                            ),
                          ),

                          //////////////////////////////////////////////////
                          /// COUNT
                          //////////////////////////////////////////////////

                          SizedBox(
                            width: 32,

                            child: Text(
                              "$_quantity",

                              textAlign:
                                  TextAlign
                                      .center,

                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontSize:
                                    15,
                                fontWeight:
                                    FontWeight
                                        .w900,
                              ),
                            ),
                          ),

                          //////////////////////////////////////////////////
                          /// PLUS
                          //////////////////////////////////////////////////

                          IconButton(
                            onPressed:
                                _quantity <
                                        _currentStock
                                    ? _increaseQuantity
                                    : null,

                            icon:
                                const Icon(
                              Icons.add,
                              color:
                                  Colors.white,
                              size: 19,
                            ),

                            padding:
                                EdgeInsets.zero,

                            constraints:
                                const BoxConstraints(
                              minWidth: 42,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                //////////////////////////////////////////////////
                /// ADD TO CART / QUANTITY CONTROL
                //////////////////////////////////////////////////

                const SizedBox(height: 11),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: !_inCart
                        ? ElevatedButton(
                            key: const ValueKey("add_to_cart"),
                            onPressed: _addingToCart
                                ? null
                                : product.hasVariants && _selectedVariation == null
                                    ? null
                                    : _currentStock <= 0
                                        ? null
                                        : _handleAddToCart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              disabledBackgroundColor: Colors.grey.shade700,
                              foregroundColor: Colors.white,
                              elevation: 7,
                              shadowColor: Colors.black.withOpacity(.30),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _addingToCart
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.shopping_cart_outlined,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        product.hasVariants && _selectedVariation == null
                                            ? "SELECT VARIATION"
                                            : _currentStock <= 0
                                                ? "OUT OF STOCK"
                                                : "ADD TO CART",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: .3,
                                        ),
                                      ),
                                    ],
                                  ),
                          )
                        : Container(
                            key: const ValueKey("cart_quantity"),
                            decoration: BoxDecoration(
                              color: primary,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 58,
                                  height: 52,
                                  child: IconButton(
                                    onPressed: _updatingCartQuantity ? null : _decreaseQuantity,
                                    icon: Icon(
                                      Icons.remove_rounded,
                                      color: _updatingCartQuantity ? Colors.white38 : Colors.white,
                                      size: 23,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: _updatingCartQuantity
                                        ? const SizedBox(
                                            width: 19,
                                            height: 19,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            "$_quantity",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                  ),
                                ),
                                SizedBox(
                                  width: 58,
                                  height: 52,
                                  child: IconButton(
                                    onPressed: _updatingCartQuantity || _quantity >= _currentStock
                                        ? null
                                        : _increaseQuantity,
                                    icon: Icon(
                                      Icons.add_rounded,
                                      color: _updatingCartQuantity || _quantity >= _currentStock
                                          ? Colors.white38
                                          : Colors.white,
                                      size: 23,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                
                ),
              ],
            )
            
          ),
        ),
      ],
    );
  }
}

////////////////////////////////////////////////////////////////
/// NETWORK IMAGE
///
/// Gives every image a proper placeholder instead of showing
/// a black/empty area while Firebase Storage is loading.
////////////////////////////////////////////////////////////////

class _ProductImage
    extends StatelessWidget {
  final String url;

  const _ProductImage({
    required this.url,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return _NetworkImage(
      url: url,
      fit: BoxFit.cover,
      icon:
          Icons
              .image_not_supported_outlined,
    );
  }
}

////////////////////////////////////////////////////////////////
/// NETWORK IMAGE WIDGET
////////////////////////////////////////////////////////////////

class _NetworkImage
    extends StatelessWidget {
  final String url;

  final BoxFit fit;

  final IconData icon;

  const _NetworkImage({
    required this.url,
    required this.fit,
    required this.icon,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    if (url.trim().isEmpty) {
      return _placeholder();
    }

    return Image.network(
      url,

      fit: fit,

      width:
          double.infinity,

      height:
          double.infinity,

      //////////////////////////////////////////////////////////
      /// CACHE SIZE
      //////////////////////////////////////////////////////////

      cacheWidth:
          (MediaQuery.of(
                    context,
                  ).size.width *
                  MediaQuery.of(
                    context,
                  ).devicePixelRatio)
              .round(),

      //////////////////////////////////////////////////////////
      /// LOADING
      //////////////////////////////////////////////////////////

      loadingBuilder:
          (
        context,
        child,
        loadingProgress,
      ) {
        if (loadingProgress ==
            null) {
          return child;
        }

        return Stack(
          fit:
              StackFit.expand,

          children: [
            _placeholder(),

            Center(
              child:
                  Container(
                width: 46,
                height: 46,

                decoration:
                    BoxDecoration(
                  color: Colors.black
                      .withOpacity(
                    .30,
                  ),

                  shape:
                      BoxShape.circle,
                ),

                padding:
                    const EdgeInsets
                        .all(
                  13,
                ),

                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,

                  color:
                      Colors.white,

                  value: loadingProgress
                              .expectedTotalBytes !=
                          null
                      ? loadingProgress
                              .cumulativeBytesLoaded /
                          loadingProgress
                              .expectedTotalBytes!
                      : null,
                ),
              ),
            ),
          ],
        );
      },

      //////////////////////////////////////////////////////////
      /// ERROR
      //////////////////////////////////////////////////////////

      errorBuilder:
          (
        context,
        error,
        stackTrace,
      ) {
        return _placeholder(
          showErrorIcon: true,
        );
      },

      //////////////////////////////////////////////////////////
      /// FADE IN
      //////////////////////////////////////////////////////////

      frameBuilder:
          (
        context,
        child,
        frame,
        wasSynchronouslyLoaded,
      ) {
        if (wasSynchronouslyLoaded) {
          return child;
        }

        return AnimatedOpacity(
          opacity:
              frame == null
                  ? 0
                  : 1,

          duration:
              const Duration(
            milliseconds: 300,
          ),

          curve:
              Curves.easeOut,

          child:
              child,
        );
      },
    );
  }

  //////////////////////////////////////////////////////////////
  /// PLACEHOLDER
  //////////////////////////////////////////////////////////////

  Widget _placeholder({
    bool showErrorIcon = false,
  }) {
    return Container(
      color:
          const Color(0xff151515),

      child: Center(
        child:
            Container(
          width: 72,
          height: 72,

          decoration:
              BoxDecoration(
            color: Colors.white
                .withOpacity(
              .06,
            ),

            shape:
                BoxShape.circle,

            border:
                Border.all(
              color: Colors.white
                  .withOpacity(
                .08,
              ),
            ),
          ),

          child:
              Icon(
            showErrorIcon
                ? icon
                : Icons
                    .image_outlined,

            color:
                Colors.white24,

            size: 32,
          ),
        ),
      ),
    );
  }
}