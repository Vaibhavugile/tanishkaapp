import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BrandTitle extends StatelessWidget {
  const BrandTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Text(
          "YANI",
          style: GoogleFonts.playfairDisplay(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: const Color(0xff662D45),
            letterSpacing: 4,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          "FINE JEWELLERY",
          style: GoogleFonts.poppins(
            color: const Color(0xffC9A64E),
            letterSpacing: 8,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}