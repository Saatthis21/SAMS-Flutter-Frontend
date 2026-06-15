import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api.dart';

class GetPendingRegistration {
  Future<List<dynamic>> execute() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/pending-registrations'));
    final data = response.body.isNotEmpty ? json.decode(response.body) : {};

    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    }

    throw Exception(data['message'] ?? 'Server Error: ${response.statusCode}');
  }
}
