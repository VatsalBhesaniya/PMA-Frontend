import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pma/models/task.dart';

class TaskRepository {
  static const String _baseUrl = 'http://10.0.2.2:8000/';
  final String _tasksUrl = '${_baseUrl}tasks';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Task?> fetchTask({
    required int taskId,
  }) async {
    final String? token = await _storage.read(key: 'token');
    final http.Response response = await http.get(
      Uri.parse('$_tasksUrl/$taskId'),
      headers: <String, String>{
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse =
          jsonDecode(response.body) as Map<String, dynamic>;
      final Task task = Task.fromJson(jsonResponse);
      return task;
    } else {
      return null;
    }
  }
}
