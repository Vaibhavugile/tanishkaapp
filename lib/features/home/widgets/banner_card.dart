import 'package:flutter/material.dart';

class BannerCard extends StatelessWidget {
  const BannerCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xffFCE4EC),
            Color(0xffF8BBD0),
            Color(0xffF48FB1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xffD81B78).withOpacity(.20),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -20,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(.18),
                ),
              ),
            ),

            Positioned(
              right: 30,
              bottom: 20,
              child: Icon(
                Icons.diamond_rounded,
                size: 95,
                color: Colors.white.withOpacity(.35),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.22),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Text(
                      "NEW COLLECTION",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        fontSize: 11,
                      ),
                    ),
                  ),

                  const Spacer(),

                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      height: 1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: 190,
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(.95),
                        fontSize: 16,
                        height: 1.35,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(50),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            buttonText,
                            style: const TextStyle(
                              color: Color(0xffD81B78),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Color(0xffD81B78),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}