enum AdminOrderFilter {
  all,

  pending,

  confirmed,

  packing,

  packed,

  shipped,

  delivered,

  cancelled,

  paymentPending,

  paymentVerified,
}

extension AdminOrderFilterExtension
    on AdminOrderFilter {
  String get title {
    switch (this) {
      case AdminOrderFilter.all:
        return "All";

      case AdminOrderFilter.pending:
        return "Pending";

      case AdminOrderFilter.confirmed:
        return "Confirmed";

      case AdminOrderFilter.packing:
        return "Packing";

      case AdminOrderFilter.packed:
        return "Packed";

      case AdminOrderFilter.shipped:
        return "Shipped";

      case AdminOrderFilter.delivered:
        return "Delivered";

      case AdminOrderFilter.cancelled:
        return "Cancelled";

      case AdminOrderFilter.paymentPending:
        return "Payment Pending";

      case AdminOrderFilter.paymentVerified:
        return "Payment Verified";
    }
  }
}