import 'dart:convert';

import 'package:http/http.dart' as http;

class OrderService {
  OrderService._();

  static final OrderService instance = OrderService._();

  static const String _url =
      "https://us-central1-jewellerywholesale-2e57c.cloudfunctions.net/placeOrderApp";

  Future<Map<String, dynamic>> placeOrder({
    required Map<String, dynamic> orderData,
  }) async {
    final response = await http.post(
      Uri.parse(_url),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(orderData),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    return jsonDecode(response.body);
  }
}