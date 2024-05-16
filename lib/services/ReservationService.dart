import 'dart:convert';
import 'package:casavia/model/reservation.dart';
import 'package:http/http.dart' as http;


class ReservationService {
  Future<Reservation?> ajouterReservation(
      Reservation reservation, int userId, int hebergementId) async {
    String url =
        'http://192.168.1.17:3000/reservation/save?user=$userId&hebergement=$hebergementId';

    try {
      String reservationJson = jsonEncode(reservation.toJson());

      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: reservationJson,
      );

      if (response.statusCode == 200) {
        Reservation reservationAjoutee =
            Reservation.fromJson(jsonDecode(response.body));
        print('Réservation ajoutée avec succès');
        return reservationAjoutee;
      } else {
        print('Échec de l\'ajout de la réservation : ${response.statusCode}');
        print('Réponse du serveur : ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la requête : $e');
      return null;
    }
  }

  Future<void> sendEmail(Reservation? reservation) async {
    String url = 'http://192.168.1.17:3000/reservation/sendEmail';

    try {
      String reservationJson = jsonEncode(reservation?.toJson());

      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: reservationJson,
      );

      if (response.statusCode == 200) {
        print('Email envoyé avec succès');
      } else {
        print('Échec de l\'envoi de l\'e-mail : ${response.statusCode}');
        print('Réponse du serveur : ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de la requête : $e');
    }
  }

  Future<Reservation?> getById(int? id) async {
    // Construire l'URL pour obtenir la réservation par son ID
    String url = 'http://192.168.1.17:3000/reservation/getById/$id';

    try {
      // Effectuer une requête HTTP GET pour obtenir la réservation
      final response = await http.get(Uri.parse(url));

      // Vérifier la réponse du serveur
      if (response.statusCode == 200) {
        // Convertir la réponse JSON en objet Reservation
        Reservation reservation =
            Reservation.fromJson(jsonDecode(response.body));
        return reservation;
      } else {
        print(
            'Échec de la récupération de la réservation : ${response.statusCode}');
        print('Réponse du serveur : ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la requête : $e');
      return null;
    }
  }
}
