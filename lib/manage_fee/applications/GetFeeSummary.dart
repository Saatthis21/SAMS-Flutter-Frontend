import 'dart:convert';
import 'package:http/http.dart' as http;

class GetFeeSummary {

  static const String baseUrl = "http://10.0.2.2:8000/api";

  static Future<Map<String, dynamic>> execute(String studentId) async {

    final response = await http.get(
      Uri.parse("$baseUrl/fee/summary/$studentId"),
    );

    return jsonDecode(response.body);
  }
}