import 'dart:convert';
import 'package:casavia/model/chambre.dart';
import 'package:casavia/model/equipement.dart';
import 'package:casavia/model/hebergement.dart';
import 'package:casavia/model/language.dart';
import 'package:http/http.dart' as http;

class HebergementService {
  Future<List<Hebergement>> fetchHebergementsWithImages() async {
    final hebergementsUrl =
        Uri.parse('http://192.168.1.17:3000/hebergement/all');
    final hebergementsResponse = await http.get(hebergementsUrl);

    if (hebergementsResponse.statusCode == 200) {
      final List<dynamic> hebergementsJsonList =
          json.decode(hebergementsResponse.body);

      List<Hebergement> hebergements = [];

      for (var hebergementJson in hebergementsJsonList) {
        if (hebergementJson != null) {
          Hebergement hebergement = Hebergement.fromJson(hebergementJson);

          hebergements.add(hebergement);
        } else {
          print(hebergementJson);
        }
      }
      for (var hebergement in hebergements) {
        print(hebergement.nom);
      }
      return hebergements;
    } else {
      throw Exception('Failed to load hebergements');
    }
  }

  Future<List<int>?> getImageBytesForChambre(int id) async {
    final imageUrl =
        Uri.parse('http://192.168.1.17:3000/api/image/loadfromFSChambre/$id');
    final imageResponse = await http.get(imageUrl);

    if (imageResponse.statusCode == 200) {
      return imageResponse.bodyBytes;
    } else {
      return null;
    }
  }

  Future<List<Hebergement>> searchHebergements(String terme) async {
    final searchUrl =
        Uri.parse('http://192.168.1.17:3000/hebergement/search?terme=$terme');
    final searchResponse = await http.get(searchUrl);

    if (searchResponse.statusCode == 200) {
      final List<dynamic> hebergementsJsonList =
          json.decode(searchResponse.body);

      List<Hebergement> hebergements = [];

      for (var hebergementJson in hebergementsJsonList) {
        if (hebergementJson != null) {
          Hebergement hebergement = Hebergement.fromJson(hebergementJson);
          hebergements.add(hebergement);
        } else {
          print(hebergementJson);
        }
      }
      for (var hebergement in hebergements) {
        print(hebergement.nom);
      }
      return hebergements;
    } else {
      throw Exception('Failed to search hebergements');
    }
  }

  Future<List<Hebergement>> findByVilleAndCategorie(
      String ville, int id) async {
    var uri =
        Uri.http('192.168.1.17:3000', '/hebergement/findByCategorieVille', {
      'ville': ville,
      'id': id.toString(),
    });

    try {
      var response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);

        return jsonResponse
            .map((model) => Hebergement.fromJson(model))
            .toList();
      } else {
        throw Exception('Failed to load hebergements');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  Future<bool> checkAvailability(
      int chambreId, String checkIn, String checkOut) async {
    var uri = Uri.http('192.168.1.17:3000', '/dates/dispo/$chambreId', {
      'checkIn': checkIn,
      'checkOut': checkOut,
    });

    try {
      var response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );
      print('Available');
      print(response.body);
      if (response.statusCode == 200) {
        return json.decode(response.body) as bool;
      } else {
        throw Exception(
            'Failed to check room availability: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  Future<bool> checkAvailabilityHebergement(
      int hebergementId, String checkIn, String checkOut) async {
    var uri = Uri.http(
        '192.168.1.17:3000', '/dates/hebergement/dispo/$hebergementId', {
      'checkIn': checkIn,
      'checkOut': checkOut,
    });

    try {
      var response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as bool;
      } else {
        throw Exception(
            'Failed to check hebergement availability: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  Future<List<Hebergement>> fetchAvailableHebergements(
      String ville, int categoryId, String checkIn, String checkOut) async {
    try {
      List<Hebergement> allHebergements =
          await findByVilleAndCategorie(ville, categoryId);
      print('hhhhhh');
      print(allHebergements.length);
      List<Hebergement> availableHebergements = [];

      for (Hebergement hebergement in allHebergements) {
        if (hebergement.chambres != null && hebergement.chambres.isNotEmpty) {
          bool isAvailable = false;

          for (Chambre chambre in hebergement.chambres) {
            print('CHAMBRES');
            print(chambre.chambreId);
            if (await checkAvailability(chambre.chambreId, checkIn, checkOut)) {
              isAvailable = true;
              break;
            }
          }

          if (isAvailable) {
            availableHebergements.add(hebergement);
          }
        }
      }
      print('AVAILABLE HEBERGEMENT');
      print(availableHebergements);
      return availableHebergements;
    } catch (e) {
      throw Exception('Failed to process hebergements: $e');
    }
  }

  Future<List<Hebergement>> fetchAvailable(
      String ville, int categoryId, String checkIn, String checkOut) async {
    try {
      List<Hebergement> allHebergements =
          await findByVilleAndCategorie(ville, categoryId);
      print('Total hebergements fetched: ${allHebergements.length}');
      List<Hebergement> availableHebergements = [];

      for (Hebergement hebergement in allHebergements) {
        if (await checkAvailabilityHebergement(
            hebergement.hebergementId, checkIn, checkOut)) {
          availableHebergements.add(hebergement);
          print('Hebergement available: ${hebergement.hebergementId}');
        } else {
          print('Hebergement not available: ${hebergement.hebergementId}');
        }
      }

      return availableHebergements;
    } catch (e) {
      throw Exception('Failed to process hebergements: $e');
    }
  }

  Future<List<Equipement>> getEquipements(int hebergementId) async {
    final response = await http.get(
      Uri.parse(
          'http://192.168.1.17:3000/hebergement/equipements?hebergement=$hebergementId'),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Equipement> equipements =
          body.map((dynamic item) => Equipement.fromJson(item)).toList();
      print(equipements);
      return equipements;
    } else {
      throw Exception('Failed to load equipements');
    }
  }

  Future<List<Equipement>> getByCategorieHebregement(
      int categorie, int hebergement) async {
    final Uri uri = Uri.parse(
        'http://192.168.1.17:3000/equipement/findByCategorieHebregement?categorie=$categorie&hebergement=$hebergement');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      Iterable jsonResponse = json.decode(response.body);
      return jsonResponse.map((e) => Equipement.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load equipements');
    }
  }

  Future<List<Language>> getLanguagesByHebergementId(int hebergementId) async {
  
    final String baseUrl = 'http://192.168.1.17:3000/hebergement';
    final String url = '$baseUrl/$hebergementId/languages';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Language.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load languages');
    }
  }
}
