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
  State<CategorySection> createState() =>
      _CategorySectionState();
}

class _CategorySectionState
    extends State<CategorySection> {
  final CategoryService _service =
      CategoryService();

  ///////////////////////////////////////////////////////////
  /// SELECTED CATEGORY
  ///////////////////////////////////////////////////////////

  String? selectedId;

  ///////////////////////////////////////////////////////////
  /// FIRST CATEGORY LOADED
  ///
  /// Prevents StreamBuilder from repeatedly selecting
  /// the first category whenever the stream updates.
  ///////////////////////////////////////////////////////////

  bool _firstCategoryLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        /////////////////////////////////////////////////////////
        /// HEADER
        /////////////////////////////////////////////////////////

        Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 22,
          ),
          child: Row(
            children: [

              Container(
                width: 5,
                height: 30,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(0xffD81B78),
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              const Expanded(
                child: Text(
                  "Shop by Category",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Color(0xff2C2C2C),
                    letterSpacing: -.5,
                  ),
                ),
              ),

              ///////////////////////////////////////////////////
              /// NO "VIEW ALL"
              ///////////////////////////////////////////////////
            ],
          ),
        ),

        const SizedBox(
          height: 20,
        ),

        /////////////////////////////////////////////////////////
        /// CATEGORIES
        /////////////////////////////////////////////////////////

        SizedBox(
          height: 150,
          child:
              StreamBuilder<
                  List<CategoryModel>>(
            stream:
                _service.getCategories(),

            builder:
                (context, snapshot) {

              ///////////////////////////////////////////////////
              /// LOADING
              ///////////////////////////////////////////////////

              if (snapshot
                      .connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child:
                      CircularProgressIndicator(
                    color:
                        Color(0xffD81B78),
                  ),
                );
              }

              ///////////////////////////////////////////////////
              /// ERROR
              ///////////////////////////////////////////////////

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    children: const [

                      Icon(
                        Icons
                            .cloud_off_rounded,
                        size: 42,
                        color:
                            Color(
                          0xffD81B78,
                        ),
                      ),

                      SizedBox(
                        height: 10,
                      ),

                      Text(
                        "Unable to load categories",
                        style:
                            TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              ///////////////////////////////////////////////////
              /// DATA
              ///////////////////////////////////////////////////

              final categories =
                  snapshot.data ?? [];

              ///////////////////////////////////////////////////
              /// EMPTY
              ///////////////////////////////////////////////////

              if (categories.isEmpty) {
                return const Center(
                  child: Text(
                    "No Categories Found",
                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                );
              }

              ///////////////////////////////////////////////////
              /// AUTOMATICALLY SELECT FIRST CATEGORY
              ///////////////////////////////////////////////////

              if (!_firstCategoryLoaded) {
                _firstCategoryLoaded =
                    true;

                final firstCategory =
                    categories.first;

                selectedId =
                    firstCategory.id;

                ///////////////////////////////////////////////////
                /// Notify parent.
                ///
                /// This causes AllProductsScreen to load
                /// the first indexed category.
                ///////////////////////////////////////////////////

                WidgetsBinding.instance
                    .addPostFrameCallback(
                  (_) {
                    if (!mounted) {
                      return;
                    }

                    widget
                        .onCategorySelected(
                      firstCategory,
                    );
                  },
                );
              }

              ///////////////////////////////////////////////////
              /// CATEGORY LIST
              ///////////////////////////////////////////////////

              return ListView.builder(
                physics:
                    const BouncingScrollPhysics(),

                scrollDirection:
                    Axis.horizontal,

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                ///////////////////////////////////////////////////
                /// NO +1
                ///
                /// Because "All" was removed.
                ///////////////////////////////////////////////////

                itemCount:
                    categories.length,

                itemBuilder:
                    (context, index) {

                  ///////////////////////////////////////////////////
                  /// FIRST FIRESTORE CATEGORY IS INDEX 0
                  ///////////////////////////////////////////////////

                  final category =
                      categories[index];

                  return CategoryCard(
                    category:
                        category,

                    isSelected:
                        selectedId ==
                            category.id,

                    onTap: () {

                      ///////////////////////////////////////////////////
                      /// SELECT CATEGORY
                      ///////////////////////////////////////////////////

                      setState(() {
                        selectedId =
                            category.id;
                      });

                      ///////////////////////////////////////////////////
                      /// LOAD SELECTED CATEGORY
                      ///////////////////////////////////////////////////

                      widget
                          .onCategorySelected(
                        category,
                      );
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