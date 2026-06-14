import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api.dart';

class ChangeLabSection {
  Future<bool> execute(int registeredID, int newLabID) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/update-lab/$registeredID'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'new_lab_id': newLabID}),
    );

    final data = response.body.isNotEmpty ? json.decode(response.body) : {};
    if (response.statusCode == 200 && data['success'] == true) {
      return true;
    }

    throw Exception(data['message'] ?? 'Failed to update lab section');
  }
}
