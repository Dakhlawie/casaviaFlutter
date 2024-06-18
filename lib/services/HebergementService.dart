import 'dart:convert';
import 'package:casavia/model/chambre.dart';
import 'package:casavia/model/equipement.dart';
import 'package:casavia/model/hebergement.dart';
import 'package:casavia/model/language.dart';
import 'package:casavia/model/offre.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HebergementService {
  final String baseUrl = 'http://192.168.1.17:3000/hebergement';
  Future<double> convertPriceToTND(double amount, String currency) async {
    final response = await http.get(
      Uri.parse('$baseUrl/convertToTND?amount=$amount&currency=$currency'),
    );

    if (response.statusCode == 200) {
      return double.parse(response.body);
    } else {
      throw Exception('Failed to convert currency');
    }
  }

  Future<double> convertPrice(
      double price, String sourceCurrency, String targetCurrency) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/currency/convert?price=$price&sourceCurrency=$sourceCurrency&targetCurrency=$targetCurrency'),
    );
    print('Bileli');
    print(response.statusCode);
    if (response.statusCode == 200) {
      return double.parse(response.body);
    } else {
      throw Exception('Failed to convert currency');
    }
  }

  Future<int> getAvailableRooms(
      int chambreId, String checkIn, String checkOut) async {
    final url = Uri.parse(
        'http://192.168.1.17:3000/dates/availableRooms?chambreId=$chambreId&checkIn=$checkIn&checkOut=$checkOut');
    final response = await http.get(url);
    print(response.statusCode);
    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else {
      throw Exception('Failed to load available rooms');
    }
  }

  Future<Hebergement> convertHebergement(
      Hebergement hebergement, String targetCurrency) async {
    final url = Uri.parse(
        '$baseUrl/currency/convertHebergementPrices?targetCurrency=$targetCurrency');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(hebergement.toJson()),
    );

    if (response.statusCode == 200) {
      return Hebergement.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to convert hebergement prices');
    }
  }

  Future<void> updateHebergementMoyenne({
    required int id,
    required int staff,
    required int location,
    required int comfort,
    required int facilities,
    required int cleanliness,
    required int security,
    required double moyenne,
    required int nbAvis, // Ajouter nbAvis ici
  }) async {
    final String url = 'http://192.168.1.17:3000/hebergement/$id/updateMoyenne';

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'staff': staff.toString(),
        'location': location.toString(),
        'comfort': comfort.toString(),
        'facilities': facilities.toString(),
        'cleanliness': cleanliness.toString(),
        'security': security.toString(),
        'moyenne': moyenne.toString(),
        'nbAvis': nbAvis.toString(),
      },
    );

    if (response.statusCode == 200) {
      print('Hebergement updated successfully');
    } else {
      throw Exception('Failed to update hebergement');
    }
  }

  Future<double> calculateDiscountedPrice(double price, int discount) async {
    final url = Uri.parse(
        '$baseUrl/calculateDiscountedPrice?price=$price&discount=$discount');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return double.parse(response.body);
    } else {
      throw Exception('Failed to load discounted price');
    }
  }

  Future<List<OffreHebergement>> getOffersByHebergementId(
      int hebergementId) async {
    final response = await http.get(Uri.parse('$baseUrl/offre/$hebergementId'));

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      List<OffreHebergement> offers =
          body.map((dynamic item) => OffreHebergement.fromJson(item)).toList();
      return offers;
    } else {
      throw Exception('Failed to load offers');
    }
  }

  Future<List<Hebergement>> findHebergementsWithoutAvisByUser(
      int userId) async {
    final url = Uri.parse(
        'http://192.168.1.17:3000/hebergement/withoutAvis?id=$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Hebergement.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load hebergements');
    }
  }

  Future<List<Hebergement>> fetchHebergementsWithOffers(int userId) async {
    final response = await http.get(Uri.parse(
        'http://192.168.1.17:3000/hebergement/withOffers?userId=$userId'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((hebergement) => Hebergement.fromJson(hebergement))
          .toList();
    } else {
      throw Exception('Failed to load hebergements with offers');
    }
  }

  Future<List<Hebergement>> fetchHebergementsWithOffersByCurrency(
      int userId, String targetCurrency) async {
    final response = await http.get(Uri.parse(
        'http://192.168.1.17:3000/hebergement/withOffersByCurrency?userId=$userId&targetCurrency=$targetCurrency'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((hebergement) => Hebergement.fromJson(hebergement))
          .toList();
    } else {
      throw Exception('Failed to load hebergements with offers by currency');
    }
  }

  Future<List<Hebergement>> fetchHebergementsWithOffersBasedOnCurrency(
      int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final storedCurrency = prefs.getString('selectedCurrency');

    if (storedCurrency != null) {
      return fetchHebergementsWithOffersByCurrency(userId, storedCurrency);
    } else {
      return fetchHebergementsWithOffers(userId);
    }
  }

  Future<List<Hebergement>> findHebergementsByChambrePriceRange(
      List<Hebergement> hebergements, double minPrice, double maxPrice) async {
    final url = Uri.parse('$baseUrl/prixChambre');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'hebergements': hebergements.map((e) => e.toJson()).toList(),
        'minPrice': minPrice,
        'maxPrice': maxPrice,
      }),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      List<dynamic> responseJson = jsonDecode(response.body);
      return responseJson.map((json) => Hebergement.fromJson(json)).toList();
    } else {
      throw Exception('Failed to filter hebergements by price range');
    }
  }

  Future<List<Hebergement>> fetchTopHebergements() async {
    final response = await http
        .get(Uri.parse('http://192.168.1.17:3000/hebergement/topHebergement'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((hebergement) => Hebergement.fromJson(hebergement))
          .toList();
    } else {
      throw Exception('Failed to load top hebergements');
    }
  }

  Future<List<Hebergement>> fetchTopHebergementsByCurrency(
      String targetCurrency) async {
    final response = await http.post(
      Uri.parse(
          'http://192.168.1.17:3000/hebergement/topHebergementByCurrency'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'currency': targetCurrency,
      }),
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((hebergement) => Hebergement.fromJson(hebergement))
          .toList();
    } else {
      throw Exception('Failed to load top hebergements by currency');
    }
  }

  Future<List<Hebergement>> convertHebergementPrices(
      List<Hebergement> hebergements, String targetCurrency) async {
    final url = Uri.parse('$baseUrl/convertPrices');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'hebergements': hebergements.map((e) => e.toJson()).toList(),
      'targetCurrency': targetCurrency,
    });

    print('Request Body: $body');

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      List<dynamic> responseJson = json.decode(response.body);
      return responseJson.map((json) => Hebergement.fromJson(json)).toList();
    } else {
      print('Failed to convert prices: ${response.body}');
      throw Exception('Failed to convert prices');
    }
  }

  Future<Map<String, double>> convertPriceRange(double minPrice,
      double maxPrice, String sourceCurrency, String targetCurrency) async {
    final url = Uri.parse('$baseUrl/convertPriceRange');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'sourceCurrency': sourceCurrency,
        'targetCurrency': targetCurrency,
      }),
    );
    print('*********************************************');
    print(response.statusCode);
    if (response.statusCode == 200) {
      return Map<String, double>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to convert prices');
    }
  }

  Future<List<Hebergement>> findOtherHebergementsByOverallAverage(
      List<Hebergement> hebergements,
      double overallAverage,
      double upperBound) async {
    final url = Uri.parse('$baseUrl/other/OverallAverage');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'hebergements':
            hebergements.map((hebergement) => hebergement.toJson()).toList(),
        'overallAverage': overallAverage,
        'upperBound': upperBound,
      }),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => Hebergement.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load hebergements');
    }
  }

  Future<List<Hebergement>> sortOtherHebergementsByMoyenneAsc(
      List<Hebergement> hebergements) async {
    final url = Uri.parse('$baseUrl/other/sortByMoyenneAsc');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          hebergements.map((hebergement) => hebergement.toJson()).toList()),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => Hebergement.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load sorted hebergements');
    }
  }

  Future<List<Hebergement>> sortOtherHebergementsByMoyenneDesc(
      List<Hebergement> hebergements) async {
    final url = Uri.parse('$baseUrl/other/sortByMoyenneDesc');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          hebergements.map((hebergement) => hebergement.toJson()).toList()),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => Hebergement.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load sorted hebergements');
    }
  }

  Future<double> findMoyenneOther(Hebergement hebergement) async {
    final url = Uri.parse('$baseUrl/other/moyenne');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(hebergement.toJson()),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load moyenne');
    }
  }

  Future<List<Hebergement>> findHebergementsByNbChambres(
      List<Hebergement> hebergements, int nbChambre) async {
    final url = Uri.parse('$baseUrl/NbChambre?nbChambre=$nbChambre');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          hebergements.map((hebergement) => hebergement.toJson()).toList()),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => Hebergement.fromJson(json)).toList();
    } else {
      print('Failed to load hebergements: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load hebergements');
    }
  }

  Future<List<Hebergement>> findByFreeCancellation(
      List<Hebergement> hebergements) async {
    final response = await http.post(
      Uri.parse('$baseUrl/FreeCancellation'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(hebergements),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Hebergement.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load hebergements');
    }
  }

  Future<double> findMoyenne(Hebergement hebergement) async {
    final response = await http.post(
      Uri.parse('$baseUrl/moyenne'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(hebergement.toJson()),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load moyenne');
    }
  }

  Future<List<Hebergement>> findHebergementsByWork(
      List<Hebergement> hebergements) async {
    final url = Uri.parse('$baseUrl/work');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          hebergements.map((hebergement) => hebergement.toJson()).toList()),
    );

    print('Request URL: $url');
    print(
        'Request body: ${jsonEncode(hebergements.map((hebergement) => hebergement.toJson()).toList())}');

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => Hebergement.fromJson(json)).toList();
    } else {
      print('Failed to load hebergements: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load hebergements');
    }
  }

  Future<List<Hebergement>> findHebergementsByOverallAverage(
      List<Hebergement> hebergements,
      double overallAverage,
      double upperBound) async {
    final response = await http.post(
      Uri.parse(
          '$baseUrl/OverallAverage?overallAverage=$overallAverage&upperBound=$upperBound'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(hebergements.map((e) => e.toJson()).toList()),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Hebergement.fromJson(item)).toList();
    } else {
      print('Failed to load hebergements: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load hebergements');
    }
  }

  Future<List<Hebergement>> findHebergementsByNbEtoile(
      List<Hebergement> hebergements, String nbEtoile) async {
    final response = await http.post(
      Uri.parse('$baseUrl/nbEtoiles?nbEtoile=$nbEtoile'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(hebergements),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Hebergement.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load hebergements');
    }
  }

  Future<List<Hebergement>> findHebergementsByPrixMaxPrixMin(
      List<Hebergement> hebergements, double minPrice, double maxPrice) async {
    final url = Uri.parse('$baseUrl/prix');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'hebergements': hebergements.map((e) => e.toJson()).toList(),
        'minPrice': minPrice,
        'maxPrice': maxPrice,
      }),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      List<dynamic> responseJson = jsonDecode(response.body);
      return responseJson.map((json) => Hebergement.fromJson(json)).toList();
    } else {
      throw Exception('Failed to filter hebergements by price range');
    }
  }

  Future<double> findMinPriceChambre(int hebergementId) async {
    final prefs = await SharedPreferences.getInstance();
    final storedCurrency = prefs.getString('selectedCurrency') ?? 'EUR';
    print('Stored currency: $storedCurrency');

    final url = Uri.parse(
        '$baseUrl/minPrice?id=$hebergementId&targetCurrency=$storedCurrency');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load minimum price');
    }
  }

  Future<List<Hebergement>> findByNbChambres(
      List<Hebergement> hebergements, int nbChambre) async {
    final response = await http.post(
      Uri.parse('$baseUrl/NbChambre?nbChambre=$nbChambre'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(hebergements),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Hebergement.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load hebergements');
    }
  }

  Future<List<Hebergement>> sortHebergementsByNbEtoilesAsc(
      List<Hebergement> hebergements) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sortBynbEtoileAsc'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(hebergements),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Hebergement.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load hebergements');
    }
  }

  Future<List<Hebergement>> sortHebergementsByNbEtoilesDesc(
      List<Hebergement> hebergements) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sortBynbEtoileDesc'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(hebergements),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Hebergement.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load hebergements');
    }
  }

  Future<List<Hebergement>> sortHebergementsByMoyenneAsc(
      List<Hebergement> hebergements) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sortByMoyenneAsc'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(hebergements),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Hebergement.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load hebergements');
    }
  }

  Future<List<Hebergement>> sortHebergementsByMoyenneDesc(
      List<Hebergement> hebergements) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sortByMoyenneDesc'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(hebergements),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Hebergement.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load hebergements');
    }
  }

  Future<List<Hebergement>> sortHebergementsByPrixAsc(
      List<Hebergement> hebergements) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sortByPrixAsc'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(hebergements),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Hebergement.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load hebergements');
    }
  }

  Future<List<Hebergement>> sortHebergementsByPrixChambreAsc(
      List<Hebergement> hebergements) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sortByPrixChambresAsc'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(hebergements),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Hebergement.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load hebergements');
    }
  }

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

  Future<List<Hebergement>> fetchHebergements(
      String ville, int id, String newCurrency) async {
    final String baseUrl = 'http://192.168.1.17:3000/hebergement';
    final url = Uri.parse(
        '$baseUrl/new-currency?ville=$ville&id=$id&new_currency=$newCurrency');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> responseJson = json.decode(response.body);
      return responseJson.map((json) => Hebergement.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load hebergements');
    }
  }

  Future<List<Hebergement>> fetchAvailableHebergements(
      String ville, int categoryId, String checkIn, String checkOut) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedCurrency = prefs.getString('selectedCurrency');

      List<Hebergement> allHebergements;

      if (storedCurrency != null && storedCurrency.isNotEmpty) {
        allHebergements =
            await fetchHebergements(ville, categoryId, storedCurrency);
      } else {
        allHebergements = await findByVilleAndCategorie(ville, categoryId);
      }

      print('Nombre total d\'hébergements : ${allHebergements.length}');
      List<Hebergement> availableHebergements = [];

      for (Hebergement hebergement in allHebergements) {
        if (hebergement.chambres != null && hebergement.chambres!.isNotEmpty) {
          bool isAvailable = false;

          for (Chambre chambre in hebergement.chambres!) {
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

      print('Hébergements disponibles : ${availableHebergements.length}');
      return availableHebergements;
    } catch (e) {
      throw Exception('Échec du traitement des hébergements : $e');
    }
  }

  Future<List<Hebergement>> fetchAvailable(
      String ville, int categoryId, String checkIn, String checkOut) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedCurrency = prefs.getString('selectedCurrency');

      List<Hebergement> allHebergements;

      if (storedCurrency != null && storedCurrency.isNotEmpty) {
        allHebergements =
            await fetchHebergements(ville, categoryId, storedCurrency);
      } else {
        allHebergements = await findByVilleAndCategorie(ville, categoryId);
      }

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
