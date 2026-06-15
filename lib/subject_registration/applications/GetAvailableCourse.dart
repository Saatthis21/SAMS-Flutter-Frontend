import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api.dart';
import '../domain/entities/Course.dart';
import '../domain/entities/LabSection.dart';

class GetAvailableCourse {
  Future<List<Course>> execute() async {
    try {
      // 1. Call the Laravel endpoint
      final url = Uri.parse('${ApiConfig.baseUrl}/courses'); // Ensure you have this route in api.php!
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // 2. If successful, convert the JSON from the database into Flutter Course objects
        if (responseData['success'] == true) {
          List<dynamic> courseData = responseData['data'];
          
          return courseData.map((json) => Course(
            // NOTE: Make sure these match your exact variable names in Course.dart!
            courseCode: json['course_code'],
            courseName: json['course_name'],
            creditHours: json['credit_hours'], 
          )).toList();
        }
      }
      return []; // Return an empty list if the server sends an error
      
    } catch (e) {
      print("Error fetching courses: $e");
      return [];
    }
  }

  Future<List<LabSection>> executeFetchLabs(String courseCode) async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/courses/$courseCode/labs'));

      if (response.statusCode == 200) {
        // --- ADD THIS LINE TO DEBUG ---
        print("RAW LARAVEL DATA: ${response.body}"); 
        
        List<dynamic> jsonList = json.decode(response.body)['data'];
        return jsonList.map((json) => LabSection.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load labs');
      }
    } catch (e) {
      throw Exception('Error fetching labs: $e');
    }
  }
}