import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/cart_item_model.dart';
import '../models/home_product_model.dart';
import '../models/variation_model.dart';
import '../services/user_role_service.dart';
import '../models/product_model.dart';
import '../models/subcollection_model.dart';
class CartService {
  CartService._();

  static final CartService instance = CartService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  User get _user {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in.");
    }

    return user;
  }

  CollectionReference<Map<String, dynamic>>
      get _cartCollection {
    return _firestore
        .collection("appUsers")
        .doc(_user.uid)
        .collection("cart");
  }

  /// ---------------------------------------------------------
  /// Find existing cart item having same
  /// Product
  /// Sub Collection
  /// Variant
  /// ---------------------------------------------------------
  Future<CartItemModel?> _findExistingItem({
    required String productId,
    required String subCollectionId,
    VariationModel? variation,
  }) async {
    final snapshot = await _cartCollection
        .where("productId", isEqualTo: productId)
        .where(
          "subCollectionId",
          isEqualTo: subCollectionId,
        )
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    final variantKey =
        "${variation?.color ?? ""}_${variation?.size ?? ""}";

    for (final doc in snapshot.docs) {
      final item = CartItemModel.fromMap(
        doc.id,
        doc.data(),
      );

      if (item.variationKey == variantKey) {
        return item;
      }
    }

    return null;
  }

  /// ---------------------------------------------------------
  /// Check available stock
  /// ---------------------------------------------------------
  void _validateStock({
    required HomeProductModel product,
    required VariationModel? variation,
    required int quantity,
  }) {
    if (quantity <= 0) {
      throw Exception("Invalid quantity.");
    }

    if (variation != null) {
      if (quantity > variation.quantity) {
        throw Exception(
          "Only ${variation.quantity} item(s) available.",
        );
      }
      return;
    }

    if (quantity > product.product.totalStock) {
      throw Exception(
        "Only ${product.product.totalStock} item(s) available.",
      );
    }
  }

  /// ---------------------------------------------------------
  /// Calculate role-based pricing
  /// ---------------------------------------------------------
  double _calculateUnitPrice({
    required HomeProductModel product,
    required int quantity,
  }) {
    return product.getPrice(
      role: UserRoleService.instance.role,
      quantity: quantity,
    );
  }

  /// ---------------------------------------------------------
  /// Add to Cart
  /// ---------------------------------------------------------
 
    // Existing item merge logic continues in Part 1B.
    Future<void> addToCart({
  required HomeProductModel product,
  VariationModel? variation,
  int quantity = 1,
}) async {
  _validateStock(
    product: product,
    variation: variation,
    quantity: quantity,
  );

  final existingItem = await _findExistingItem(
    productId: product.product.id,
    subCollectionId: product.subCollection.id,
    variation: variation,
  );

  /// =========================================================
  /// ITEM ALREADY EXISTS
  /// =========================================================
  if (existingItem != null) {
    final newQuantity =
        existingItem.quantity + quantity;

    _validateStock(
      product: product,
      variation: variation,
      quantity: newQuantity,
    );

    final newUnitPrice = _calculateUnitPrice(
      product: product,
      quantity: newQuantity,
    );

    final newTotalPrice =
        newUnitPrice * newQuantity;

    await _cartCollection
        .doc(existingItem.id)
        .update({
      "quantity": newQuantity,
      "unitPrice": newUnitPrice,
      "totalPrice": newTotalPrice,
      "updatedAt": Timestamp.now(),
    });

    return;
  }

  /// =========================================================
  /// NEW CART ITEM
  /// =========================================================

  final unitPrice = _calculateUnitPrice(
    product: product,
    quantity: quantity,
  );

  final totalPrice =
      unitPrice * quantity;

  final now = Timestamp.now();

  final doc = _cartCollection.doc();

  final item = CartItemModel(
  id: doc.id,
  productId: product.product.id,
  subCollectionId: product.subCollection.id,

  source: product.source,

  productName: product.product.productName,
  productCode: product.product.productCode,
  image: product.product.image,
  variation: variation,
  quantity: quantity,
  unitPrice: unitPrice,
  totalPrice: totalPrice,
  userRole: UserRoleService.instance.role,
  createdAt: now,
  updatedAt: now,
);

  await doc.set(item.toMap());
}
  

  /// =========================================================
