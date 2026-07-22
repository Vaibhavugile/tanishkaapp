import 'dart:math';

import 'package:flutter/material.dart';

class SparkleBackground extends StatelessWidget {
  const SparkleBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final random = Random(10);

    return IgnorePointer(
      child: Stack(
        children: List.generate(35, (index) {
          return Positioned(
            left: random.nextDouble() * 400,
            top: random.nextDouble() * 850,
            child: Opacity(
              opacity: random.nextDouble() * .5 + .2,
              child: Icon(
                Icons.auto_awesome,
                color: Colors.amber.shade200,
                size: random.nextDouble() * 10 + 8,
              ),
            ),
          );
        }),
      ),
    );
  }
}