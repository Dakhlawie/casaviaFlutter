import 'dart:convert';
import 'package:casavia/model/avis.dart';
import 'package:http/http.dart' as http;


class AvisService {
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
}
