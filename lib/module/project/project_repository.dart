import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pma/models/project.dart';

class ProjectRepository {
  static const String _baseUrl = 'http://10.0.2.2:8000/';
  final String _projectUrl = '${_baseUrl}projects';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Project?> fetchProject({
    required int projectId,
  }) async {
    final String? token = await _storage.read(key: 'token');
    final http.Response response = await http.get(
      Uri.parse('$_projectUrl/$projectId'),
      headers: <String, String>{
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse =
          jsonDecode(response.body) as Map<String, dynamic>;
      final Project project = Project.fromJson(jsonResponse);
      return project;
    } else {
      return null;
    }
  }
}
