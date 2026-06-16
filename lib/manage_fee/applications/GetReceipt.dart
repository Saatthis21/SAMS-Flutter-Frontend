import 'dart:convert';
import 'package:http/http.dart' as http;

class GetReceipt {

  static const String baseUrl = "http://10.0.2.2:8000/api";

  static Future<Map<String, dynamic>> execute(
      String receiptId) async {

    final response = await http.get(

      Uri.parse(
          "$baseUrl/receipt/$receiptId"),

    );

    return jsonDecode(response.body);

  }

}