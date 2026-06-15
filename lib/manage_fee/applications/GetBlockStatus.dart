import 'dart:convert';
import 'package:http/http.dart' as http;

class GetBlockStatus {

  static const String baseUrl = "http://127.0.0.1:8000/api";

  static Future<Map<String, dynamic>> execute(
      String studentId) async {

    final response = await http.get(

      Uri.parse(
          "$baseUrl/block/status/$studentId"),

    );

    return jsonDecode(response.body);

  }

}