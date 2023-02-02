import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pma/models/document.dart';

class DocumentRepository {
  static const String _baseUrl = 'http://10.0.2.2:8000/';
  final String _documentsUrl = '${_baseUrl}documents';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Document?> fetchDocument({
    required int documentId,
  }) async {
    final String? token = await _storage.read(key: 'token');
    final http.Response response = await http.get(
      Uri.parse('$_documentsUrl/$documentId'),
      headers: <String, String>{
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse =
          jsonDecode(response.body) as Map<String, dynamic>;
      final Document document = Document.fromJson(jsonResponse);
      return document;
    } else {
      return null;
    }
  }
}
