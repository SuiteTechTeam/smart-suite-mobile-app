import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';
import '../../core/core.dart';

class HttpService {
  final StorageService _storageService;
  final http.Client _httpClient;

  HttpService({required StorageService storageService, http.Client? httpClient})
    : _storageService = storageService,
      _httpClient = httpClient ?? http.Client();

  Future<Map<String, String>> _getHeaders() async {
    return await _storageService.getAuthHeaders();
  }

  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('${AppConfig.smartSuiteApiBaseUrl}/$endpoint');

    return await _httpClient.get(uri, headers: headers);
  }

  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('${AppConfig.smartSuiteApiBaseUrl}/$endpoint');

    return await _httpClient.post(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('${AppConfig.smartSuiteApiBaseUrl}/$endpoint');

    return await _httpClient.put(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('${AppConfig.smartSuiteApiBaseUrl}/$endpoint');

    return await _httpClient.delete(uri, headers: headers);
  }

  void dispose() {
    _httpClient.close();
  }
}
