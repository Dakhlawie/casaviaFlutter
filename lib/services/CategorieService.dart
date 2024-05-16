
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/categorie.dart';

class CategorieService {
  final String baseUrl = "http://192.168.1.17:3000/categorie";

  Future<List<Categorie>> getAllCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/all'));

    if (response.statusCode == 200) {
      List<dynamic> categoriesJson = jsonDecode(response.body);
      return categoriesJson.map((json) => Categorie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }
}
