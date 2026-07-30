import 'package:flutter/material.dart';

import '../widgets/address_section.dart';
import '../widgets/delivery_section.dart';
import 'package:provider/provider.dart';

import '../../../providers/cart_provider.dart';
import '../widgets/order_summary_section.dart';
import '../widgets/price_summary_section.dart';
import '../../address/screens/address_list_screen.dart';
import '../../../models/address_model.dart';
import '../widgets/coupon_section.dart';
import '../widgets/order_notes_section.dart';
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
  });

  @override
  State<CheckoutScreen> createState() =>
      _CheckoutScreenState();
}

class _CheckoutScreenState
    extends State<CheckoutScreen> {
  DeliveryType _delivery =
      DeliveryType.standard;
      AddressModel? _selectedAddress;
      final TextEditingController
    _orderNotesController =
        TextEditingController();
      Future<void> _selectAddress() async {
  final AddressModel? address =
      await Navigator.push<AddressModel>(
    context,
    MaterialPageRoute(
      builder: (_) =>
          const AddressListScreen(
        selectMode: true,
      ),
    ),
  );

  if (address == null) return;

  setState(() {
    _selectedAddress = address;
  });
}
// Map<String, dynamic> _buildOrderData() {
//   return {
//     /// Customer
//     "customerId": FirebaseAuth.instance.currentUser!.uid,

//     "orderSource": "Flutter App",

//     "createdFrom": "Mobile App",

//     /// Order Status
//     "status": "Placed",

//     "paymentMethod": "Pending",

//     "paymentStatus": "Pending",

//     "deliveryMethod": _selectedDelivery.name,

//     "notes": _orderNotesController.text.trim(),

//     /// Billing Info
//     "billingInfo": {
//       "fullName": _selectedAddress!.fullName,
//       "phoneNumber": _selectedAddress!.phoneNumber,
//       "email":
//           FirebaseAuth.instance.currentUser?.email ?? "",
//       "addressLine1": _selectedAddress!.addressLine1,
//       "addressLine2": _selectedAddress!.addressLine2,
//       "city": _selectedAddress!.city,
//       "state": _selectedAddress!.state,
//       "country": _selectedAddress!.country,
//       "pincode": _selectedAddress!.pincode,
//     },

//     /// Shipping Info
//     "shippingInfo": {
//       "fullName": _selectedAddress!.fullName,
//       "phoneNumber": _selectedAddress!.phoneNumber,
//       "email":
//           FirebaseAuth.instance.currentUser?.email ?? "",
//       "addressLine1": _selectedAddress!.addressLine1,
//       "addressLine2": _selectedAddress!.addressLine2,
//       "city": _selectedAddress!.city,
//       "state": _selectedAddress!.state,
//       "country": _selectedAddress!.country,
//       "pincode": _selectedAddress!.pincode,
//     },

//     /// Products
//     "items": cart.items.map((item) {
//       return {
//         "collectionId": item.collectionId,
//         "subcollectionId": item.subCollectionId,
//         "productId": item.productId,
//         "productName": item.productName,
//         "productCode": item.productCode,
//         "image": item.image,
//         "quantity": item.quantity,
//         "priceAtTimeOfOrder": item.unitPrice,
//         "totalPrice": item.totalPrice,
//         "source": item.source,
//         "variation": item.variation?.toMap(),
//       };
//     }).toList(),

//     /// Pricing
//     "subtotal": cart.totalPrice,

//     "shippingFee":
//         _selectedDelivery == DeliveryType.express
//             ? 150.0
//             : 0.0,

//     "discount": 0.0,

//     "totalAmount":
//         cart.totalPrice +
//         (_selectedDelivery ==
//                 DeliveryType.express
//             ? 150.0
//             : 0.0),
//   };
// }
@override
void dispose() {
  _orderNotesController.dispose();
  super.dispose();
}
  @override
  Widget build(BuildContext context) {
    final cart =
    Provider.of<CartProvider>(context);
    final shipping =
    _delivery == DeliveryType.standard
        ? 0.0
        : 150.0;

final subtotal = cart.totalPrice;

const discount = 0.0;

final gst = subtotal * 0.03;
    return Scaffold(
      backgroundColor: const Color(0xffF8F9FB),

      body: SafeArea(
        child: Column(
          children: [
            /// Header
            Container(
  padding: const EdgeInsets.fromLTRB(
    20,
    16,
    20,
    16,
  ),
  decoration: BoxDecoration(
    color: const Color(0xffFFF5F8),
    borderRadius: const BorderRadius.only(
      bottomLeft: Radius.circular(28),
      bottomRight: Radius.circular(28),
    ),
    boxShadow: [
      BoxShadow(
        color: const Color(0xffE91E63).withOpacity(.08),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  ),
  child: SafeArea(
    bottom: false,
    child: Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xffF4D5E2),
              ),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: Color(0xffE91E63),
            ),
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                "Checkout",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff222222),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                "${cart.totalItems} item${cart.totalItems > 1 ? "s" : ""}",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.lock_outline,
                size: 14,
                color: Colors.green,
              ),
              SizedBox(width: 4),
              Text(
                "Secure",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
),

            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                children: [
                  /// Address
                  AddressSection(
  hasAddress:
      _selectedAddress != null,

  name:
      _selectedAddress?.fullName ?? "",

  phone:
      _selectedAddress?.phone ?? "",

  address:
      _selectedAddress?.fullAddress ?? "",

  onAdd: _selectAddress,

  onChange: _selectAddress,
),

                  const SizedBox(height: 20),

                  /// Delivery
                  DeliverySection(
                    selected: _delivery,
                    onChanged: (value) {
                      setState(() {
                        _delivery = value;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  /// Order Summary
                  OrderSummarySection(
  items: cart.items,
),

                  const SizedBox(height: 20),

                  /// Coupon
CouponSection(
  appliedCoupon: null,
  onApply: () {
    // TODO
    // Open Coupon Screen
  },
),
                  const SizedBox(height: 20),

                  /// Order Notes
OrderNotesSection(
  controller: _orderNotesController,
),
                       const SizedBox(height: 20),
             

                  /// Price Summary
PriceSummarySection(
  subtotal: subtotal,
  shipping: shipping,
  discount: discount,
  gst: gst,
),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
  padding: const EdgeInsets.fromLTRB(
    20,
    16,
    20,
    20,
  ),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(28),
      topRight: Radius.circular(28),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(.08),
        blurRadius: 20,
        offset: const Offset(0, -6),
      ),
    ],
  ),
  child: SafeArea(
    top: false,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        Row(
          children: [

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    "Total Payable",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "₹${(subtotal + shipping + gst - discount).toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffE91E63),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor:
                        const Color(0xffE91E63),
                    foregroundColor:
                        Colors.white,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),
                    ),
                  ),
                  onPressed:
                      cart.isEmpty ||
                              _selectedAddress ==
                                  null
                          ? null
                          : () {

                            // Payment

                          },
                  child: const Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [

                      Text(
                        "Continue",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      SizedBox(width: 8),

                      Icon(
                        Icons.arrow_forward,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [

            Icon(
              Icons.lock,
              size: 15,
              color: Colors.green.shade700,
            ),

            const SizedBox(width: 6),

            Text(
              "100% Secure Checkout",
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    ),
  ),
),
    );
  }
}