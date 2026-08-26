import 'package:flutter/material.dart';

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
  static const Color primary = Color(0xffE91E63);

 
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
      setState(() {
        _loading = true;
        _error = null;
      });

      //////////////////////////////////////////////////////////
      /// FIRST 20 FROM PRODUCTS
      //////////////////////////////////////////////////////////

      await _loadNextPage(
        loadAppProducts: false,
      );

      //////////////////////////////////////////////////////////
      /// IF LESS THAN 20
      /// ALSO CHECK APP PRODUCTS
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
  /// LOAD NEXT 20
  //////////////////////////////////////////////////////////////

  Future<void> _loadNextPage({
    required bool loadAppProducts,
  }) async {
    if (_loadingMore) return;

    ////////////////////////////////////////////////////////////
    /// CHECK PAGINATION STATE
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

        loadAppProducts:
            loadAppProducts,

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
      /// UPDATE
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
  /// LOAD MORE NEAR END
  //////////////////////////////////////////////////////////////

  Future<void> _checkLoadMore(
    int index,
  ) async {
    if (_loadingMore) return;

    ////////////////////////////////////////////////////////////
    /// WHEN 5 PRODUCTS ARE LEFT
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

  Future<void> _addToCart(
    HomeProductModel item,
  ) async {
    final product =
        item.product;

    ////////////////////////////////////////////////////////////
    /// SIMPLE PRODUCT
    ////////////////////////////////////////////////////////////

    if (!product.hasVariants) {
      await _addProductToCart(
        item: item,
        variation: null,
      );

      return;
    }

    ////////////////////////////////////////////////////////////
    /// VARIANT PRODUCT
    ////////////////////////////////////////////////////////////

    final selectedVariation =
        await _showVariationSelector(
      item,
    );

    if (selectedVariation == null) {
      return;
    }

    await _addProductToCart(
      item: item,
      variation: selectedVariation,
    );
  }

  //////////////////////////////////////////////////////////////
  /// ACTUAL ADD TO CART
  //////////////////////////////////////////////////////////////

  Future<void> _addProductToCart({
    required HomeProductModel item,
    required VariationModel? variation,
  }) async {
    try {
      //////////////////////////////////////////////////////////
      /// STOCK CHECK
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
      /// REAL CART SERVICE
      //////////////////////////////////////////////////////////

      await CartService.instance.addToCart(
        product: item,
        variation: variation,
        quantity: 1,
      );

      if (!mounted) return;

      //////////////////////////////////////////////////////////
      /// SUCCESS
      //////////////////////////////////////////////////////////

      _showMessage(
        variation == null
            ? "${item.product.productName} added to cart"
            : "${item.product.productName} • ${variation.label} added to cart",
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
  /// VARIATION SELECTOR
  //////////////////////////////////////////////////////////////

  Future<VariationModel?>
      _showVariationSelector(
    HomeProductModel item,
  ) async {
    final variations =
        item.product.variations
            .where(
              (variation) =>
                  variation.quantity > 0,
            )
            .toList();

    ////////////////////////////////////////////////////////////
    /// NO AVAILABLE VARIATIONS
    ////////////////////////////////////////////////////////////

    if (variations.isEmpty) {
      _showMessage(
        "No variants are currently available.",
        isError: true,
      );

      return null;
    }

    return showModalBottomSheet<
        VariationModel>(
      context: context,

      backgroundColor:
          Colors.transparent,

      isScrollControlled: true,

      builder: (context) {
        VariationModel?
            selectedVariation;

        return StatefulBuilder(
          builder:
              (
            context,
            setModalState,
          ) {
            return Container(
              decoration:
                  const BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.vertical(
                  top: Radius.circular(
                    28,
                  ),
                ),
              ),

              padding:
                  const EdgeInsets.fromLTRB(
                20,
                14,
                20,
                25,
              ),

              child: SafeArea(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,

                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    //////////////////////////////////////////////////
                    /// HANDLE
                    //////////////////////////////////////////////////

                    Center(
                      child: Container(
                        width: 45,
                        height: 5,

                        decoration:
                            BoxDecoration(
                          color: Colors
                              .grey
                              .shade300,

                          borderRadius:
                              BorderRadius
                                  .circular(
                            20,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    //////////////////////////////////////////////////
                    /// TITLE
                    //////////////////////////////////////////////////

                    const Text(
                      "Select Variant",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      item.product
                          .productName,

                      maxLines: 1,

                      overflow:
                          TextOverflow
                              .ellipsis,

                      style: TextStyle(
                        color: Colors
                            .grey
                            .shade600,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    //////////////////////////////////////////////////
                    /// VARIATIONS
                    //////////////////////////////////////////////////

                    ConstrainedBox(
                      constraints:
                          BoxConstraints(
                        maxHeight:
                            MediaQuery.of(
                          context,
                        ).size.height *
                            .45,
                      ),

                      child:
                          SingleChildScrollView(
                        child:
                            Wrap(
                          spacing: 10,
                          runSpacing: 10,

                          children:
                              variations.map(
                            (
                              variation,
                            ) {
                              final selected =
                                  selectedVariation ==
                                      variation;

                              return GestureDetector(
                                onTap: () {
                                  setModalState(
                                    () {
                                      selectedVariation =
                                          variation;
                                    },
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
                                        15,
                                    vertical:
                                        12,
                                  ),

                                  decoration:
                                      BoxDecoration(
                                    color: selected
                                        ? primary
                                            .withOpacity(
                                            .08,
                                          )
                                        : Colors
                                            .white,

                                    border:
                                        Border.all(
                                      color:
                                          selected
                                              ? primary
                                              : Colors
                                                  .grey
                                                  .shade300,

                                      width:
                                          selected
                                              ? 2
                                              : 1,
                                    ),

                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      15,
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
                                            TextStyle(
                                          color:
                                              selected
                                                  ? primary
                                                  : Colors
                                                      .black87,

                                          fontWeight:
                                              FontWeight
                                                  .w800,
                                        ),
                                      ),

                                      const SizedBox(
                                        height:
                                            4,
                                      ),

                                      Text(
                                        "${variation.quantity} available",

                                        style:
                                            TextStyle(
                                          fontSize:
                                              11,

                                          color: Colors
                                              .grey
                                              .shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    //////////////////////////////////////////////////
                    /// ADD BUTTON
                    //////////////////////////////////////////////////

                    SizedBox(
                      width:
                          double.infinity,

                      height: 54,

                      child:
                          ElevatedButton(
                        onPressed:
                            selectedVariation ==
                                    null
                                ? null
                                : () {
                                    Navigator.pop(
                                      context,
                                      selectedVariation,
                                    );
                                  },

                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              primary,

                          disabledBackgroundColor:
                              Colors.grey
                                  .shade300,

                          foregroundColor:
                              Colors.white,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              16,
                            ),
                          ),
                        ),

                        child:
                            const Text(
                          "ADD TO CART",
                          style:
                              TextStyle(
                            fontWeight:
                                FontWeight.w900,
                            fontSize:
                                15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
    if (_loading) {
      return const Center(
        child:
            CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    if (_products.isEmpty) {
      return _buildEmpty();
    }

    return Stack(
      children: [
        //////////////////////////////////////////////////////////
        /// PRODUCTS
        //////////////////////////////////////////////////////////

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
            return _StatusProductPage(
              item:
                  _products[index],

              onAddToCart:
                  () => _addToCart(
                _products[index],
              ),
            );
          },
        ),

        //////////////////////////////////////////////////////////
        /// TOP GRADIENT
        //////////////////////////////////////////////////////////

        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 130,

          child: IgnorePointer(
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
                        .withOpacity(
                      .75,
                    ),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        //////////////////////////////////////////////////////////
        /// PROGRESS
        //////////////////////////////////////////////////////////

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
                              ? Colors
                                  .white
                              : Colors
                                  .white
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

        //////////////////////////////////////////////////////////
        /// HEADER
        //////////////////////////////////////////////////////////

        Positioned(
          top: 25,
          left: 16,
          right: 12,

          child: Row(
            children: [
              ////////////////////////////////////////////////////
              /// COLLECTION IMAGE
              ////////////////////////////////////////////////////

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
                      Image.network(
                    widget.category
                        .image,

                    fit:
                        BoxFit.cover,

                    errorBuilder:
                        (
                      _,
                      __,
                      ___,
                    ) {
                      return const Icon(
                        Icons
                            .collections_outlined,
                        size: 22,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              ////////////////////////////////////////////////////
              /// TITLE
              ////////////////////////////////////////////////////

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

              ////////////////////////////////////////////////////
              /// CLOSE
              ////////////////////////////////////////////////////

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

        //////////////////////////////////////////////////////////
        /// LEFT TAP
        //////////////////////////////////////////////////////////

        Positioned(
          left: 0,
          top: 100,
          bottom: 130,

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

        //////////////////////////////////////////////////////////
        /// RIGHT TAP
        //////////////////////////////////////////////////////////

        Positioned(
          right: 0,
          top: 100,
          bottom: 130,

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

        //////////////////////////////////////////////////////////
        /// LOADING NEXT
        //////////////////////////////////////////////////////////

        if (_loadingMore)
          Positioned(
            top: 62,
            right: 18,

            child:
                Container(
              width: 22,
              height: 22,

              padding:
                  const EdgeInsets
                      .all(3),

              decoration:
                  BoxDecoration(
                color:
                    Colors.black
                        .withOpacity(
                  .45,
                ),

                shape:
                    BoxShape.circle,
              ),

              child:
                  const CircularProgressIndicator(
                strokeWidth: 2,

                color:
                    Colors.white,
              ),
            ),
          ),
      ],
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

              style: TextStyle(
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

///////////////////////////////////////////////////////////////
/// PRODUCT PAGE
///////////////////////////////////////////////////////////////

class _StatusProductPage
    extends StatelessWidget {
          static const Color primary =
      Color(0xffE91E63);
  final HomeProductModel item;

  final VoidCallback
      onAddToCart;

  const _StatusProductPage({
    required this.item,
    required this.onAddToCart,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final product =
        item.product;

    final stock =
        product.totalStock;

    final hasVariants =
        product.hasVariants;

    return Stack(
      fit: StackFit.expand,

      children: [
        /////////////////////////////////////////////////////////
        /// IMAGE
        /////////////////////////////////////////////////////////

        Image.network(
          product.image,

          fit:
              BoxFit.cover,

          errorBuilder:
              (_, __, ___) {
            return Container(
              color:
                  Colors.grey.shade900,

              child:
                  const Center(
                child: Icon(
                  Icons
                      .image_not_supported_outlined,

                  color:
                      Colors.white54,

                  size: 70,
                ),
              ),
            );
          },
        ),

        /////////////////////////////////////////////////////////
        /// DARK GRADIENT
        /////////////////////////////////////////////////////////

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
                    .withOpacity(.10),

                Colors.black
                    .withOpacity(.90),
              ],

              stops: const [
                .25,
                .52,
                1,
              ],
            ),
          ),
        ),

        /////////////////////////////////////////////////////////
        /// PRODUCT INFORMATION
        /////////////////////////////////////////////////////////

        Positioned(
          left: 20,
          right: 20,
          bottom: 25,

          child:
              Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,

            children: [
              ///////////////////////////////////////////////////
              /// PRODUCT CODE
              ///////////////////////////////////////////////////

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
                    color: Colors
                        .white
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

                      fontSize:
                          11,

                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),

              const SizedBox(
                height: 10,
              ),

              ///////////////////////////////////////////////////
              /// PRODUCT NAME
              ///////////////////////////////////////////////////

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

                  fontSize: 25,

                  height: 1.15,

                  fontWeight:
                      FontWeight.w900,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              ///////////////////////////////////////////////////
              /// STOCK
              ///////////////////////////////////////////////////

              Row(
                children: [
                  const Icon(
                    Icons
                        .inventory_2_outlined,

                    color:
                        Colors.white70,

                    size: 18,
                  ),

                  const SizedBox(
                    width: 6,
                  ),

                  Text(
                    hasVariants
                        ? "$stock total available"
                        : "$stock available",

                    style:
                        const TextStyle(
                      color:
                          Colors.white70,

                      fontSize: 14,

                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 18,
              ),

              ///////////////////////////////////////////////////
              /// ADD TO CART
              ///////////////////////////////////////////////////

              SizedBox(
                width:
                    double.infinity,

                height: 55,

                child:
                    ElevatedButton
                        .icon(
                  onPressed:
                      stock > 0
                          ? onAddToCart
                          : null,

                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        primary,

                    disabledBackgroundColor:
                        Colors.grey
                            .shade700,

                    foregroundColor:
                        Colors.white,

                    elevation: 8,

                    shadowColor:
                        Colors.black
                            .withOpacity(
                      .35,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        17,
                      ),
                    ),
                  ),

                  icon:
                      const Icon(
                    Icons
                        .shopping_cart_outlined,
                  ),

                  label:
                      Text(
                    stock > 0
                        ? "ADD TO CART"
                        : "OUT OF STOCK",

                    style:
                        const TextStyle(
                      fontSize: 15,

                      fontWeight:
                          FontWeight.w900,

                      letterSpacing:
                          .4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}