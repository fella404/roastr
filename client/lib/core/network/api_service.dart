import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import 'storage_service.dart';

class ApiService {
  final StorageService _storage;

  ApiService(this._storage);

  String? get _token => _storage.getToken();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(String path, {Object? body}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final response = await http.post(uri, headers: _headers, body: body != null ? jsonEncode(body) : null);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(String path, {Object? body}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final response = await http.put(uri, headers: _headers, body: body != null ? jsonEncode(body) : null);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final response = await http.delete(uri, headers: _headers);
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body is Map<String, dynamic> ? body : {'data': body};
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: body['message'] ?? 'Terjadi kesalahan',
    );
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => '$statusCode: $message';
}
