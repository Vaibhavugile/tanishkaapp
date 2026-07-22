import 'package:flutter/material.dart';

import '../../../models/category_model.dart';
import '../../../services/category_service.dart';
import 'category_card.dart';

class CategorySection extends StatefulWidget {
  final Function(CategoryModel?) onCategorySelected;

  const CategorySection({
    super.key,
    required this.onCategorySelected,
  });

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  final CategoryService _service = CategoryService();

  String selectedId = "all";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        /// HEADER
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            children: [

              Container(
                width: 5,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xffD81B78),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Text(
                  "Shop by Category",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff2C2C2C),
                    letterSpacing: -.5,
                  ),
                ),
              ),

              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffFFF1F7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "View All",
                    style: TextStyle(
                      color: Color(0xffD81B78),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          height: 150,
          child: StreamBuilder<List<CategoryModel>>(
            stream: _service.getCategories(),
            builder: (context, snapshot) {

              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xffD81B78),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [

                      Icon(
                        Icons.cloud_off_rounded,
                        size: 42,
                        color: Color(0xffD81B78),
                      ),

                      SizedBox(height: 10),

                      Text(
                        "Unable to load categories",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final categories = snapshot.data ?? [];

              if (categories.isEmpty) {
                return const Center(
                  child: Text(
                    "No Categories Found",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                itemCount: categories.length + 1,
                itemBuilder: (context, index) {

                  if (index == 0) {
                    return CategoryCard(
                      category: const CategoryModel(
                        id: "all",
                        title: "All",
                        image: "",
                        showNumber: 0,
                      ),
                      isSelected: selectedId == "all",
                      onTap: () {
                        setState(() {
                          selectedId = "all";
                        });

                        widget.onCategorySelected(null);
                      },
                    );
                  }

                  final category = categories[index - 1];

                  return CategoryCard(
                    category: category,
                    isSelected:
                        selectedId == category.id,
                    onTap: () {
                      setState(() {
                        selectedId = category.id;
                      });

                      widget.onCategorySelected(category);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}