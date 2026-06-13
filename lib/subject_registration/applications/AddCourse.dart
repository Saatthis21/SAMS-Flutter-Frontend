import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api.dart'; 

class AddCourse {
  // We changed Future<bool> to Future<String> right here!
  Future<String> execute(String studentID, String courseCode, int labID) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/add-course'), // <-- PUT YOUR REAL API ROUTE HERE
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'studentID': studentID, 
          'course_code': courseCode,
          'labID': labID,
        }),
      );

      // We decode the data no matter what the status code is
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return "Success";
      } else {
        // Now this will correctly catch the 400 and 500 errors!
        return data['message'] ?? "Server Error: ${response.statusCode}";
      }
    } catch (e) {
      return "App Error: $e";
    }
  }
}