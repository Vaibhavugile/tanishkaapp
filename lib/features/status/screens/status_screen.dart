import 'package:flutter/material.dart';

import '../../../models/category_model.dart';
import '../../../services/category_service.dart';
import 'status_viewer_screen.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  static const Color primary = Color(0xffE91E63);
  static const Color dark = Color(0xff241B2F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F7FA),

      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),

          slivers: [
            ///////////////////////////////////////////////////////
            /// HEADER
            ///////////////////////////////////////////////////////

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  22,
                  20,
                  8,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Status",
                      style: TextStyle(
                        fontSize: 29,
                        fontWeight: FontWeight.w900,
                        color: dark,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      "Explore our latest collections",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            ///////////////////////////////////////////////////////
            /// COLLECTION STATUS
            ///////////////////////////////////////////////////////

            SliverToBoxAdapter(
              child: StreamBuilder<List<CategoryModel>>(
                stream:
                    CategoryService().getCategories(),

                builder: (
                  context,
                  snapshot,
                ) {
                  ///////////////////////////////////////////////////
                  /// LOADING
                  ///////////////////////////////////////////////////

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(30),
                      child: Center(
                        child:
                            CircularProgressIndicator(
                          color: primary,
                        ),
                      ),
                    );
                  }

                  ///////////////////////////////////////////////////
                  /// ERROR
                  ///////////////////////////////////////////////////

                  if (snapshot.hasError) {
                    return Padding(
                      padding:
                          const EdgeInsets.all(30),
                      child: Center(
                        child: Text(
                          "Unable to load collections.",
                          style: TextStyle(
                            color:
                                Colors.grey.shade700,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }

                  final categories =
                      snapshot.data ?? [];

                  ///////////////////////////////////////////////////
                  /// EMPTY
                  ///////////////////////////////////////////////////

                  if (categories.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          "No collections available.",
                        ),
                      ),
                    );
                  }

                  ///////////////////////////////////////////////////
                  /// HORIZONTAL STATUS LIST
                  ///////////////////////////////////////////////////

                  return SizedBox(
                    height: 126,

                    child: ListView.separated(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 15,
                      ),

                      scrollDirection:
                          Axis.horizontal,

                      physics:
                          const BouncingScrollPhysics(),

                      itemCount:
                          categories.length,

                      separatorBuilder:
                          (_, __) =>
                              const SizedBox(
                        width: 17,
                      ),

                      itemBuilder:
                          (context, index) {
                        final category =
                            categories[index];

                        return _StatusCircle(
                          category:
                              category,

                          onTap: () {
                            Navigator.push(
                              context,

                              MaterialPageRoute(
                                builder: (_) =>
                                    StatusViewerScreen(
                                  category:
                                      category,

                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            ///////////////////////////////////////////////////////
            /// DIVIDER
            ///////////////////////////////////////////////////////

            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: Divider(
                  color: Colors.grey.shade200,
                ),
              ),
            ),

            ///////////////////////////////////////////////////////
            /// INFO
            ///////////////////////////////////////////////////////

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  30,
                ),

                child: Container(
                  padding:
                      const EdgeInsets.all(18),

                  decoration:
                      BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(
                      22,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(.04),
                        blurRadius: 16,
                        offset:
                            const Offset(0, 6),
                      ),
                    ],
                  ),

                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,

                        decoration:
                            BoxDecoration(
                          color: primary
                              .withOpacity(.09),
                          shape:
                              BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons
                              .auto_awesome_outlined,
                          color: primary,
                        ),
                      ),

                      const SizedBox(
                        width: 13,
                      ),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                            Text(
                              "What's New",
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),

                            SizedBox(height: 3),

                            Text(
                              "Tap a collection to explore available products.",
                              style: TextStyle(
                                color:
                                    Colors.black54,
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////
/// STATUS CIRCLE
///////////////////////////////////////////////////////////////

class _StatusCircle extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const _StatusCircle({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: SizedBox(
        width: 76,

        child: Column(
          children: [
            /////////////////////////////////////////////////////
            /// GRADIENT RING
            /////////////////////////////////////////////////////

            Container(
              width: 72,
              height: 72,

              padding:
                  const EdgeInsets.all(3),

              decoration:
                  const BoxDecoration(
                shape: BoxShape.circle,

                gradient:
                    LinearGradient(
                  colors: [
                    Color(0xffE91E63),
                    Color(0xffFF8A65),
                    Color(0xffF8BBD0),
                    Color(0xffE91E63),
                  ],

                  begin:
                      Alignment.topLeft,

                  end:
                      Alignment.bottomRight,
                ),
              ),

              child: Container(
                padding:
                    const EdgeInsets.all(2),

                decoration:
                    const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),

                child: ClipOval(
                  child: Image.network(
                    category.image,

                    width: 62,
                    height: 62,

                    fit: BoxFit.cover,

                    errorBuilder:
                        (_, __, ___) {
                      return Container(
                        color:
                            Colors.grey.shade100,

                        child: const Icon(
                          Icons
                              .image_outlined,
                          color:
                              Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 7),

            /////////////////////////////////////////////////////
            /// TITLE
            /////////////////////////////////////////////////////

            Text(
              category.title,

              maxLines: 1,

              overflow:
                  TextOverflow.ellipsis,

              textAlign:
                  TextAlign.center,

              style: const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w700,
                color:
                    Color(0xff241B2F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}