import 'package:cloud_firestore/cloud_firestore.dart';

import 'variation_model.dart';

class CartItemModel {
  final String id;

  /// Product
  final String productId;

  /// Parent Collection ID
  final String collectionId;

  /// Sub Collection ID
  final String subCollectionId;

  /// Source Collection
  /// "products" or "appProducts"
  final String source;

  final String productName;
  final String productCode;

  final String image;

  /// Selected Variation
  final VariationModel? variation;

  /// Quantity
  final int quantity;

  /// Pricing
  final double unitPrice;
  final double totalPrice;

  /// User Role
  final String userRole;

  /// Dates
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const CartItemModel({
    required this.id,
    required this.productId,
    required this.collectionId,
    required this.subCollectionId,
    required this.source,
    required this.productName,
    required this.productCode,
    required this.image,
    required this.variation,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.userRole,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartItemModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return CartItemModel(
      id: id,
      productId: map["productId"] ?? "",
      collectionId: map["collectionId"] ?? "",
      subCollectionId: map["subCollectionId"] ?? "",
      source: map["source"] ?? "products",
      productName: map["productName"] ?? "",
      productCode: map["productCode"] ?? "",
      image: map["image"] ?? "",
      variation: map["variation"] != null
          ? VariationModel.fromMap(
              Map<String, dynamic>.from(
                map["variation"],
              ),
            )
          : null,
      quantity: map["quantity"] ?? 1,
      unitPrice: (map["unitPrice"] ?? 0).toDouble(),
      totalPrice: (map["totalPrice"] ?? 0).toDouble(),
      userRole: map["userRole"] ?? "retail",
      createdAt: map["createdAt"] ?? Timestamp.now(),
      updatedAt: map["updatedAt"] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "productId": productId,
      "collectionId": collectionId,
      "subCollectionId": subCollectionId,
      "source": source,
      "productName": productName,
      "productCode": productCode,
      "image": image,
      "variation": variation?.toMap(),
      "quantity": quantity,
      "unitPrice": unitPrice,
      "totalPrice": totalPrice,
      "userRole": userRole,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
    };
  }

  CartItemModel copyWith({
    String? collectionId,
    String? source,
    VariationModel? variation,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    Timestamp? updatedAt,
  }) {
    return CartItemModel(
      id: id,
      productId: productId,
      collectionId: collectionId ?? this.collectionId,
      subCollectionId: subCollectionId,
      source: source ?? this.source,
      productName: productName,
      productCode: productCode,
      image: image,
      variation: variation ?? this.variation,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      userRole: userRole,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get hasVariation => variation != null;

  String get color => variation?.color ?? "";

  String get size => variation?.size ?? "";

  String get variationKey {
    if (variation == null) {
      return "";
    }

    return "${variation!.color}_${variation!.size}";
  }

  bool isSameVariant(CartItemModel other) {
    return collectionId == other.collectionId &&
        productId == other.productId &&
        subCollectionId == other.subCollectionId &&
        variationKey == other.variationKey;
  }
}