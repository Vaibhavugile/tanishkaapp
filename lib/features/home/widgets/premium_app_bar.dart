import 'dart:ui';
import 'package:flutter/material.dart';

class PremiumAppBar extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onCartTap;

  final int wishlistCount;
  final int cartCount;

  const PremiumAppBar({
    super.key,
    this.onMenuTap,
    this.onWishlistTap,
    this.onCartTap,
    this.wishlistCount = 0,
    this.cartCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(36),
        bottomRight: Radius.circular(36),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
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
                color: const Color(0xffD81B78).withOpacity(.10),
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

    _LuxuryBadgeIcon(
      icon: Icons.shopping_bag_rounded,
      count: cartCount,
      onTap: onCartTap,
    ),

    const SizedBox(width: 10),

    _LuxuryIcon(
      icon: Icons.grid_view_rounded,
      onTap: onMenuTap,
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
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white,
            border: Border.all(
              color: const Color(0xffF8D8E7),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xffD81B78).withOpacity(.08),
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
        if (count > 0)
          Positioned(
            right: -3,
            top: -3,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xffD81B78),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                count > 99 ? "99" : "$count",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}