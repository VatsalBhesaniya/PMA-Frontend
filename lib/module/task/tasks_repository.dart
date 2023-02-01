import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pma/models/task.dart';

class TasksRepository {
  static const String _baseUrl = 'http://10.0.2.2:8000/';
  final String _tasksUrl = '${_baseUrl}tasks';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<List<Task>?> fetchTasks() async {
    final String? token = await _storage.read(key: 'token');
    final http.Response response = await http.get(
      Uri.parse(_tasksUrl),
      headers: <String, String>{
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse =
          jsonDecode(response.body) as List<dynamic>;
      final List<Task> tasks = jsonResponse
          .map((dynamic task) => Task.fromJson(task as Map<String, dynamic>))
          .toList();
      return tasks;
    } else {
      return null;
    }
  }
}
