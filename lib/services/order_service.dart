import 'dart:convert';

import 'package:http/http.dart' as http;

class OrderService {
  OrderService._();

  static const String _url =
      "https://us-central1-jewellerywholesale-2e57c.cloudfunctions.net/placeOrderApp";

  static Future<Map<String, dynamic>> placeOrder({
    required Map<String, dynamic> orderData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(orderData),
      );

      final Map<String, dynamic> data =
          jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      }

      throw Exception(
        data["error"] ??
            data["message"] ??
            "Failed to place order.",
      );
    } catch (e) {
      throw Exception(
        e.toString(),
      );
    }
  }
}