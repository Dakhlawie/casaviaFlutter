import 'package:casavia/model/chambre.dart';
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
}
