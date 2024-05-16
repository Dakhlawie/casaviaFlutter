import 'package:casavia/model/categorieEquipement.dart';
import 'package:casavia/model/equipement.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EquipementService {
  Future<List<CategorieEquipement>> getAllCategorieEquipement() async {
    var url = Uri.parse('http://192.168.1.17:3000/categorie_equipement/all');
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonList = json.decode(response.body) as List;
        List<CategorieEquipement> categories = jsonList
            .map((jsonItem) => CategorieEquipement.fromJson(jsonItem))
            .toList();
        return categories;
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }
   Future<List<CategorieEquipement>> getCategoriesOfEquipementsByHebergementId(int hebergementId) async {
    final url = Uri.parse('http://192.168.1.17:3000/hebergement/$hebergementId/categories'); 
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CategorieEquipement.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<Equipement>> getEquipementsByCategorieHebregement(
    int categorieId,
    int hebergementId,
  ) async {
    final String baseUrl = 'http://192.168.1.17:3000/equipement';

    final url = Uri.parse(
        '$baseUrl/findByCategorieHebregement?categorie=$categorieId&hebergement=$hebergementId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;

      final equipements =
          data.map((equipment) => Equipement.fromJson(equipment)).toList();

      return equipements;
    } else {
      throw Exception('Failed to fetch equipements: ${response.statusCode}');
    }
  }
  
  Future<CategorieEquipement> getCategoryByNom(String nom) async {
    try {
      var url = Uri.parse('http://192.168.1.17:3000/categorie_equipement/nom?nom=$nom');
      var response = await http.get(url);

      if (response.statusCode == 200) {
     
        return CategorieEquipement.fromJson(jsonDecode(response.body));
      } else {

        throw Exception('Failed to load category');
      }
    } catch (e) {
      throw Exception('Failed to load category: $e');
    }
  }
}

