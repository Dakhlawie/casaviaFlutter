import 'dart:convert';
import 'package:casavia/model/hebergement.dart';
import 'package:casavia/model/payement.dart';
import 'package:casavia/model/user.dart';

class Reservation {
  int? id;
  String? numeroReservation;
  User? user;
  Hebergement? hebergement;
  String dateCheckIn;
  String dateCheckOut;
  double prix;
  String etat;
  int? nbRooms;
  List<int>? rooms;
  String currency;
  Payment? payment; 

  Reservation({
    this.id,
    this.numeroReservation,
    this.user,
    this.hebergement,
    required this.dateCheckIn,
    required this.dateCheckOut,
    required this.prix,
    required this.etat,
    this.nbRooms,
    this.rooms,
    required this.currency,
    this.payment, // New field
  })  : assert(currency.isNotEmpty, 'Currency cannot be empty'),
        assert(etat.isNotEmpty, 'Etat cannot be empty');

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      numeroReservation: json['numeroReservation'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      hebergement: json['hebergement'] != null
          ? Hebergement.fromJson(json['hebergement'])
          : null,
      dateCheckIn: json['dateCheckIn'],
      dateCheckOut: json['dateCheckOut'],
      prix: json['prix'],
      etat: json['etat'],
      nbRooms: json['nbRooms'],
      rooms: json['rooms'] != null ? List<int>.from(json['rooms']) : null,
      currency: json['currency'],
      payment: json['payment'] != null
          ? Payment.fromJson(json['payment'])
          : null, // New field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numeroReservation': numeroReservation,
      'user': user?.toJson(),
      'hebergement': hebergement?.toJson(),
      'dateCheckIn': dateCheckIn,
      'dateCheckOut': dateCheckOut,
      'prix': prix,
      'etat': etat,
      'nbRooms': nbRooms,
      'rooms': rooms,
      'currency': currency,
      'payment': payment?.toJson(), // New field
    };
  }
}
