import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sweetmanager/ResourceManagement/models/typereport.dart';
import 'package:sweetmanager/IAM/services/auth_service.dart'; // AuthService import

class TypesReportService {
  final String baseUrl = 'https://sweetmanager-api.ryzeon.me/api';
  final authService = AuthService();// AuthService dependency

  TypesReportService();

  // Helper method to get headers with token
  Future<Map<String, String>> _getHeaders() async {
    final token = await authService.storage.read(key: 'token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Add Bearer token to authorization header
    };
  }

  // Fetch all types of reports
  Future<List<TypesReport>> fetchTypesReports() async {
    final headers = await _getHeaders(); // Fetch headers with token
    final response = await http.get(
      Uri.parse('$baseUrl/types-reports'), // Ensure the endpoint is correct
      headers: headers, // Send headers with the request
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<TypesReport> typesReports = body
          .map((dynamic item) => TypesReport.fromJson(item))
          .toList();
      return typesReports;
    } else {
      throw Exception('Failed to load types of reports');
    }
  }

}
