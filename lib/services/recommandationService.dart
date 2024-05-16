import 'dart:convert';
import 'package:casavia/model/KMeansClustering.dart';
import 'package:casavia/model/recommandation.dart';
import 'package:http/http.dart' as http;
import 'package:casavia/model/hebergement.dart';

class RecommandationService {
  Future<List<Hebergement>> fetchHebergements() async {
    final response =
        await http.get(Uri.parse('http://192.168.1.17:3000/hebergement/all'));

    if (response.statusCode == 200) {
      List<dynamic> hebergementsJson = json.decode(response.body);
      return hebergementsJson
          .map((json) => Hebergement.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load hebergements');
    }
  }

  Future<List<Hebergement>> fetchLikedHebergements(int userId) async {
    final response = await http.get(Uri.parse(
        'http://192.168.1.17:3000/hebergement/liked-hebergements?userId=$userId'));

    if (response.statusCode == 200) {
      List<dynamic> hebergementsJson = json.decode(response.body);
      return hebergementsJson
          .map((json) => Hebergement.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load liked hebergements');
    }
  }

  Future<List<Hebergement>> fetchReservedHebergements(int userId) async {
    final response = await http.get(Uri.parse(
        'http://192.168.1.17:3000/hebergement/reserved-hebergements?userId=$userId'));

    if (response.statusCode == 200) {
      List<dynamic> hebergementsJson = json.decode(response.body);
      return hebergementsJson
          .map((json) => Hebergement.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load reserved hebergements');
    }
  }

  Future<List<Hebergement>> fetchLikedAndReservedHebergements(
      int userId) async {
    try {
      Future<List<Hebergement>> likedHebergementsFuture =
          fetchLikedHebergements(userId);
      Future<List<Hebergement>> reservedHebergementsFuture =
          fetchReservedHebergements(userId);

      List<Hebergement> likedHebergements = await likedHebergementsFuture;
      List<Hebergement> reservedHebergements = await reservedHebergementsFuture;

      Set<Hebergement> uniqueHebergements = Set<Hebergement>();
      uniqueHebergements.addAll(likedHebergements);
      uniqueHebergements.addAll(reservedHebergements);

      return uniqueHebergements.toList();
    } catch (e) {
      throw Exception('Failed to load hebergements: $e');
    }
  }

  Future<Recommandation> addRecommandation(
      Recommandation recommandation, int userId, int hebergementId) async {
    final response = await http.post(
      Uri.parse(
          'http://192.168.1.17:3000/recommandation/save?user=$userId&hebergement=$hebergementId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(recommandation.toJson()),
    );

    if (response.statusCode == 200) {
      return Recommandation.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to save recommandation');
    }
  }

  Future<Hebergement> getHebergementFromRecommandation(
      int? recommandationId) async {
    final response = await http.get(Uri.parse(
        'http://192.168.1.17:3000/hebergement/from-recommandation/$recommandationId'));
    print(response.statusCode);
    if (response.statusCode == 200) {
      return Hebergement.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load Hebergement');
    }
  }

  Future<List<Recommandation>> fetchRecommandationsByUser(int userId) async {
    final response = await http.get(Uri.parse(
        'http://192.168.1.17:3000/recommandation/getByUser?user=$userId'));

    if (response.statusCode == 200) {
      List<dynamic> recommandationsJson = json.decode(response.body);
      print(recommandationsJson
          .map((json) => Recommandation.fromJson(json))
          .toList());
      return recommandationsJson
          .map((json) => Recommandation.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load recommandations');
    }
  }

  Future<Set<int>> fetchAlreadyRecommendedHebergementIds(int userId) async {
    try {
      List<Recommandation> existingRecommendations =
          await fetchRecommandationsByUser(userId);
      Set<int> alreadyRecommendedIds = {};
      for (Recommandation recommendation in existingRecommendations) {
        try {
          Hebergement hebergement = await getHebergementFromRecommandation(
              recommendation.recommandation_id);
          alreadyRecommendedIds.add(hebergement.hebergementId);
        } catch (e) {
          print("Failed to fetch Hebergement for recommendation: ${e}");
        }
      }
      print('alreadyRecommendedIds');
      print(alreadyRecommendedIds);
      return alreadyRecommendedIds;
    } catch (e) {
      throw Exception("Failed to load existing recommendations: ${e}");
    }
  }

  Future<List<Hebergement>> getRecommendedHebergementsByUser(int userId) async {
    print('hi');
    try {
      List<Recommandation> recommandations =
          await fetchRecommandationsByUser(userId);

      List<Hebergement> hebergements = [];

      for (Recommandation recommandation in recommandations) {
        Hebergement hebergement = await getHebergementFromRecommandation(
            recommandation.recommandation_id);
        hebergements.add(hebergement);
      }
      print('********************************');
      print(hebergements);
      return hebergements;
    } catch (e) {
      print('Error fetching recommended Hebergements: $e');
      throw Exception('Failed to fetch recommended Hebergements');
    }
  }

  Future<List<Hebergement>> getRecommendedHebergements(
      List<Hebergement> selectedHebergements, int userId) async {
    final allHebergements = await fetchHebergements();
    Set<int> alreadyRecommendedIds =
        await fetchAlreadyRecommendedHebergementIds(userId);

    List<Hebergement> recommendedHebergements = [];

    final List<Hebergement> hebergementsToCluster = allHebergements
        .where((hebergement) => !selectedHebergements.contains(hebergement))
        .toList();

    KMeansClustering kmeans = KMeansClustering(
      data: hebergementsToCluster,
      k: 5,
    );

    kmeans.run();

    List<int> selectedClusters = selectedHebergements
        .map((hebergement) => kmeans.predict(hebergement))
        .toList();

    for (int clusterId in selectedClusters.toSet()) {
      List<Hebergement> clusterHebergements = kmeans.getCluster(clusterId);

      for (Hebergement selectedHebergement in selectedHebergements) {
        List<Hebergement> filteredHebergements = clusterHebergements
            .where((hebergement) =>
                hebergement.pays == selectedHebergement.pays &&
                hebergement.nbEtoile == selectedHebergement.nbEtoile &&
                hebergement.nbChambres == selectedHebergement.nbChambres &&
                hebergement.nbSallesDeBains ==
                    selectedHebergement.nbSallesDeBains)
            .toList();
        print('verification');
        print(
            "Selected IDs: ${selectedHebergements.map((h) => h.hebergementId).toList()}");
        print(
            "Matching IDs: ${allHebergements.map((h) => h.hebergementId).toList()}");

        for (Hebergement matchingHebergement in filteredHebergements) {
          print(matchingHebergement.nom);
          bool isAlreadySelected = selectedHebergements.any((selected) =>
              selected.hebergementId == matchingHebergement.hebergementId);
          if (!isAlreadySelected &&
              !alreadyRecommendedIds
                  .contains(matchingHebergement.hebergementId)) {
            addRecommandation(
                Recommandation(), userId, matchingHebergement.hebergementId);
            recommendedHebergements.add(matchingHebergement);
          }
        }
      }
    }

    recommendedHebergements = recommendedHebergements
        .where((hebergement) => !selectedHebergements.contains(hebergement))
        .toList();

    return recommendedHebergements;
  }
}
