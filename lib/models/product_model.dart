import 'package:cloud_firestore/cloud_firestore.dart';

import 'variation_model.dart';

class ProductModel {
  final String id;

  final String productName;
  final String productCode;

  final String image;

  final List<String> additionalImages;

  final int quantity;
  final int initialQuantity;

  final List<VariationModel> variations;

  final String mainCollection;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductModel({
    required this.id,
    required this.productName,
    required this.productCode,
    required this.image,
    required this.additionalImages,
    required this.quantity,
    required this.initialQuantity,
    required this.variations,
    required this.mainCollection,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ProductModel(
      id: doc.id,

      productName: (data['productName'] ?? '').toString(),

      productCode: (data['productCode'] ?? '').toString(),

      image: (data['image'] ?? '').toString(),

      additionalImages:
          (data['additionalImages'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],

      quantity: (data['quantity'] ?? 0) as int,

      initialQuantity:
          (data['initialQuantity'] ?? 0) as int,

      mainCollection:
          (data['mainCollection'] ?? '').toString(),

      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate(),

      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate(),

      variations:
          (data['variations'] as List?)
                  ?.map(
                    (e) => VariationModel.fromMap(
                      Map<String, dynamic>.from(e),
                    ),
                  )
                  .toList() ??
              [],
    );
  }

  bool get hasVariants => variations.isNotEmpty;

  bool get isSimpleProduct => variations.isEmpty;

  int get totalStock {
    if (!hasVariants) {
      return quantity;
    }

    return variations.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  bool get inStock => totalStock > 0;

  List<String> get gallery {
    return [
      image,
      ...additionalImages,
    ];
  }
}