import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api.dart';

class SubmitRegistration {
  Future<bool> execute(String studentID) async {
    final response = await http.post(Uri.parse('${ApiConfig.baseUrl}/notify-faculty/$studentID'));
    final data = response.body.isNotEmpty ? json.decode(response.body) : {};

    if (response.statusCode == 200 && data['success'] == true) {
      return true;
    }

    throw Exception(data['message'] ?? 'Failed to notify faculty');
  }
}
