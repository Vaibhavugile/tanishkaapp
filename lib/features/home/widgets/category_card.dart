import 'package:flutter/material.dart';
import '../../../models/category_model.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        scale: isSelected ? 1.08 : 1,
        child: Container(
          width: 90,
          margin: const EdgeInsets.only(right: 16),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 74,
                height: 74,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [
                            Color(0xffD81B78),
                            Color(0xffF5B2CF),
                          ],
                        )
                      : null,
                  color: isSelected ? null : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? const Color(0xffD81B78).withOpacity(.30)
                          : Colors.black.withOpacity(.08),
                      blurRadius: isSelected ? 24 : 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: category.image.isEmpty
                        ? Container(
                            color: const Color(0xffFFF3F8),
                            child: const Icon(
                              Icons.apps_rounded,
                              color: Color(0xffD81B78),
                              size: 34,
                            ),
                          )
                        : Image.network(
                            category.image,
                            fit: BoxFit.cover,
                            loadingBuilder:
                                (context, child, progress) {
                              if (progress == null) return child;

                              return const Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xffD81B78),
                                  ),
                                ),
                              );
                            },
                            errorBuilder:
                                (_, __, ___) => Container(
                              color: const Color(0xffFFF3F8),
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Color(0xffD81B78),
                              ),
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected
                      ? FontWeight.w700
                      : FontWeight.w600,
                  color: isSelected
                      ? const Color(0xffD81B78)
                      : Colors.black87,
                ),
                child: Text(
                  category.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 6),

              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 4,
                width: isSelected ? 26 : 0,
                decoration: BoxDecoration(
                  color: const Color(0xffD81B78),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}