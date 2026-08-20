import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/home_product_model.dart';
import '../models/product_model.dart';
import '../models/subcollection_model.dart';

class LatestProductsService {
  LatestProductsService();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
///////////////////////////////////////////////////////////
/// SUB COLLECTION CACHE
///////////////////////////////////////////////////////////


  static const String productsCollection = "products";
  static const String appProductsCollection = "appProducts";

///////////////////////////////////////////////////////////
/// CHECK AVAILABLE STOCK
///////////////////////////////////////////////////////////

bool _hasAvailableStock(
  DocumentSnapshot<Map<String, dynamic>> doc,
) {
  final data = doc.data();

  if (data == null) {
    return false;
  }

  /////////////////////////////////////////////////////////
  /// VARIANT PRODUCT
  /////////////////////////////////////////////////////////

  final variations =
      data["variations"];

  if (variations is List &&
      variations.isNotEmpty) {
    for (final variation in variations) {
      if (variation is Map) {
        final quantity =
            num.tryParse(
                  "${variation["quantity"] ?? 0}",
                ) ??
                0;

        if (quantity > 0) {
          return true;
        }
      }
    }

    // Every variation has quantity 0.
    return false;
  }

  /////////////////////////////////////////////////////////
  /// SIMPLE PRODUCT
  /////////////////////////////////////////////////////////

  final quantity =
      num.tryParse(
            "${data["quantity"] ?? 0}",
          ) ??
          0;

  return quantity > 0;
}
///////////////////////////////////////////////////////////
/// GET SUB COLLECTION WITH CACHE
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
/// SUB COLLECTION CACHE
///
/// Cache the Future, not just the final model.
///
/// This prevents duplicate Firestore requests when
/// multiple products request the same subcollection
/// at the same time.
///////////////////////////////////////////////////////////

final Map<
    String,
    Future<SubCollectionModel>
> _subCollectionCache = {};
///////////////////////////////////////////////////////////
/// GET SUB COLLECTION WITH CACHE
///
/// IMPORTANT:
/// The Future itself is cached.
///
/// If 5 products request the same subcollection
/// simultaneously, only ONE Firestore request is made.
///////////////////////////////////////////////////////////

Future<SubCollectionModel>
    _getSubCollectionCached(
  DocumentReference<Map<String, dynamic>>
      subCollectionRef,
) {
  final path =
      subCollectionRef.path;

  ///////////////////////////////////////////////////////////
  /// CHECK CACHE
  ///////////////////////////////////////////////////////////

  final cachedFuture =
      _subCollectionCache[path];

  if (cachedFuture != null) {
    debugPrint(
      "⚡ SubCollection CACHE: $path",
    );

    return cachedFuture;
  }

  ///////////////////////////////////////////////////////////
  /// CREATE ONE FIRESTORE REQUEST
  ///////////////////////////////////////////////////////////

  final future = () async {
    debugPrint(
      "🔥 Firestore SubCollection: $path",
    );

    final subDoc =
        await subCollectionRef.get();

    return SubCollectionModel
        .fromFirestore(
      subDoc,
    );
  }();

  ///////////////////////////////////////////////////////////
  /// STORE THE FUTURE IMMEDIATELY
  ///
  /// This is important.
  ///
  /// We store it BEFORE awaiting it, so another
  /// simultaneous request gets the same Future.
  ///////////////////////////////////////////////////////////

  _subCollectionCache[path] =
      future;

  ///////////////////////////////////////////////////////////
  /// REMOVE FAILED REQUEST FROM CACHE
  ///
  /// If Firestore fails, don't permanently cache
  /// the failed Future.
  ///////////////////////////////////////////////////////////

  future.catchError((error) {
    _subCollectionCache.remove(path);
    throw error;
  });

  return future;
}
 Future<List<HomeProductModel>> getLatestProducts({
  String? categoryId,
  int limit = 10,
}) async {
  debugPrint("======================================");
  debugPrint("🚀 Fetching Latest Products");
  debugPrint(
    "Category : ${categoryId ?? "All"}",
  );
  debugPrint(
    "Required : $limit available products",
  );
  debugPrint("======================================");

  try {
    final List<HomeProductModel> allProducts = [];

    /////////////////////////////////////////////////////////
    /// HOW MANY FIRESTORE DOCUMENTS TO FETCH PER BATCH
    /////////////////////////////////////////////////////////

    const int batchSize = 20;

    /////////////////////////////////////////////////////////
    /// FETCH ONE COLLECTION
    /////////////////////////////////////////////////////////

    Future<void> fetchCollection(
      String collectionName,
    ) async {
      DocumentSnapshot<
          Map<String, dynamic>>? lastDocument;

      bool hasMore = true;

      ///////////////////////////////////////////////////////
      /// KEEP FETCHING UNTIL WE HAVE ENOUGH
      /// AVAILABLE PRODUCTS
      ///////////////////////////////////////////////////////

      while (
          hasMore &&
          allProducts.length < limit) {
        /////////////////////////////////////////////////////
        /// QUERY
        /////////////////////////////////////////////////////

        Query<Map<String, dynamic>> query =
            _firestore
                .collectionGroup(
                  collectionName,
                )
                .orderBy(
                  "createdAt",
                  descending: true,
                );

        /////////////////////////////////////////////////////
        /// CATEGORY FILTER
        /////////////////////////////////////////////////////

        if (categoryId != null) {
          query = query.where(
            "mainCollection",
            isEqualTo: categoryId,
          );
        }

        /////////////////////////////////////////////////////
        /// PAGINATION
        /////////////////////////////////////////////////////

        if (lastDocument != null) {
          query = query.startAfterDocument(
            lastDocument!,
          );
        }

        /////////////////////////////////////////////////////
        /// FETCH BATCH
        /////////////////////////////////////////////////////

        final snapshot =
            await query
                .limit(batchSize)
                .get();

        debugPrint(
          "📦 $collectionName batch: "
          "${snapshot.docs.length}",
        );

        /////////////////////////////////////////////////////
        /// NO MORE DOCUMENTS
        /////////////////////////////////////////////////////

        if (snapshot.docs.isEmpty) {
          hasMore = false;
          break;
        }

        /////////////////////////////////////////////////////
        /// PROCESS DOCUMENTS IN PARALLEL
        ///
        /// IMPORTANT:
        /// Stock is checked from the freshly fetched
        /// Firestore product document.
        ///
        /// Only SubCollectionModel uses cache.
        /////////////////////////////////////////////////////

        final futures =
            snapshot.docs.map(
          (doc) async {
            ///////////////////////////////////////////////////
            /// STOCK CHECK
            ///////////////////////////////////////////////////

            if (!_hasAvailableStock(doc)) {
              debugPrint(
                "⛔ Out of stock: ${doc.id}",
              );

              return null;
            }

            try {
              //////////////////////////////////////////////////
              /// PRODUCT MODEL
              //////////////////////////////////////////////////

              final product =
                  ProductModel.fromFirestore(
                doc,
              );

              //////////////////////////////////////////////////
              /// SUB COLLECTION REFERENCE
              //////////////////////////////////////////////////

              final subCollectionRef =
                  doc.reference
                      .parent
                      .parent!;

              //////////////////////////////////////////////////
              /// MAIN COLLECTION ID
              //////////////////////////////////////////////////

              final collectionId =
                  subCollectionRef
                      .parent
                      .parent!
                      .id;

              //////////////////////////////////////////////////
              /// GET SUB COLLECTION FROM CACHE
              //////////////////////////////////////////////////

              final subCollection =
                  await _getSubCollectionCached(
                subCollectionRef,
              );

              //////////////////////////////////////////////////
              /// CREATE HOME PRODUCT
              //////////////////////////////////////////////////

              debugPrint(
                "✅ Available: "
                "${product.productName}",
              );

              return HomeProductModel(
                collectionId:
                    collectionId,
                product:
                    product,
                subCollection:
                    subCollection,
                source:
                    collectionName,
              );
            } catch (e) {
              debugPrint(
                "❌ Product Error "
                "${doc.reference.path}: $e",
              );

              return null;
            }
          },
        );

        /////////////////////////////////////////////////////
        /// WAIT FOR ALL PRODUCTS IN THIS BATCH
        /////////////////////////////////////////////////////

        final loadedProducts =
            await Future.wait(
          futures,
        );

        /////////////////////////////////////////////////////
        /// ADD SUCCESSFULLY LOADED PRODUCTS
        /////////////////////////////////////////////////////

        for (final product
            in loadedProducts) {
          if (product != null) {
            allProducts.add(
              product,
            );

            //////////////////////////////////////////////////
            /// REQUIRED LIMIT REACHED
            //////////////////////////////////////////////////

            if (allProducts.length >=
                limit) {
              break;
            }
          }
        }

        /////////////////////////////////////////////////////
        /// LAST FIRESTORE DOCUMENT
        ///
        /// IMPORTANT:
        /// Always move the cursor using the last
        /// Firestore document fetched.
        /////////////////////////////////////////////////////

        lastDocument =
            snapshot.docs.last;

        /////////////////////////////////////////////////////
        /// CHECK WHETHER MORE DOCUMENTS EXIST
        /////////////////////////////////////////////////////

        if (snapshot.docs.length <
            batchSize) {
          hasMore = false;
        }

        /////////////////////////////////////////////////////
        /// DEBUG
        /////////////////////////////////////////////////////

        debugPrint(
          "📊 Available so far: "
          "${allProducts.length}/$limit",
        );

        debugPrint(
          "📊 Has more: $hasMore",
        );
      }
    }

    /////////////////////////////////////////////////////////
    /// FIRST: PRODUCTS
    /////////////////////////////////////////////////////////

    await fetchCollection(
      productsCollection,
    );

    /////////////////////////////////////////////////////////
    /// THEN: APP PRODUCTS
    ///
    /// Only fetch if we still need more.
    /////////////////////////////////////////////////////////

    if (allProducts.length <
        limit) {
      await fetchCollection(
        appProductsCollection,
      );
    }

    /////////////////////////////////////////////////////////
    /// SORT EVERYTHING BY CREATED DATE
    /////////////////////////////////////////////////////////

    allProducts.sort(
      (a, b) {
        final aDate =
            a.product.createdAt ??
                DateTime(2000);

        final bDate =
            b.product.createdAt ??
                DateTime(2000);

        return bDate.compareTo(
          aDate,
        );
      },
    );

    /////////////////////////////////////////////////////////
    /// RETURN ONLY REQUESTED NUMBER
    /////////////////////////////////////////////////////////

    final result =
        allProducts
            .take(limit)
            .toList();

    /////////////////////////////////////////////////////////
    /// FINAL DEBUG
    /////////////////////////////////////////////////////////

    debugPrint(
      "======================================",
    );

    debugPrint(
      "🎉 Returning "
      "${result.length} available products",
    );

    debugPrint(
      "======================================",
    );

    return result;
  } catch (e, stack) {
    /////////////////////////////////////////////////////////
    /// ERROR
    /////////////////////////////////////////////////////////

    debugPrint(
      "❌ LatestProductsService Error",
    );

    debugPrint(
      e.toString(),
    );

    debugPrint(
      stack.toString(),
    );

    rethrow;
  }
}
Future<({
  List<HomeProductModel> products,
  DocumentSnapshot? lastDocument,
  bool hasMore,
})> getProductsPage({
  String? categoryId,
  required bool loadAppProducts,
  DocumentSnapshot? startAfter,
  int limit = 20,
}) async {
  ///////////////////////////////////////////////////////////
  /// COLLECTION
  ///////////////////////////////////////////////////////////

  final String collectionName =
      loadAppProducts
          ? appProductsCollection
          : productsCollection;

  ///////////////////////////////////////////////////////////
  /// BATCH SIZE
  ///
  /// We fetch candidates in batches because some products
  /// may have zero stock.
  ///////////////////////////////////////////////////////////

  const int batchSize = 20;

  ///////////////////////////////////////////////////////////
  /// LAST FIRESTORE DOCUMENT
  ///////////////////////////////////////////////////////////

  DocumentSnapshot<Map<String, dynamic>>?
      lastDocument =
          startAfter
              as DocumentSnapshot<
                  Map<String, dynamic>>?;

  ///////////////////////////////////////////////////////////
  /// AVAILABLE PRODUCTS
  ///////////////////////////////////////////////////////////

  final List<HomeProductModel> items = [];

  ///////////////////////////////////////////////////////////
  /// MORE DOCUMENTS
  ///////////////////////////////////////////////////////////

  bool hasMore = true;

  ///////////////////////////////////////////////////////////
  /// KEEP FETCHING UNTIL:
  ///
  /// 1. We have enough AVAILABLE products
  ///
  /// OR
  ///
  /// 2. Firestore has no more documents.
  ///////////////////////////////////////////////////////////

  while (
      hasMore &&
      items.length < limit) {
    /////////////////////////////////////////////////////////
    /// QUERY
    /////////////////////////////////////////////////////////

    Query<Map<String, dynamic>> query =
        _firestore
            .collectionGroup(
              collectionName,
            )
            .orderBy(
              "createdAt",
              descending: true,
            );

    /////////////////////////////////////////////////////////
    /// CATEGORY FILTER
    /////////////////////////////////////////////////////////

    if (categoryId != null) {
      query = query.where(
        "mainCollection",
        isEqualTo: categoryId,
      );
    }

    /////////////////////////////////////////////////////////
    /// PAGINATION
    /////////////////////////////////////////////////////////

    if (lastDocument != null) {
      query = query.startAfterDocument(
        lastDocument,
      );
    }

    /////////////////////////////////////////////////////////
    /// FETCH BATCH
    /////////////////////////////////////////////////////////

    final snapshot =
        await query
            .limit(batchSize)
            .get();

    debugPrint(
      "==================================",
    );

    debugPrint(
      "Collection : $collectionName",
    );

    debugPrint(
      "Category   : ${categoryId ?? "ALL"}",
    );

    debugPrint(
      "Fetched    : ${snapshot.docs.length}",
    );

    debugPrint(
      "StartAfter : ${lastDocument?.id}",
    );

    debugPrint(
      "==================================",
    );

    /////////////////////////////////////////////////////////
    /// NO MORE DOCUMENTS
    /////////////////////////////////////////////////////////

    if (snapshot.docs.isEmpty) {
      hasMore = false;
      break;
    }

    /////////////////////////////////////////////////////////
    /// PROCESS DOCUMENTS IN PARALLEL
    /////////////////////////////////////////////////////////

    final futures =
        snapshot.docs.map(
      (doc) async {
        /////////////////////////////////////////////////////
        /// STOCK CHECK
        ///
        /// SIMPLE:
        /// quantity > 0
        ///
        /// VARIANT:
        /// ANY variation.quantity > 0
        /////////////////////////////////////////////////////

        if (!_hasAvailableStock(doc)) {
          debugPrint(
            "⛔ Out of stock: ${doc.id}",
          );

          return null;
        }

        try {
          ///////////////////////////////////////////////////
          /// PRODUCT MODEL
          ///////////////////////////////////////////////////

          final product =
              ProductModel.fromFirestore(
            doc,
          );

          ///////////////////////////////////////////////////
          /// SUB COLLECTION REFERENCE
          ///////////////////////////////////////////////////

          final subCollectionRef =
              doc.reference
                  .parent
                  .parent!;

          ///////////////////////////////////////////////////
          /// MAIN COLLECTION ID
          ///////////////////////////////////////////////////

          final collectionId =
              subCollectionRef
                  .parent
                  .parent!
                  .id;

          ///////////////////////////////////////////////////
          /// GET CACHED SUB COLLECTION
          ///////////////////////////////////////////////////

          final subCollection =
              await _getSubCollectionCached(
            subCollectionRef,
          );

          ///////////////////////////////////////////////////
          /// CREATE HOME PRODUCT
          ///////////////////////////////////////////////////

          debugPrint(
            "✅ Available: "
            "${product.productName}",
          );

          return HomeProductModel(
            collectionId:
                collectionId,
            product:
                product,
            subCollection:
                subCollection,
            source:
                collectionName,
          );
        } catch (e) {
          debugPrint(
            "❌ Error loading "
            "${doc.reference.path}: $e",
          );

          return null;
        }
      },
    );

    /////////////////////////////////////////////////////////
    /// WAIT FOR BATCH
    /////////////////////////////////////////////////////////

    final loadedProducts =
        await Future.wait(
      futures,
    );

    /////////////////////////////////////////////////////////
    /// ADD VALID PRODUCTS
    /////////////////////////////////////////////////////////

    for (final product
        in loadedProducts) {
      if (product != null) {
        items.add(product);

        /////////////////////////////////////////////////////
        /// PAGE SIZE REACHED
        /////////////////////////////////////////////////////

        if (items.length >= limit) {
          break;
        }
      }
    }

    /////////////////////////////////////////////////////////
    /// ADVANCE CURSOR
    ///
    /// IMPORTANT:
    /// Use the LAST FIRESTORE document fetched.
    ///
    /// Do NOT use the last available product.
    /////////////////////////////////////////////////////////

    lastDocument =
        snapshot.docs.last;

    /////////////////////////////////////////////////////////
    /// CHECK MORE DATA
    /////////////////////////////////////////////////////////

    if (snapshot.docs.length <
        batchSize) {
      hasMore = false;
    }

    /////////////////////////////////////////////////////////
    /// DEBUG PROGRESS
    /////////////////////////////////////////////////////////

    debugPrint(
      "📊 Available: "
      "${items.length}/$limit",
    );

    debugPrint(
      "📊 Has more: $hasMore",
    );
  }

  ///////////////////////////////////////////////////////////
  /// FINAL DEBUG
  ///////////////////////////////////////////////////////////

  debugPrint(
    "==================================",
  );

  debugPrint(
    "Collection         : $collectionName",
  );

  debugPrint(
    "Available returned : ${items.length}",
  );

  debugPrint(
    "Last document      : ${lastDocument?.id}",
  );

  debugPrint(
    "Has more           : $hasMore",
  );

  debugPrint(
    "==================================",
  );

  ///////////////////////////////////////////////////////////
  /// RETURN
  ///////////////////////////////////////////////////////////

  return (
    products: items,
    lastDocument: lastDocument,
    hasMore: hasMore,
  );
}
}