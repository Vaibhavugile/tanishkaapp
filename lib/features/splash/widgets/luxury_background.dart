import 'package:flutter/material.dart';

class LuxuryBackground extends StatelessWidget {
  final Widget child;

  const LuxuryBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xffFFFDFD),
            Color(0xffFFF7F8),
            Color(0xffFFF2F5),
            Color(0xffFFF9F8),
          ],
        ),
      ),
      child: Stack(
        children: [

          /// Top Right Glow
          Positioned(
            top: -120,
            right: -120,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xffF9DCE7).withOpacity(.35),
              ),
            ),
          ),

          /// Bottom Left Glow
          Positioned(
            bottom: -160,
            left: -120,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xffFFE8EF).withOpacity(.55),
              ),
            ),
          ),

          child,
        ],
      ),
    );
  }
}