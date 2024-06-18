import 'package:casavia/model/hebergement.dart';


import 'package:http/http.dart' as http;
import 'dart:convert';
class UserPositionService {
  // Future<Position> getCurrentPosition() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;

  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     return Future.error('Location services are disabled.');
  //   }

  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       return Future.error('Location permissions are denied');
  //     }
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     return Future.error(
  //         'Location permissions are permanently denied, we cannot request permissions.');
  //   }
 
  //   return await Geolocator.getCurrentPosition();
  // }

Future<List<Hebergement>> sendLocationToBackend(
      double latitude, double longitude) async {
    final response = await http.post(
      Uri.parse('http://192.168.1.17:3000/hebergement/nearby-hebergements'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      }),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      List<Hebergement> hebergements = jsonResponse
          .map<Hebergement>((data) => Hebergement.fromJson(data))
          .toList();
      return hebergements;
    } else {
     
      print('Erreur: ${response.statusCode}');
      return [];
    }
  }
}
