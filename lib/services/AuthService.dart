import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String BASE_URL = "http://192.168.1.17:3000/";
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('http://192.168.1.17:3000/user/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'mot_de_passe': password,
      }),
    );

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.headers['content-type']!.contains('application/json')) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      print('Response data: $responseData');
    } else {
      print('Response body: ${response.body}');
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final token = responseData['token'];
      await _saveToken(token);
      return {'success': true};
    } else {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final errorMessage = responseData['message'];
      return {'success': false, 'message': errorMessage};
    }
  }

  Future<void> _saveToken(String token) async {
    print('Token to save: $token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<Map<String, dynamic>?> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? '';

    if (token.isNotEmpty) {
      try {
        Map<String, dynamic> payload = Jwt.parseJwt(token);
        print("User Details: $payload");
        return payload;
      } catch (e) {
        print("Erreur lors de la décodage du token: $e");
        return null;
      }
    } else {
      print("Aucun token trouvé");
      return null;
    }
  }

  Future<int?> getUserIdFromToken() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? '';
    print('Hello');
    print(token);

    if (token == null) return null;

    try {
      Map<String, dynamic> payload = Jwt.parseJwt(token);

      var dataMap = payload['data'] as Map<String, dynamic>;
      print('DATAMAP');
      print(dataMap);
      return dataMap['user_id'];
    } catch (e) {
      print('Error parsing JWT: $e');
      return null;
    }
  }

  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    print('Token deleted successfully');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null;
  }
}
