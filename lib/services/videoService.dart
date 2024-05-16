import 'package:casavia/model/video.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VideoService {
  Future<Video?> getVideoByHebergementId(int idHeber) async {
    try {
      final response = await http.get(
          Uri.parse('http://192.168.1.17:3000/video/getVideoHeber/$idHeber'));

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        if (jsonBody != null) {
          return Video.fromJson(jsonBody);
        } else {
          return null;
        }
      } else {
        throw Exception('Failed to load video');
      }
    } catch (e) {
      throw Exception('Failed to connect to the API: $e');
    }
  }
}
