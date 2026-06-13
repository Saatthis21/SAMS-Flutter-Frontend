import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api.dart';
import '../domain/entities/LabSection.dart';

class GetCourseLabs {
  Future<List<LabSection>> execute(String courseCode) async {
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