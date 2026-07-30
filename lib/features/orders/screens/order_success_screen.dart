import 'package:flutter/material.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xffE91E63);

    return Scaffold(
      backgroundColor: const Color(0xffF8F9FB),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            children: [

              const Spacer(),

              /////////////////////////////////////////////////////
              /// Success Circle
              /////////////////////////////////////////////////////

              TweenAnimationBuilder<double>(
                tween: Tween(
                  begin: 0,
                  end: 1,
                ),
                duration: const Duration(
                  milliseconds: 700,
                ),
                curve: Curves.elasticOut,
                builder: (_, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },

                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.shade50,
                    border: Border.all(
                      color: Colors.green.shade200,
                      width: 2,
                    ),
                  ),

                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 90,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                "Order Placed Successfully!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "Thank you for shopping with us.\nYour order has been received successfully.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 35),

              /////////////////////////////////////////////////////
              /// Order Card
              /////////////////////////////////////////////////////

              Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(24),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.05),
                      blurRadius: 18,
                    )
                  ],
                ),

                child: Column(
                  children: [

                    _row(
                      "Order ID",
                      orderId,
                    ),

                    const Divider(height: 30),

                    _row(
                      "Payment",
                      "Pending",
                    ),

                    const Divider(height: 30),

                    _row(
                      "Delivery",
                      "3 - 5 Business Days",
                    ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                  ),

                  onPressed: () {

                    Navigator.popUntil(
                      context,
                      (route) => route.isFirst,
                    );

                  },

                  child: const Text(
                    "Continue Shopping",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 56,

                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: primary,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                  ),

                  onPressed: () {

                    // TODO
                    // Navigate Orders

                  },

                  child: const Text(
                    "View My Orders",
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _row(
    String title,
    String value,
  ) {
    return Row(
      children: [

        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ),

        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}