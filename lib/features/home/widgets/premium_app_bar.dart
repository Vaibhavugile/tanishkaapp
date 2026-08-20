import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../../providers/cart_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
class PremiumAppBar extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onCartTap;

  final int wishlistCount;
Future<void> _signOut(BuildContext context) async {
  final shouldSignOut = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Sign Out?",
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        content: const Text(
          "Are you sure you want to sign out?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor:
                  const Color(0xffD81B78),
            ),
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text("Sign Out"),
          ),
        ],
      );
    },
  );

  if (shouldSignOut != true) {
    return;
  }

  try {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    // Remove all previous screens and go to login.
   Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(
    builder: (_) => const LoginScreen(),
  ),
  (route) => false,
);
  } catch (e) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        content: Text(
          "Unable to sign out: $e",
        ),
      ),
    );
  }
}
  const PremiumAppBar({
    super.key,
    this.onMenuTap,
    this.onWishlistTap,
    this.onCartTap,
    this.wishlistCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(36),
        bottomRight: Radius.circular(36),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            18,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.88),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(36),
              bottomRight: Radius.circular(36),
            ),
            border: Border.all(
              color: Colors.white.withOpacity(.5),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xffD81B78)
                    .withOpacity(.10),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Hero(
                      tag: "logo",
                      child: Image.asset(
                        "assets/logos/logo.png",
                        height: 82,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                _LuxuryBadgeIcon(
                  icon: Icons.favorite_rounded,
                  count: wishlistCount,
                  onTap: onWishlistTap,
                ),

                const SizedBox(width: 10),

                Consumer<CartProvider>(
                  builder: (
                    context,
                    cart,
                    child,
                  ) {
                    return _LuxuryBadgeIcon(
                      icon: Icons.shopping_bag_rounded,
                      count: cart.totalItems,
                      onTap: onCartTap,
                    );
                  },
                ),

                const SizedBox(width: 10),

                _LuxuryIcon(
  icon: Icons.logout_rounded,
  onTap: () => _signOut(context),
),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LuxuryIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _LuxuryIcon({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(18),
            color: Colors.white,
            border: Border.all(
              color: const Color(0xffF8D8E7),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xffD81B78)
                    .withOpacity(.08),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 22,
            color: const Color(0xffD81B78),
          ),
        ),
      ),
    );
  }
}

class _LuxuryBadgeIcon extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback? onTap;

  const _LuxuryBadgeIcon({
    required this.icon,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _LuxuryIcon(
          icon: icon,
          onTap: onTap,
        ),

        AnimatedSwitcher(
          duration: const Duration(
            milliseconds: 250,
          ),
          transitionBuilder:
              (child, animation) {
            return ScaleTransition(
              scale: animation,
              child: child,
            );
          },
          child: count == 0
              ? const SizedBox.shrink()
              : Positioned(
                  key: ValueKey(count),
                  right: -3,
                  top: -3,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(
                        0xffD81B78,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      count > 99
                          ? "99+"
                          : "$count",
                      style:
                          const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}