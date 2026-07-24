import 'dart:async';

import 'package:flutter/material.dart';

import '../models/cart_item_model.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService.instance;

  StreamSubscription<List<CartItemModel>>? _subscription;

  List<CartItemModel> _items = [];

  bool _loading = true;

  String? _error;

  List<CartItemModel> get items => _items;

  bool get isLoading => _loading;

  String? get error => _error;

  int get totalItems => _items.fold(
        0,
        (sum, item) => sum + item.quantity,
      );

  double get totalPrice => _items.fold(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );

  bool get isEmpty => _items.isEmpty;

  bool get hasItems => _items.isNotEmpty;

  CartProvider() {
    _listenCart();
  }

  void _listenCart() {
    _loading = true;
    notifyListeners();

    _subscription = _cartService.cartStream().listen(
      (cart) {
        _items = cart;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _loading = false;
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  Future<void> refresh() async {
    await _subscription?.cancel();
    _listenCart();
  }

  Future<void> clearCart() async {
    await _cartService.clearCart();
  }

  Future<void> removeItem(String id) async {
    await _cartService.removeItem(id);
  }

  /// ===============================
  /// Quantity Helpers
  /// ===============================

  Future<void> increaseQuantity({
    required CartItemModel item,
  }) async {
    await _cartService.increaseQuantity(
      item: item,
    );
  }

  Future<void> decreaseQuantity({
    required CartItemModel item,
  }) async {
    await _cartService.decreaseQuantity(
      item: item,
    );
  }

  Future<void> updateQuantity({
    required CartItemModel item,
    required int quantity,
  }) async {
    await _cartService.updateQuantity(
      item: item,
      quantity: quantity,
    );
  }

  CartItemModel? findItem(
    String productId,
    String subCollectionId,
    String variationKey,
  ) {
    try {
      return _items.firstWhere(
        (item) =>
            item.productId == productId &&
            item.subCollectionId == subCollectionId &&
            item.variationKey == variationKey,
      );
    } catch (_) {
      return null;
    }
  }

  bool isInCart({
    required String productId,
    required String subCollectionId,
    required String variationKey,
  }) {
    return findItem(
          productId,
          subCollectionId,
          variationKey,
        ) !=
        null;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}