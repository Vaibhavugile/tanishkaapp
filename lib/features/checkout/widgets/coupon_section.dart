import 'package:flutter/material.dart';

class CouponSection extends StatelessWidget {
  final String? appliedCoupon;
  final VoidCallback onApply;

  const CouponSection({
    super.key,
    this.appliedCoupon,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xffE91E63);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          const Row(
            children: [

              Icon(
                Icons.local_offer_rounded,
                color: primary,
              ),

              SizedBox(width: 10),

              Text(
                "Coupons & Offers",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          InkWell(
            borderRadius:
                BorderRadius.circular(18),
            onTap: onApply,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [

                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color:
                          primary.withOpacity(.1),
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                    child: const Icon(
                      Icons.sell_rounded,
                      color: primary,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Text(
                          appliedCoupon == null
                              ? "Apply Coupon"
                              : appliedCoupon!,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          appliedCoupon == null
                              ? "Tap to view available coupons"
                              : "Coupon applied successfully",
                          style: TextStyle(
                            color:
                                Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: Row(
              children: [

                const Icon(
                  Icons.local_fire_department,
                  color: Colors.green,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    "Free shipping on orders above ₹999",
                    style: TextStyle(
                      color:
                          Colors.green.shade800,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}