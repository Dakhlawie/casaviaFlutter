import 'dart:convert';
import 'package:casavia/model/reservation.dart';
import 'package:http/http.dart' as http;

class ReservationService {
  final String baseUrl = 'http://192.168.1.17:3000/reservation';
  Future<Reservation?> ajouterReservation(
      Reservation reservation, int user_id, int hebergement_id) async {
    String url =
        'http://192.168.1.17:3000/reservation/save?user_id=$user_id&hebergement_id=$hebergement_id';

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
    String url = 'http://192.168.1.17:3000/reservation/getById/$id';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
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

  Future<List<Reservation>> getPendingOrConfirmedReservationsByUser(
      int userId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/user/pendingOrConfirmed/$userId'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Reservation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reservations');
    }
  }

  Future<List<Reservation>> getCompletedReservationsByUser(int userId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/user/completed/$userId'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Reservation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reservations');
    }
  }
  Future<void> annulerReservation(int id) async {
    final url = Uri.parse('$baseUrl/annuler/$id');
    final response = await http.put(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to cancel reservation');
    }
  }

  Future<Reservation> updateReservation(int id, Reservation updatedReservation) async {
    final url = Uri.parse('$baseUrl/updated/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedReservation.toJson()),
    );

    if (response.statusCode == 200) {
      return Reservation.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update reservation');
    }
  }
}
