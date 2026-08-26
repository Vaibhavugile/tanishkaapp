import 'package:flutter/material.dart';

import '../../../models/category_model.dart';
import '../../../services/category_service.dart';
import 'status_viewer_screen.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({
    super.key,
  });

  static const Color primary =
      Color(0xffE91E63);

  static const Color dark =
      Color(0xff241B2F);

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xffF8F7FA),

      body: SafeArea(
        child: CustomScrollView(
          physics:
              const BouncingScrollPhysics(),

          slivers: [
            ///////////////////////////////////////////////////////
            /// HEADER
            ///////////////////////////////////////////////////////

            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  22,
                  20,
                  12,
                ),

                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          const Text(
                            "Status",
                            style:
                                TextStyle(
                              fontSize: 29,
                              fontWeight:
                                  FontWeight.w900,
                              color: dark,
                            ),
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          Text(
                            "Explore our latest collections",
                            style:
                                TextStyle(
                              fontSize: 14,
                              color: Colors
                                  .grey
                                  .shade600,
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    //////////////////////////////////////////////////
                    /// STATUS ICON
                    //////////////////////////////////////////////////

                    Container(
                      width: 42,
                      height: 42,

                      decoration:
                          BoxDecoration(
                        color: primary
                            .withOpacity(.09),
                        borderRadius:
                            BorderRadius
                                .circular(
                          14,
                        ),
                      ),

                      child:
                          const Icon(
                        Icons
                            .auto_awesome_outlined,
                        color: primary,
                        size: 22,
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
              child:
                  StreamBuilder<
                      List<CategoryModel>>(
                stream:
                    CategoryService()
                        .getCategories(),

                builder: (
                  context,
                  snapshot,
                ) {
                  //////////////////////////////////////////////////
                  /// LOADING
                  //////////////////////////////////////////////////

                  if (snapshot
                          .connectionState ==
                      ConnectionState
                          .waiting) {
                    return _buildLoading();
                  }

                  //////////////////////////////////////////////////
                  /// ERROR
                  //////////////////////////////////////////////////

                  if (snapshot.hasError) {
                    return Padding(
                      padding:
                          const EdgeInsets
                              .all(
                        30,
                      ),
                      child:
                          Center(
                        child: Text(
                          "Unable to load collections.",
                          style:
                              TextStyle(
                            color: Colors
                                .grey
                                .shade700,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }

                  final categories =
                      snapshot.data ?? [];

                  //////////////////////////////////////////////////
                  /// EMPTY
                  //////////////////////////////////////////////////

                  if (categories.isEmpty) {
                    return const Padding(
                      padding:
                          EdgeInsets.all(
                        40,
                      ),
                      child:
                          Center(
                        child: Text(
                          "No collections available.",
                        ),
                      ),
                    );
                  }

                  //////////////////////////////////////////////////
                  /// HORIZONTAL STATUS CARDS
                  //////////////////////////////////////////////////

                  return SizedBox(
                    height: 154,

                    child:
                        ListView.separated(
                      padding:
                          const EdgeInsets
                              .fromLTRB(
                        18,
                        8,
                        18,
                        18,
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
                        width: 10,
                      ),

                      itemBuilder:
                          (context, index) {
                        final category =
                            categories[
                                index];

                        return _StatusCard(
                          category:
                              category,

                          onTap: () {
                            Navigator.push(
                              context,

                              PageRouteBuilder(
                                transitionDuration:
                                    const Duration(
                                  milliseconds:
                                      280,
                                ),

                                reverseTransitionDuration:
                                    const Duration(
                                  milliseconds:
                                      220,
                                ),

                                pageBuilder:
                                    (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                ) {
                                  return StatusViewerScreen(
                                    category:
                                        category,
                                  );
                                },

                                transitionsBuilder:
                                    (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  return FadeTransition(
                                    opacity:
                                        animation,
                                    child:
                                        child,
                                  );
                                },
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
                    const EdgeInsets
                        .symmetric(
                  horizontal: 20,
                ),

                child:
                    Divider(
                  color:
                      Colors.grey.shade200,
                  height: 18,
                ),
              ),
            ),

            ///////////////////////////////////////////////////////
            /// INFO
            ///////////////////////////////////////////////////////

            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  30,
                ),

                child:
                    Container(
                  padding:
                      const EdgeInsets.all(
                    18,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white,

                    borderRadius:
                        BorderRadius
                            .circular(
                      22,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Colors
                            .black
                            .withOpacity(
                          .04,
                        ),
                        blurRadius: 16,
                        offset:
                            const Offset(
                          0,
                          6,
                        ),
                      ),
                    ],
                  ),

                  child:
                      Row(
                    children: [
                      //////////////////////////////////////////////////
                      /// ICON
                      //////////////////////////////////////////////////

                      Container(
                        width: 44,
                        height: 44,

                        decoration:
                            BoxDecoration(
                          color: primary
                              .withOpacity(
                            .09,
                          ),
                          shape:
                              BoxShape
                                  .circle,
                        ),

                        child:
                            const Icon(
                          Icons
                              .auto_awesome_outlined,
                          color: primary,
                        ),
                      ),

                      const SizedBox(
                        width: 13,
                      ),

                      //////////////////////////////////////////////////
                      /// TEXT
                      //////////////////////////////////////////////////

                      const Expanded(
                        child:
                            Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                            Text(
                              "What's New",
                              style:
                                  TextStyle(
                                fontWeight:
                                    FontWeight
                                        .w800,
                                fontSize: 15,
                              ),
                            ),

                            SizedBox(
                              height: 3,
                            ),

                            Text(
                              "Tap a collection to explore available products.",
                              style:
                                  TextStyle(
                                color:
                                    Colors.black54,
                                fontSize: 13,
                                height:
                                    1.35,
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

  //////////////////////////////////////////////////////////////
  /// LOADING
  //////////////////////////////////////////////////////////////

  static Widget _buildLoading() {
    return SizedBox(
      height: 154,

      child:
          ListView.separated(
        padding:
            const EdgeInsets.fromLTRB(
          18,
          8,
          18,
          18,
        ),

        scrollDirection:
            Axis.horizontal,

        physics:
            const NeverScrollableScrollPhysics(),

        itemCount: 5,

        separatorBuilder:
            (_, __) =>
                const SizedBox(
          width: 10,
        ),

        itemBuilder:
            (_, index) {
          return Container(
            width: 94,
            height: 128,

            decoration:
                BoxDecoration(
              color:
                  Colors.grey.shade200,

              borderRadius:
                  BorderRadius
                      .circular(
                18,
              ),
            ),
          );
        },
      ),
    );
  }
}

////////////////////////////////////////////////////////////////
/// STATUS CARD
////////////////////////////////////////////////////////////////

class _StatusCard
    extends StatelessWidget {
  final CategoryModel category;

  final VoidCallback onTap;

  const _StatusCard({
    required this.category,
    required this.onTap,
  });

  static const Color primary =
      Color(0xffE91E63);

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: onTap,

      child:
          Container(
        width: 94,
        height: 128,

        decoration:
            BoxDecoration(
          borderRadius:
              BorderRadius
                  .circular(
            18,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(
                .10,
              ),
              blurRadius: 12,
              offset:
                  const Offset(
                0,
                5,
              ),
            ),
          ],
        ),

        child:
            ClipRRect(
          borderRadius:
              BorderRadius
                  .circular(
            18,
          ),

          child:
              Stack(
            fit:
                StackFit.expand,

            children: [
              //////////////////////////////////////////////////
              /// IMAGE
              //////////////////////////////////////////////////

              _StatusImage(
                url:
                    category.image,
              ),

              //////////////////////////////////////////////////
              /// DARK GRADIENT
              //////////////////////////////////////////////////

              DecoratedBox(
                decoration:
                    BoxDecoration(
                  gradient:
                      LinearGradient(
                    begin:
                        Alignment.topCenter,
                    end:
                        Alignment.bottomCenter,

                    colors: [
                      Colors
                          .transparent,

                      Colors.black
                          .withOpacity(
                        .05,
                      ),

                      Colors.black
                          .withOpacity(
                        .78,
                      ),
                    ],

                    stops:
                        const [
                      0,
                      .40,
                      1,
                    ],
                  ),
                ),
              ),

              //////////////////////////////////////////////////
              /// TOP STATUS DOT
              //////////////////////////////////////////////////

              Positioned(
                top: 8,
                right: 8,

                child:
                    Container(
                  width: 8,
                  height: 8,

                  decoration:
                      BoxDecoration(
                    color: primary,

                    shape:
                        BoxShape
                            .circle,

                    boxShadow: [
                      BoxShadow(
                        color: primary
                            .withOpacity(
                          .45,
                        ),
                        blurRadius: 6,
                        spreadRadius:
                            1,
                      ),
                    ],
                  ),
                ),
              ),

              //////////////////////////////////////////////////
              /// COLLECTION TITLE
              //////////////////////////////////////////////////

              Positioned(
                left: 9,
                right: 9,
                bottom: 10,

                child:
                    Text(
                  category.title,

                  maxLines: 2,

                  overflow:
                      TextOverflow
                          .ellipsis,

                  style:
                      const TextStyle(
                    color:
                        Colors.white,

                    fontSize: 12,

                    height: 1.1,

                    fontWeight:
                        FontWeight.w800,

                    shadows: [
                      Shadow(
                        color:
                            Colors.black54,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////
/// STATUS IMAGE
////////////////////////////////////////////////////////////////

class _StatusImage
    extends StatelessWidget {
  final String url;

  const _StatusImage({
    required this.url,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    if (url.trim().isEmpty) {
      return _placeholder();
    }

    return Image.network(
      url,

      fit:
          BoxFit.cover,

      width:
          double.infinity,

      height:
          double.infinity,

      loadingBuilder:
          (
        context,
        child,
        loadingProgress,
      ) {
        if (loadingProgress ==
            null) {
          return AnimatedOpacity(
            opacity: 1,
            duration:
                const Duration(
              milliseconds:
                  250,
            ),
            child:
                child,
          );
        }

        return Stack(
          fit:
              StackFit.expand,

          children: [
            _placeholder(),

            Center(
              child:
                  SizedBox(
                width: 22,
                height: 22,

                child:
                    CircularProgressIndicator(
                  strokeWidth:
                      2,

                  color:
                      Colors.white,

                  value: loadingProgress
                              .expectedTotalBytes !=
                          null
                      ? loadingProgress
                              .cumulativeBytesLoaded /
                          loadingProgress
                              .expectedTotalBytes!
                      : null,
                ),
              ),
            ),
          ],
        );
      },

      errorBuilder:
          (
        context,
        error,
        stackTrace,
      ) {
        return _placeholder(
          error: true,
        );
      },
    );
  }

  Widget _placeholder({
    bool error = false,
  }) {
    return Container(
      decoration:
          const BoxDecoration(
        gradient:
            LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            Color(0xff292929),
            Color(0xff111111),
          ],
        ),
      ),

      child:
          Center(
        child:
            Icon(
          error
              ? Icons
                  .image_not_supported_outlined
              : Icons
                  .image_outlined,

          color:
              Colors.white24,

          size: 28,
        ),
      ),
    );
  }
}