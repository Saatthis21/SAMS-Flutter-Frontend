import 'dart:convert';
import 'package:http/http.dart' as http;

class UpdateFeeStructure {

  static const String baseUrl =
      "http://10.0.2.2:8000/api";

  Future<bool> execute({

    required int id,

    required String program,

    required String semester,

    required double feeAmount,

    required int deadlineWeek,

  }) async {

    final response = await http.put(

      Uri.parse(
        "$baseUrl/fee/update/$id",
      ),

      headers: {
        "Content-Type": "application/json",
      },

      body: jsonEncode({

        "program": program,

        "semester": semester,

        "fee_amount": feeAmount,

        "deadline_week": deadlineWeek,

      }),

    );

    return response.statusCode == 200;
  }
}