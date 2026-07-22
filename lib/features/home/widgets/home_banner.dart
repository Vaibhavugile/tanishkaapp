import 'dart:async';

import 'package:flutter/material.dart';
import 'banner_card.dart';

class HomeBanner extends StatefulWidget {
  const HomeBanner({super.key});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  final PageController _controller = PageController(viewportFraction: .92);

  int currentPage = 0;

  Timer? timer;

  final banners = const [
    {
      "title": "Bridal\nCollection",
      "subtitle": "Premium Jewellery for Every Occasion",
      "button": "Shop Now",
    },
    {
      "title": "Gold\nNecklace",
      "subtitle": "Elegant Designs Crafted with Love",
      "button": "Explore",
    },
    {
      "title": "New\nArrivals",
      "subtitle": "Latest Fashion Jewellery Collection",
      "button": "Discover",
    },
  ];

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: 4),
      (_) {
        if (!_controller.hasClients) return;

        int next = currentPage + 1;

        if (next >= banners.length) {
          next = 0;
        }

        _controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        SizedBox(
          height: 225,
          child: PageView.builder(
            controller: _controller,
            itemCount: banners.length,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            itemBuilder: (_, index) {

              final banner = banners[index];

              return AnimatedScale(
                duration: const Duration(milliseconds: 250),
                scale: currentPage == index ? 1 : .94,
                child: BannerCard(
                  title: banner["title"]!,
                  subtitle: banner["subtitle"]!,
                  buttonText: banner["button"]!,
                  onTap: () {},
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 18),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            banners.length,
            (index) {

              final selected = currentPage == index;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: selected ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xffD81B78)
                      : Colors.pink.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}