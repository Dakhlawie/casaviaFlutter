import 'package:casavia/model/chambre.dart';
import 'package:casavia/model/equipement.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChambresServices {
  Future<bool> checkAvailability(
      Chambre chambre, String checkIn, String checkOut) async {
    var url = Uri.parse('http://192.168.1.17:3000/dates/dispo');
    var response = await http.post(url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'chambre': chambre.toJson(),
          'checkIn': checkIn,
          'checkOut': checkOut,
        }));

    if (response.statusCode == 200) {
      return json.decode(response.body) as bool;
    } else {
      throw Exception('Failed to check availability: ${response.body}');
    }
  }

  Future<Chambre> getChambreById(int id) async {
    final response =
        await http.get(Uri.parse('http://192.168.1.17:3000/chambre/$id'));

    if (response.statusCode == 200) {
      return Chambre.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load chambre');
    }
  }

  Future<List<Equipement>> getEquipements(int chambreId) async {
    var url =
        Uri.parse('http://192.168.1.17:3000/chambre/equipements/$chambreId');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> equipementsJson = json.decode(response.body);
      return equipementsJson.map((json) => Equipement.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load equipements: ${response.body}');
    }
  }
}
