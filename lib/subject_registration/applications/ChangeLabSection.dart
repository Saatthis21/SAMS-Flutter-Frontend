import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api.dart';

class ChangeLabSection {
  Future<bool> execute(int registeredID, int newLabID) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/change-lab/$registeredID');

    // ADDED HEADERS HERE!
    final response = await http.post( 
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json', 
      },
      body: json.encode({
        'new_lab_id': newLabID,
      }),
    );

    if (response.statusCode != 200) {
      final errorData = response.body.isNotEmpty ? json.decode(response.body) : {};
      throw Exception(errorData['message'] ?? 'Failed to update section.');
    }
    
    final data = json.decode(response.body);
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to update section.');
    }
    return true;
  }
}