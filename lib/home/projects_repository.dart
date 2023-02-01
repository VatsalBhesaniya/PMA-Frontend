import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pma/models/project.dart';

class ProjectsRepository {
  static const String _baseUrl = 'http://10.0.2.2:8000/';
  final String _projectsUrl = '${_baseUrl}projects';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<List<Project>?> fetchProjects() async {
    final String? token = await _storage.read(key: 'token');
    final http.Response response = await http.get(
      Uri.parse(_projectsUrl),
      headers: <String, String>{
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse =
          jsonDecode(response.body) as List<dynamic>;
      final List<Project> projects = jsonResponse
          .map((dynamic project) =>
              Project.fromJson(project as Map<String, dynamic>))
          .toList();
      return projects;
    } else {
      return null;
    }
  }
}
