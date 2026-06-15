import 'dart:convert';
import 'package:http/http.dart' as http;

class InitiatePayment {

  static const String baseUrl = "http://127.0.0.1:8000/api";

  static Future<Map<String, dynamic>> execute({

    required String studentId,
    required String feeId,
    required double amount,
    required String paymentMethod,

  }) async {

    final response = await http.post(

      Uri.parse("$baseUrl/payment/initiate"),

      headers: {
        "Content-Type": "application/json"
      },

      body: jsonEncode({

        "student_id": studentId,
        "fee_id": feeId,
        "amount": amount,
        "payment_method": paymentMethod

      }),

    );

    return jsonDecode(response.body);

  }

}