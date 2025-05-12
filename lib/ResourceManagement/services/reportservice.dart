
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sweetmanager/ResourceManagement/models/report.dart';
import 'package:sweetmanager/IAM/services/auth_service.dart'; // Ensure you import your AuthService class

class ReportService {
  final String baseUrl = 'https://sweetmanager-api.ryzeon.me/api';
  final authService = AuthService();

  // Helper method to get the headers with token
  Future<Map<String, String>> _getHeaders() async {
    final token = await authService.storage.read(key: 'token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get all reports
  Future<List<dynamic>> getReports(int hotelId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/reports?hotelId=$hotelId'),
      headers: headers,
    );
        print('response status: ${response.statusCode}');
    print(' response body: ${response.body}');


    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load reports');
    }
  }

  // Get a report by ID
  Future<Report> getReportById(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/reports/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return Report.fromJson(json.decode(response.body)); // Ensure Report.fromJson exists
    } else {
      throw Exception('Failed to load report');
    }
  }

  // Create a new report, optionally with an image
  Future<dynamic> createReport(Map<String, dynamic> report, String? base64Image) async {
  final headers = await _getHeaders();
  final uri = Uri.parse('$baseUrl/reports/create');

  // Assign the Base64 image to the 'fileUrl' key if not null
  if (base64Image != null) {
    report['fileUrl'] = base64Image;
  }

  // Print for debugging
  print("Report Data: $report");
  print("Headers: $headers");

  final response = await http.post(
    uri,
    headers: headers,
    body: jsonEncode(report),
  );

  if (response.statusCode == 201) {
    return json.decode(response.body);
  } else {
    print("Error: ${response.body}");
    throw Exception('Failed to create report');
  }
}



}
