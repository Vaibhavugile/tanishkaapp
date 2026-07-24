import 'package:flutter/material.dart';

class EmptyCart extends StatelessWidget {
  final VoidCallback? onContinueShopping;

  const EmptyCart({
    super.key,
    this.onContinueShopping,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xffFFF1F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 70,
                color: Color(0xffE91E63),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Your cart is empty",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Looks like you haven't added\nanything yet.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 35),

            SizedBox(
              width: 220,
              height: 52,
              child: ElevatedButton(
                onPressed: onContinueShopping,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffE91E63),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  "Continue Shopping",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}