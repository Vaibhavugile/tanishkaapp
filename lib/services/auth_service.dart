import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const String _url =
      "https://us-central1-jewellerywholesale-2e57c.cloudfunctions.net/sendWhatsappOtp";

  Future<void> sendOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse(_url),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "integrated_number": "15558299861",
        "content_type": "template",
        "payload": {
          "messaging_product": "whatsapp",
          "type": "template",
          "template": {
            "name": "kiyuotp",
            "language": {
              "code": "en",
              "policy": "deterministic",
            },
            "namespace": "60cbb046_c34d_4f04_8c62_2cb720ccf00d",
            "to_and_components": [
              {
                "to": [phoneNumber.replaceAll("+", "")],
                "components": {
                  "body_1": {
                    "type": "text",
                    "value": otp,
                  },
                  "button_1": {
                    "subtype": "url",
                    "type": "text",
                    "value": otp,
                  }
                }
              }
            ]
          }
        }
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }
}