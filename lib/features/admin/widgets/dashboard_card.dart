import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final Widget child;

  final EdgeInsetsGeometry? padding;

  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 250),

      padding:
          padding ?? const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(24),

        border: Border.all(
          color: const Color(0xffF3E5EC),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: child,
    );

    if (onTap == null) {
      return card;
    }

    return InkWell(
      borderRadius:
          BorderRadius.circular(24),
      onTap: onTap,
      child: card,
    );
  }
}