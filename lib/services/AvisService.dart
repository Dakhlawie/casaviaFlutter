import 'dart:convert';
import 'package:casavia/model/avis.dart';
import 'package:http/http.dart' as http;
import 'dart:core';

class AvisService {
  final String baseUrl = 'http://192.168.1.17:3000/avis';
  Future<bool> hasUserLeftReview(int hebergementId, int userId) async {
    final url = Uri.parse(
        '$baseUrl/avis/hasUserLeftReview?hebergementId=$hebergementId&userId=$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    } else {
      throw Exception('Failed to check if user has left a review');
    }
  }

  Future<List<Avis>> fetchAvisByHebergement(int hebergementId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/Hebergement/$hebergementId'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Avis.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load avis');
    }
  }

  Future<Avis> ajouterAvis(Avis avis, int hebergementId, int userId) async {
    final url = Uri.parse('$baseUrl/save?id=$hebergementId&user=$userId');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(avis.toJson()),
    );

    if (response.statusCode == 200) {
      return Avis.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to save avis');
    }
  }

  Future<List<Avis>> fetchAvis() async {
    print("Début de la récupération des avis...");
    final response =
        await http.get(Uri.parse('http://192.168.1.17:3000/avis/all'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);

      List<Avis> avisList =
          jsonResponse.map((data) => Avis.fromJson(data)).toList();

      return avisList;
    } else {
      throw Exception('Failed to load avis');
    }
  }

  Future<Map<String, double>> getReviewsByHebergement(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/hebergement/$id'));

    if (response.statusCode == 200) {
      Map<String, dynamic> reviewsJson = json.decode(response.body);
      Map<String, double> reviews = reviewsJson
          .map((key, value) => MapEntry(key, (value ?? 0 as num).toDouble()));
      return reviews;
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  Future<List<Avis>> findTopAvisHebergement(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/top?id=$id'));

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      List<Avis> avisList =
          body.map((dynamic item) => Avis.fromJson(item)).toList();
      return avisList;
    } else {
      throw Exception('Failed to load top avis');
    }
  }

  Future<List<Avis>> fetchAvisByUserId(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/avis/user/$userId'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Avis> avisList =
          body.map((dynamic item) => Avis.fromJson(item)).toList();
      return avisList;
    } else {
      throw Exception('Failed to load avis');
    }
  }
}
