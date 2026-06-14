import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api.dart';

class DropCourse {
  Future<String> execute(int registeredID) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/drop-course/$registeredID');
      final response = await http.delete(url);

      final responseData = response.body.isNotEmpty
          ? json.decode(response.body)
          : {};

      if (response.statusCode == 200) {
        if (responseData['success'] == true ||
            responseData['status'] == 'success') {
          return 'Success';
        }

        return responseData['message']?.toString() ?? 'Failed to drop course.';
      }

      return responseData['message']?.toString() ??
          'Server returned error: ${response.statusCode}';
    } catch (e) {
      return 'Failed to connect to server: $e';
    }
  }
}
