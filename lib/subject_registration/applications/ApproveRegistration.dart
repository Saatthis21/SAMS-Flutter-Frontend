import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api.dart';

class ApproveRegistration {
  Future<bool> executeApprove(int submissionID) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/review-decision'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'submissionID': submissionID,
        'decision': 'Approve',
        'rejection_reason': null,
      }),
    );

    final data = response.body.isNotEmpty ? json.decode(response.body) : {};
    if (response.statusCode == 200 && data['success'] == true) {
      return true;
    }

    throw Exception(data['message'] ?? 'Error processing approval');
  }
}
