import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/cart_provider.dart';
import '../widgets/cart_bottom_bar.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/empty_cart.dart';
import '../../checkout/screens/checkout_screen.dart';
import '../../home/home_screen.dart';
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Scaffold(
          backgroundColor: const Color(0xffFFF8FB),

          body: Stack(
            children: [
              /// Background
              Positioned(
                top: -120,
                right: -100,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(
                      0xffF8BBD0,
                    ).withOpacity(.25),
                  ),
                ),
              ),

              Positioned(
                bottom: -140,
                left: -120,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(
                      0xffFCE4EC,
                    ).withOpacity(.9),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    /// ==========================
                    /// Premium Header
                    /// ==========================

                    Container(
  margin: const EdgeInsets.fromLTRB(
    12,
    8,
    12,
    8,
  ),

  padding: const EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 10,
  ),

  decoration: BoxDecoration(
    color: Colors.white.withOpacity(.94),

    borderRadius: BorderRadius.circular(18),

    border: Border.all(
      color: Colors.white,
    ),

    boxShadow: [
      BoxShadow(
        color: const Color(
          0xffD81B78,
        ).withOpacity(.07),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  ),

  child: Row(
    children: [
      //////////////////////////////////////////////////////
      /// BACK BUTTON
      //////////////////////////////////////////////////////

      InkWell(
        borderRadius:
            BorderRadius.circular(12),

        onTap: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const HomeScreen(),
            ),
            (route) => false,
          );
        },

        child: Container(
          width: 38,
          height: 38,

          decoration: BoxDecoration(
            color: const Color(
              0xffFCE4EC,
            ),

            borderRadius:
                BorderRadius.circular(12),
          ),

          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(
              0xffD81B78,
            ),
            size: 17,
          ),
        ),
      ),

      const SizedBox(width: 11),

      //////////////////////////////////////////////////////
      /// TITLE + ITEM COUNT
      //////////////////////////////////////////////////////

      Expanded(
        child: Row(
          children: [
            const Text(
              "My Cart",

              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(
                  0xff222222,
                ),
                height: 1,
              ),
            ),

            const SizedBox(width: 8),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),

              decoration: BoxDecoration(
                color: const Color(
                  0xffFCE4EC,
                ),

                borderRadius:
                    BorderRadius.circular(20),
              ),

              child: Text(
                "${cart.totalItems}",

                style: const TextStyle(
                  color: Color(
                    0xffD81B78,
                  ),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),

      //////////////////////////////////////////////////////
      /// CLEAR CART
      //////////////////////////////////////////////////////

      if (cart.hasItems)
        InkWell(
          borderRadius:
              BorderRadius.circular(11),

          onTap: () async {
            final confirm =
                await showDialog<bool>(
              context: context,
              builder: (_) =>
                  AlertDialog(
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),

                title: const Text(
                  "Clear Cart?",
                ),

                content: const Text(
                  "Remove all items from your cart?",
                ),

                actions: [
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(
                      context,
                      false,
                    ),
                    child: const Text(
                      "Cancel",
                    ),
                  ),

                  FilledButton(
                    style:
                        FilledButton.styleFrom(
                      backgroundColor:
                          const Color(
                        0xffD81B78,
                      ),
                    ),

                    onPressed: () =>
                        Navigator.pop(
                      context,
                      true,
                    ),

                    child: const Text(
                      "Clear",
                    ),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              await cart.clearCart();
            }
          },

          child: Container(
            width: 38,
            height: 38,

            decoration: BoxDecoration(
              color: const Color(
                0xffFFF1F5,
              ),

              borderRadius:
                  BorderRadius.circular(11),
            ),

            child: const Icon(
              Icons.delete_sweep_outlined,
              color: Color(
                0xffD81B78,
              ),
              size: 20,
            ),
          ),
        ),
    ],
  ),
),
                    /// ==========================
                    /// Body
                    /// ==========================

                    Expanded(
                      child: Builder(
                        builder: (_) {
                          if (cart.isLoading) {
                            return const Center(
                              child:
                                  CircularProgressIndicator(
                                color: Color(
                                  0xffD81B78,
                                ),
                              ),
                            );
                          }

                          if (cart.error !=
                              null) {
                            return Center(
                              child: Text(
                                cart.error!,
                              ),
                            );
                          }

                          if (cart.isEmpty) {
                            return const EmptyCart();
                          }

                          return RefreshIndicator(
                            color: const Color(
                              0xffD81B78,
                            ),
                            onRefresh:
                                cart.refresh,
                            child:
                                ListView.builder(
                              physics:
                                  const BouncingScrollPhysics(),
                              padding:
                                  const EdgeInsets
                                      .only(
                                bottom: 140,
                                top: 6,
                              ),
                              itemCount:
                                  cart.items.length,
                              itemBuilder:
                                  (_, index) {
                                return CartItemCard(
                                  item: cart
                                      .items[index],
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          bottomNavigationBar: cart.hasItems
              ? CartBottomBar(
                  totalItems:
                      cart.totalItems,
                  totalPrice:
                      cart.totalPrice,
                  onCheckout: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const CheckoutScreen(),
    ),
  );
},
                )
              : null,
        );
      },
    );
  }
}