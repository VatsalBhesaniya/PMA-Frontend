import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class UserRepository {
  static const String baseUrl = 'http://10.0.2.2:8000/';
  final String loginUrl = '${baseUrl}login';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // getUser

  // hasToken
  Future<bool> hasToken() async {
    final String? token = await _storage.read(key: 'token');
    return token != null;
  }

  // persistToken
  Future<void> persistToken(String token) async {
    _storage.write(key: 'token', value: token);
  }

  // deleteToken
  Future<void> deleteToken() async {
    _storage.delete(key: 'token');
    _storage.deleteAll();
  }

  //login
  Future<String?> login(
      {required String email, required String password}) async {
    final http.Response response = await http.post(Uri.parse(loginUrl), body: {
      'username': 'bhesaniyavatsal@gmail.com',
      'password': '1234',
    });
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse =
          jsonDecode(response.body) as Map<String, dynamic>;
      final String token = jsonResponse['access_token'] as String;
      return token;
    } else {
      return null;
    }
  }
}