/// UPDATE QUANTITY
/// =========================================================
Future<void> updateQuantity({
  required CartItemModel item,
  required int quantity,
}) async {
  final product =
      await getProductForCart(item);

  if (quantity <= 0) {
    await removeItem(item.id);
    return;
  }

  _validateStock(
    product: product,
    variation: item.variation,
    quantity: quantity,
  );

  final unitPrice = _calculateUnitPrice(
    product: product,
    quantity: quantity,
  );

  final totalPrice =
      unitPrice * quantity;

  await _cartCollection
      .doc(item.id)
      .update({
    "quantity": quantity,
    "unitPrice": unitPrice,
    "totalPrice": totalPrice,
    "updatedAt": Timestamp.now(),
  });
}
/// =========================================================
/// INCREASE
/// =========================================================
Future<void> increaseQuantity({
  required CartItemModel item,
}) async {
  await updateQuantity(
    item: item,
    quantity: item.quantity + 1,
  );
}

/// =========================================================
/// DECREASE
/// =========================================================
Future<void> decreaseQuantity({
  required CartItemModel item,
}) async {
  await updateQuantity(
    item: item,
    quantity: item.quantity - 1,
  );
}
/// =========================================================
/// REMOVE ITEM
/// =========================================================
Future<void> removeItem(String cartItemId) async {
  await _cartCollection.doc(cartItemId).delete();
}

/// =========================================================
/// CLEAR CART
/// =========================================================
Future<void> clearCart() async {
  final snapshot = await _cartCollection.get();

  final batch = _firestore.batch();

  for (final doc in snapshot.docs) {
    batch.delete(doc.reference);
  }

  await batch.commit();
}
/// =========================================================
/// CART STREAM
/// =========================================================
Stream<List<CartItemModel>> cartStream() {
  return _cartCollection
      .orderBy("createdAt", descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => CartItemModel.fromMap(
                doc.id,
                doc.data(),
              ),
            )
            .toList(),
      );
}

/// =========================================================
/// CART COUNT
/// =========================================================
Stream<int> cartCount() {
  return cartStream().map(
    (items) => items.fold(
      0,
      (sum, item) => sum + item.quantity,
    ),
  );
}

/// =========================================================
/// CART TOTAL
/// =========================================================
Stream<double> cartTotal() {
  return cartStream().map(
    (items) => items.fold(
      0.0,
      (sum, item) => sum + item.totalPrice,
    ),
  );
}
/// =========================================================
/// GET CART COUNT
/// =========================================================
Future<int> getCartCount() async {
  final snapshot = await _cartCollection.get();

  int total = 0;

  for (final doc in snapshot.docs) {
    total += (doc.data()["quantity"] ?? 1) as int;
  }

  return total;
}

/// =========================================================
/// GET CART TOTAL
/// =========================================================
Future<double> getCartTotal() async {
  final snapshot = await _cartCollection.get();

  double total = 0;

  for (final doc in snapshot.docs) {
    total += (doc.data()["totalPrice"] ?? 0).toDouble();
  }

  return total;
}

/// =========================================================
/// CHECK IF ITEM EXISTS
/// =========================================================
Future<bool> isInCart({
  required String productId,
  required String subCollectionId,
  VariationModel? variation,
}) async {
  final item = await _findExistingItem(
    productId: productId,
    subCollectionId: subCollectionId,
    variation: variation,
  );

  return item != null;
}
Future<HomeProductModel> getProductForCart(
  CartItemModel item,
) async {
  final snapshot = await _firestore
      .collectionGroup(item.source)
      .where(
        FieldPath.documentId,
        isEqualTo: item.productId,
      )
      .limit(1)
      .get();

  if (snapshot.docs.isEmpty) {
    throw Exception(
      "Product no longer exists.",
    );
  }

  final productDoc = snapshot.docs.first;

  final product =
      ProductModel.fromFirestore(productDoc);

  final subDoc =
      await productDoc.reference.parent.parent!.get();

  final subCollection =
      SubCollectionModel.fromFirestore(subDoc);

  return HomeProductModel(
    product: product,
    subCollection: subCollection,
    source: item.source,
  );
}
}
