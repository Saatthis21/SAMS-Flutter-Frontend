import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api.dart';

class RejectRegistration {
  Future<bool> executeReject(int submissionID, String reason) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/review-decision'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'submissionID': submissionID,
        'decision': 'Reject',
        'rejection_reason': reason,
      }),
    );

    final data = response.body.isNotEmpty ? json.decode(response.body) : {};
    if (response.statusCode == 200 && data['success'] == true) {
      return true;
    }

    throw Exception(data['message'] ?? 'Error processing rejection');
  }
}
