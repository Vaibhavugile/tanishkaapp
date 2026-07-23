import 'product_model.dart';
import 'subcollection_model.dart';

class HomeProductModel {
  final ProductModel product;

  final SubCollectionModel subCollection;

  /// Which collection the product came from
  /// ("products" or "appProducts")
  final String source;

  const HomeProductModel({
    required this.product,
    required this.subCollection,
    required this.source,
  });

  bool get isAppProduct => source == "appProducts";

  bool get isNormalProduct => source == "products";

  /// Main display image
  String get image => product.image;

  /// Product name
  String get name => product.productName;

  /// Product code
  String get code => product.productCode;

  /// Gallery
  List<String> get gallery => product.gallery;

  /// Total stock
  int get stock => product.totalStock;

  bool get inStock => product.inStock;

  bool get hasVariants => product.hasVariants;

  /// Purchase rate
  double get purchaseRate => subCollection.purchaseRate;

  /// Pricing
  TieredPricing get pricing => subCollection.pricing;
}