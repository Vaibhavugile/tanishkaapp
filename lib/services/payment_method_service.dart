import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/payment_method_model.dart';

class PaymentMethodService {
  PaymentMethodService._();

  static final PaymentMethodService instance =
      PaymentMethodService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  ///////////////////////////////////////////////////////////
  /// ACTIVE PAYMENT METHODS
  ///
  /// Only active scanners are returned.
  /// Ordered using sortOrder.
  ///////////////////////////////////////////////////////////

  Stream<List<PaymentMethodModel>>
      activePaymentMethodsStream() {
    return _firestore
        .collection("paymentMethods")
        .where(
          "isActive",
          isEqualTo: true,
        )
        .orderBy(
          "sortOrder",
          descending: false,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    PaymentMethodModel.fromFirestore(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  ///////////////////////////////////////////////////////////
  /// GET ACTIVE PAYMENT METHODS ONCE
  ///////////////////////////////////////////////////////////

  Future<List<PaymentMethodModel>>
      getActivePaymentMethods() async {
    final snapshot = await _firestore
        .collection("paymentMethods")
        .where(
          "isActive",
          isEqualTo: true,
        )
        .orderBy(
          "sortOrder",
          descending: false,
        )
        .get();

    return snapshot.docs
        .map(
          (doc) =>
              PaymentMethodModel.fromFirestore(
            doc.id,
            doc.data(),
          ),
        )
        .toList();
  }

  ///////////////////////////////////////////////////////////
  /// GET SINGLE PAYMENT METHOD
  ///////////////////////////////////////////////////////////

  Future<PaymentMethodModel?>
      getPaymentMethod(
    String paymentMethodId,
  ) async {
    if (paymentMethodId.trim().isEmpty) {
      return null;
    }

    final doc = await _firestore
        .collection("paymentMethods")
        .doc(paymentMethodId)
        .get();

    if (!doc.exists) {
      return null;
    }

    return PaymentMethodModel.fromFirestore(
      doc.id,
      doc.data() ?? {},
    );
  }

  ///////////////////////////////////////////////////////////
  /// CHECK IF PAYMENT METHOD IS ACTIVE
  ///////////////////////////////////////////////////////////

  Future<bool> isPaymentMethodActive(
    String paymentMethodId,
  ) async {
    final method =
        await getPaymentMethod(
      paymentMethodId,
    );

    return method?.isActive ?? false;
  }
  Stream<List<PaymentMethodModel>>
    allPaymentMethodsStream() {
  return _firestore
      .collection("paymentMethods")
      .orderBy(
        "sortOrder",
        descending: false,
      )
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) =>
                  PaymentMethodModel.fromFirestore(
                doc.id,
                doc.data(),
              ),
            )
            .toList(),
      );
}
}