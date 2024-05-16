import 'dart:convert';
import 'package:casavia/model/like.dart';
import 'package:http/http.dart' as http;

class LikeService {
  final String baseUrl = "http://192.168.1.17:3000/like";

  Future<List<Like>> getLikesByUser(int userId) async {
    var url = Uri.parse('$baseUrl/getByUser/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> likesJson = jsonDecode(response.body) as List<dynamic>;
        return likesJson.map((json) => Like.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load likes for user: Server returned ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load likes for user: $e');
    }
  }

  Future<Like> addLike(int userId, int hebergementId) async {
    final uri = Uri.parse('$baseUrl/save').replace(queryParameters: {
      'userId': userId.toString(),
      'hebergementId': hebergementId.toString(),
    });
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return Like.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add like');
    }
  }

  Future<bool> checkLikeForUserAndHebergement(int user, int hebergement) async {
    final url = 'http://192.168.1.17:3000/like/findByUserHebergement';
    final response = await http.get(
      Uri.parse('$url?user=$user&hebergement=$hebergement'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur: ${response.statusCode}');
    }
  }

  Future<void> deleteLikeByUserAndHebergement(
      int userId, int hebergementId) async {
    final url = 'http://192.168.1.17:3000/like/deleteByUserHebergement';

    final response = await http.delete(
      Uri.parse(url),
      body: {
        'user': userId.toString(),
        'hebergement': hebergementId.toString(),
      },
    );
    print(response);
    if (response.statusCode == 200) {
      print('Deleted successfully');
    } else {
      print('Failed to delete: ${response.statusCode}');
    }
  }
}
