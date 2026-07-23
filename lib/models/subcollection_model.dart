import 'package:cloud_firestore/cloud_firestore.dart';

class PriceRange {
  final int minQuantity;
  final int maxQuantity;
  final double price;

  const PriceRange({
    required this.minQuantity,
    required this.maxQuantity,
    required this.price,
  });

  factory PriceRange.fromMap(Map<String, dynamic> map) {
    return PriceRange(
      minQuantity:
          int.tryParse(map["min_quantity"]?.toString() ?? "0") ?? 0,
      maxQuantity:
          int.tryParse(map["max_quantity"]?.toString() ?? "0") ?? 0,
      price:
          double.tryParse(map["price"]?.toString() ?? "0") ?? 0,
    );
  }
}

class TieredPricing {
  final List<PriceRange> dealer;
  final List<PriceRange> distributor;
  final List<PriceRange> wholesale;
  final List<PriceRange> retail;
  final List<PriceRange> vip;
  final List<PriceRange> dropshipping;

  const TieredPricing({
    required this.dealer,
    required this.distributor,
    required this.wholesale,
    required this.retail,
    required this.vip,
    required this.dropshipping,
  });

  factory TieredPricing.fromMap(Map<String, dynamic>? map) {
    List<PriceRange> parse(String key) {
      final list = map?[key] as List? ?? [];

      return list
          .map((e) => PriceRange.fromMap(
                Map<String, dynamic>.from(e),
              ))
          .toList();
    }

    return TieredPricing(
      dealer: parse("dealer"),
      distributor: parse("distributor"),
      wholesale: parse("wholesale"),
      retail: parse("retail"),
      vip: parse("vip"),
      dropshipping: parse("dropshipping"),
    );
  }
}

class SubCollectionModel {
  final String id;

  final String name;
  final String description;
  final String image;

  final double purchaseRate;

  final int showNumber;

  final TieredPricing pricing;

  const SubCollectionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.purchaseRate,
    required this.showNumber,
    required this.pricing,
  });

  factory SubCollectionModel.fromFirestore(
      DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return SubCollectionModel(
      id: doc.id,
      name: (data["name"] ?? "").toString(),
      description: (data["description"] ?? "").toString(),
      image: (data["image"] ?? "").toString(),
      purchaseRate:
          (data["purchaseRate"] ?? 0).toDouble(),
      showNumber: (data["showNumber"] ?? 0) as int,
      pricing: TieredPricing.fromMap(
        data["tieredPricing"] as Map<String, dynamic>?,
      ),
    );
  }
}