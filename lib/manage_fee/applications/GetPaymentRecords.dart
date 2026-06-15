import 'dart:convert';
import 'package:http/http.dart' as http;

class GetPaymentRecords {

  static const String baseUrl =
      "http://10.0.2.2:8000/api";

  Future<List<dynamic>> execute() async {

    final response = await http.get(
      Uri.parse(
        "$baseUrl/treasury/payments",
      ),
    );

    if (response.statusCode == 200) {

      final jsonData =
          jsonDecode(response.body);

      return jsonData["data"];

    }

    return [];

  }

}