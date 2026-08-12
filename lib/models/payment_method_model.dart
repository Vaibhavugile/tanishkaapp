class PaymentMethodModel {
  final String id;

  final String name;

  /// upi
  /// qr
  /// bank
  /// other
  final String type;

  /// Firebase Storage / image URL
  final String image;

  final bool isActive;

  final int sortOrder;

  const PaymentMethodModel({
    required this.id,
    required this.name,
    required this.type,
    required this.image,
    required this.isActive,
    required this.sortOrder,
  });

  ///////////////////////////////////////////////////////////
  /// FROM FIRESTORE
  ///////////////////////////////////////////////////////////

  factory PaymentMethodModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return PaymentMethodModel(
      id: id,

      name:
          (data["name"] ?? "").toString(),

      type:
          (data["type"] ?? "upi").toString(),

      image:
          (data["image"] ?? "").toString(),

      isActive:
          data["isActive"] == true,

      sortOrder:
          _toInt(data["sortOrder"]),
    );
  }

  ///////////////////////////////////////////////////////////
  /// TO MAP
  ///////////////////////////////////////////////////////////

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "type": type,
      "image": image,
      "isActive": isActive,
      "sortOrder": sortOrder,
    };
  }

  ///////////////////////////////////////////////////////////
  /// HELPERS
  ///////////////////////////////////////////////////////////

  bool get isUpi =>
      type == "upi";

  bool get isQr =>
      type == "qr";

  bool get isBank =>
      type == "bank";

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? "",
        ) ??
        0;
  }
}