import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/cart_provider.dart';
import '../widgets/cart_bottom_bar.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/empty_cart.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Scaffold(
          backgroundColor: const Color(0xffF8F9FB),

          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            title: Text(
              "My Cart (${cart.totalItems})",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              if (cart.hasItems)
                IconButton(
                  tooltip: "Clear Cart",
                  icon: const Icon(Icons.delete_sweep_outlined),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Clear Cart?"),
                        content: const Text(
                          "Remove all items from your cart?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          FilledButton(
                            onPressed: () =>
                                Navigator.pop(context, true),
                            child: const Text("Clear"),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await cart.clearCart();
                    }
                  },
                ),
            ],
          ),

          body: Builder(
            builder: (_) {
              if (cart.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (cart.error != null) {
                return Center(
                  child: Text(cart.error!),
                );
              }

              if (cart.isEmpty) {
                return const EmptyCart();
              }

              return RefreshIndicator(
                onRefresh: cart.refresh,
                child: ListView.builder(
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 120,
                  ),
                  itemCount: cart.items.length,
                  itemBuilder: (_, index) {
                    return CartItemCard(
                      item: cart.items[index],
                    );
                  },
                ),
              );
            },
          ),

          bottomNavigationBar: cart.hasItems
              ? CartBottomBar(
                  totalItems: cart.totalItems,
                  totalPrice: cart.totalPrice,
                  onCheckout: () {
                    // TODO:
                    // Navigate to Checkout Screen
                  },
                )
              : null,
        );
      },
    );
  }
}