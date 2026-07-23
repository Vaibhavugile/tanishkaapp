import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/home_product_model.dart';
import '../models/product_model.dart';
import '../models/subcollection_model.dart';

class LatestProductsService {
  LatestProductsService();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String productsCollection = "products";
  static const String appProductsCollection = "appProducts";

  Future<List<HomeProductModel>> getLatestProducts({
    String? categoryId,
    int limit = 10,
  }) async {
    debugPrint("======================================");
    debugPrint("🚀 Fetching Latest Products");
    debugPrint("Category : ${categoryId ?? "All"}");
    debugPrint("======================================");

    try {
      final List<HomeProductModel> allProducts = [];

      //--------------------------------------------------------
      // PRODUCTS QUERY
      //--------------------------------------------------------

      Query<Map<String, dynamic>> productsQuery =
          _firestore.collectionGroup(productsCollection);

      if (categoryId != null) {
        productsQuery = productsQuery.where(
          "mainCollection",
          isEqualTo: categoryId,
        );
      }

      final productsSnapshot = await productsQuery
          .orderBy("createdAt", descending: true)
          .limit(limit)
          .get();

      debugPrint(
          "✅ Products Found : ${productsSnapshot.docs.length}");

      for (final doc in productsSnapshot.docs) {
        try {
          final product = ProductModel.fromFirestore(doc);

          final subCollectionRef = doc.reference.parent.parent!;

          final subDoc = await subCollectionRef.get();

          final subCollection =
              SubCollectionModel.fromFirestore(subDoc);

          allProducts.add(
            HomeProductModel(
              product: product,
              subCollection: subCollection,
              source: productsCollection,
            ),
          );

          debugPrint("✔ Product : ${product.productName}");
        } catch (e) {
          debugPrint("❌ Product Error : $e");
        }
      }

      //--------------------------------------------------------
      // APP PRODUCTS QUERY
      //--------------------------------------------------------

      Query<Map<String, dynamic>> appProductsQuery =
          _firestore.collectionGroup(appProductsCollection);

      if (categoryId != null) {
        appProductsQuery = appProductsQuery.where(
          "mainCollection",
          isEqualTo: categoryId,
        );
      }

      final appProductsSnapshot = await appProductsQuery
          .orderBy("createdAt", descending: true)
          .limit(limit)
          .get();

      debugPrint(
          "✅ App Products Found : ${appProductsSnapshot.docs.length}");

      for (final doc in appProductsSnapshot.docs) {
        try {
          final product = ProductModel.fromFirestore(doc);

          final subCollectionRef = doc.reference.parent.parent!;

          final subDoc = await subCollectionRef.get();

          final subCollection =
              SubCollectionModel.fromFirestore(subDoc);

          allProducts.add(
            HomeProductModel(
              product: product,
              subCollection: subCollection,
              source: appProductsCollection,
            ),
          );

          debugPrint("✔ App Product : ${product.productName}");
        } catch (e) {
          debugPrint("❌ App Product Error : $e");
        }
      }

      //--------------------------------------------------------
      // SORT BOTH LISTS TOGETHER
      //--------------------------------------------------------

      allProducts.sort((a, b) {
        final aDate = a.product.createdAt ?? DateTime(2000);
        final bDate = b.product.createdAt ?? DateTime(2000);

        return bDate.compareTo(aDate);
      });

      final result = allProducts.take(limit).toList();

      debugPrint("======================================");
      debugPrint("🎉 Returning ${result.length} Products");
      debugPrint("======================================");

      return result;
    } catch (e, stack) {
      debugPrint("❌ LatestProductsService Error");
      debugPrint(e.toString());
      debugPrint(stack.toString());

      rethrow;
    }
  }
  Future<({
  List<HomeProductModel> products,
  DocumentSnapshot? lastDocument,
  bool appProductsCompleted,
})> getProductsPage({
  String? categoryId,
  required bool loadAppProducts,
  DocumentSnapshot? startAfter,
  int limit = 20,
}) async {
  final String collectionName =
      loadAppProducts ? appProductsCollection : productsCollection;

  Query<Map<String, dynamic>> query =
      _firestore.collectionGroup(collectionName);

  if (categoryId != null) {
    query = query.where(
      "mainCollection",
      isEqualTo: categoryId,
    );
  }

  query = query.orderBy("createdAt", descending: true);

  if (startAfter != null) {
    query = query.startAfterDocument(startAfter);
  }

  final snapshot = await query.limit(limit).get();

  final List<HomeProductModel> items = [];

  for (final doc in snapshot.docs) {
    try {
      final product = ProductModel.fromFirestore(doc);

      final subDoc =
          await doc.reference.parent.parent!.get();

      final subCollection =
          SubCollectionModel.fromFirestore(subDoc);

      items.add(
        HomeProductModel(
          product: product,
          subCollection: subCollection,
          source: collectionName,
        ),
      );
    } catch (e) {
      debugPrint(
        "Error loading ${doc.reference.path}: $e",
      );
    }
  }

  return (
    products: items,
    lastDocument:
        snapshot.docs.isEmpty ? null : snapshot.docs.last,
    appProductsCompleted:
        loadAppProducts && snapshot.docs.length < limit,
  );
}
}