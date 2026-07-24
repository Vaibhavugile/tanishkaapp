import 'package:flutter/material.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;

  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  final bool enabled;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xffE91E63);

    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _button(
            icon: Icons.remove,
            onTap: enabled ? onDecrease : null,
          ),

          Container(
            constraints: const BoxConstraints(
              minWidth: 42,
            ),
            alignment: Alignment.center,
            child: Text(
              quantity.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),

          _button(
            icon: Icons.add,
            onTap: enabled ? onIncrease : null,
          ),
        ],
      ),
    );
  }

  Widget _button({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 20,
          color: onTap == null
              ? Colors.grey
              : const Color(0xffE91E63),
        ),
      ),
    );
  }
}