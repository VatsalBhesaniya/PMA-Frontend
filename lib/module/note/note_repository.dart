import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pma/models/note.dart';

class NoteRepository {
  static const String _baseUrl = 'http://10.0.2.2:8000/';
  final String _notesUrl = '${_baseUrl}notes';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Note?> fetchNote({
    required int noteId,
  }) async {
    final String? token = await _storage.read(key: 'token');
    final http.Response response = await http.get(
      Uri.parse('$_notesUrl/$noteId'),
      headers: <String, String>{
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse =
          jsonDecode(response.body) as Map<String, dynamic>;
      final Note note = Note.fromJson(jsonResponse);
      return note;
    } else {
      return null;
    }
  }

  Future<Note?> updateNote({
    required Note note,
  }) async {
    final String body = jsonEncode(note.toJson()..remove('id'));
    final String? token = await _storage.read(key: 'token');
    final http.Response response = await http.put(
      Uri.parse('$_notesUrl/${note.id}'),
      headers: <String, String>{
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: body,
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse =
          jsonDecode(response.body) as Map<String, dynamic>;
      final Note note = Note.fromJson(jsonResponse);
      return note;
    } else {
      return null;
    }
  }
}
