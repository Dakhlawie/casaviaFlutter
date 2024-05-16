import 'package:casavia/model/hebergement.dart';
import 'package:casavia/services/recommandationService.dart';
import 'package:flutter/foundation.dart';

class UserModel with ChangeNotifier {
  int _userId = 0;
  RecommandationService recommandationService = RecommandationService();
  List<Hebergement> userPreferredHebergements = [];

  int get userId => _userId;

  void setUserId(int userId) async {
    _userId = userId;
    notifyListeners();
    if (userId == 0) {
  
    print("Invalid userId provided: 0");
    return;
  }
    userPreferredHebergements = await fetchUserPreferredHebergements(userId);
    List<Hebergement> recommendedHebergements = await recommandationService
        .getRecommendedHebergements(userPreferredHebergements, userId);
  }

  Future<List<Hebergement>> fetchUserPreferredHebergements(int userId) async {
    try {
      List<Hebergement> preferredHebergements =
          await recommandationService.fetchLikedAndReservedHebergements(userId);

      return preferredHebergements;
    } catch (e) {
      throw Exception('Failed to fetch user preferred hebergements: $e');
    }
  }
}
