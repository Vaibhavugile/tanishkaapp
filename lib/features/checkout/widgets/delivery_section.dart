import 'package:flutter/material.dart';

enum DeliveryType {
  standard,
  express,
}

class DeliverySection extends StatelessWidget {
  final DeliveryType selected;
  final ValueChanged<DeliveryType> onChanged;

  const DeliverySection({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
                Icons.local_shipping_rounded,
                color: Color(0xffE91E63),
              ),

              SizedBox(width: 10),

              Text(
                "Delivery Method",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _DeliveryTile(
            icon: Icons.local_shipping,
            title: "Standard Delivery",
            subtitle:
                "Estimated: Fri, 31 Jul - Sun, 2 Aug",
            badge: "Recommended",
            badgeColor: Colors.green,
            price: "FREE",
            selected:
                selected ==
                    DeliveryType.standard,
            onTap: () => onChanged(
              DeliveryType.standard,
            ),
          ),

          const SizedBox(height: 16),

          _DeliveryTile(
            icon: Icons.flash_on_rounded,
            title: "Express Delivery",
            subtitle:
                "Estimated: Tomorrow",
            badge: "Fastest",
            badgeColor: Colors.orange,
            price: "₹150",
            selected:
                selected ==
                    DeliveryType.express,
            onTap: () => onChanged(
              DeliveryType.express,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final String price;
  final bool selected;
  final VoidCallback onTap;

  const _DeliveryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.price,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xffE91E63);

    return InkWell(
      borderRadius:
          BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected
              ? primary.withOpacity(.08)
              : Colors.grey.shade50,
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? primary
                : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [

            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: primary,
            ),

            const SizedBox(width: 16),

            CircleAvatar(
              radius: 22,
              backgroundColor:
                  primary.withOpacity(.1),
              child: Icon(
                icon,
                color: primary,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [

                      Expanded(
                        child: Text(
                          title,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration:
                            BoxDecoration(
                          color: badgeColor
                              .withOpacity(.12),
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),
                        ),
                        child: Text(
                          badge,
                          style:
                              TextStyle(
                            color:
                                badgeColor,
                            fontSize: 11,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    subtitle,
                    style: TextStyle(
                      color:
                          Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Text(
              price,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}