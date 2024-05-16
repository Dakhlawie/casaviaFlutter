import 'package:casavia/model/historique.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistoriqueService {
  final String baseUrl = "http://192.168.1.17:3000/historique";

  Future<Historique?> ajouterHistorique(
      int userId, Historique historiqueData) async {
    String url = '$baseUrl/save?user=$userId';
    try {
      var response = await http.post(
        Uri.parse(url),
        body: json.encode(historiqueData.toJson()),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        print("Historique ajouté avec succès");
        return Historique.fromJson(json.decode(response.body));
      } else {
        print('Erreur: ${response.body}');
      }
    } catch (e) {
      print('Exception lors de l\'ajout de l\'historique: $e');
    }
    return null;
  }

  Future<List<Historique>> getHistoriqueByUser(int userId) async {
    print("hello");
    String url = '$baseUrl/getByUser?user=$userId';
    try {
      var response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        print('hi');
        var data = json.decode(response.body) as List;
        List<Historique> historiques =
            data.map((item) => Historique.fromJson(item)).toList();
        print(historiques);
        return historiques;
      } else {
        print('Erreur: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Exception lors de la récupération des historiques: $e');
      return [];
    }
  }

  Future<void> deleteAllHistoriquesByUser(int userId) async {
    String url = '$baseUrl/deleteAll?user=$userId';
    try {
      var response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        print("Historiques supprimés avec succès");
      } else {
        print('Erreur: ${response.body}');
      }
    } catch (e) {
      print('Exception lors de la suppression des historiques: $e');
    }
  }
}
