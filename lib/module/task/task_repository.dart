import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pma/models/document.dart';
import 'package:pma/models/note.dart';
import 'package:pma/models/task.dart';

class TaskRepository {
  static const String _baseUrl = 'http://10.0.2.2:8000/';
  final String _tasksUrl = '${_baseUrl}tasks';
  final String _notesUrl = '${_baseUrl}notes';
  final String _documentsUrl = '${_baseUrl}documents';
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

  Future<List<Note>?> fetchAttachedNotes({
    required List<int> noteIds,
  }) async {
    final String? token = await _storage.read(key: 'token');
    String queryParams = noteIds.isEmpty ? '' : '?';
    for (final int id in noteIds) {
      queryParams += 'noteId=$id&';
    }
    final http.Response response = await http.get(
      Uri.parse('$_notesUrl/attached$queryParams'),
      headers: <String, String>{
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse =
          jsonDecode(response.body) as List<dynamic>;
      final List<Note> notes = jsonResponse
          .map((dynamic note) => Note.fromJson(note as Map<String, dynamic>))
          .toList();
      return notes;
    } else {
      return null;
    }
  }

  Future<List<Document>?> fetchAttachedDocuments({
    required List<int> documentIds,
  }) async {
    final String? token = await _storage.read(key: 'token');
    String queryParams = documentIds.isEmpty ? '' : '?';
    for (final int id in documentIds) {
      queryParams += 'documentId=$id&';
    }

    final http.Response response = await http.get(
      Uri.parse('$_documentsUrl/attached$queryParams'),
      headers: <String, String>{
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse =
          jsonDecode(response.body) as List<dynamic>;
      final List<Document> documents = jsonResponse
          .map((dynamic document) =>
              Document.fromJson(document as Map<String, dynamic>))
          .toList();
      return documents;
    } else {
      return null;
    }
  }
}
