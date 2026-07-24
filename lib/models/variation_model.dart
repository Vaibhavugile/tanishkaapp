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
      color: (map['color'] ?? '').toString().trim(),
      size: (map['size'] ?? '').toString().trim(),
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

  // ==========================================================
  // Helpers
  // ==========================================================

  bool get hasSize => size.isNotEmpty;

  bool get hasColor => color.isNotEmpty;

  bool get inStock => quantity > 0;

  bool get isLowStock => quantity > 0 && quantity <= 3;

  bool get isOutOfStock => quantity <= 0;

  /// Premium display label
  /// Examples:
  /// Pink • Small
  /// Pink
  /// Small
  /// Default
  String get label {
    if (hasColor && hasSize) {
      return "$color • $size";
    }

    if (hasColor) {
      return color;
    }

    if (hasSize) {
      return size;
    }

    return "Default";
  }

  /// Stock label
  String get stockLabel {
    if (isOutOfStock) {
      return "Out of Stock";
    }

    if (isLowStock) {
      return "Only $quantity Left";
    }

    return "$quantity In Stock";
  }

  @override
  String toString() => label;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VariationModel &&
        other.color == color &&
        other.size == size;
  }

  @override
  int get hashCode => Object.hash(color, size);

  VariationModel copyWith({
    String? color,
    String? size,
    int? quantity,
    int? initialQuantity,
  }) {
    return VariationModel(
      color: color ?? this.color,
      size: size ?? this.size,
      quantity: quantity ?? this.quantity,
      initialQuantity: initialQuantity ?? this.initialQuantity,
    );
  }
}