class VariationModel {
  final String color;
  final String size;
  final int quantity;
  final int initialQuantity;

  const VariationModel({
    required this.color,
    required this.size,
    required this.quantity,
    required this.initialQuantity,
  });

  factory VariationModel.fromMap(Map<String, dynamic> map) {
    return VariationModel(
      color: (map['color'] ?? '').toString(),
      size: (map['size'] ?? '').toString(),
      quantity: (map['quantity'] ?? 0) as int,
      initialQuantity: (map['initialQuantity'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'color': color,
      'size': size,
      'quantity': quantity,
      'initialQuantity': initialQuantity,
    };
  }

  bool get hasSize => size.trim().isNotEmpty;

  bool get hasColor => color.trim().isNotEmpty;

  bool get inStock => quantity > 0;
}