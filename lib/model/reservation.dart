import 'dart:convert';

import 'package:casavia/model/hebergement.dart';
import 'package:casavia/model/user.dart';


class Reservation {
  int? id;
  User? user;
  Hebergement? hebergement;

  String dateCheckIn;
  String dateCheckOut;
  String prix;
  String? etat;
  String nbRooms;

  Reservation({
    this.id,
    this.user,
    this.hebergement,
    required this.dateCheckIn,
    required this.dateCheckOut,
    required this.prix,
    this.etat,
    required this.nbRooms,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      user: User.fromJson(json['user']),
      hebergement: Hebergement.fromJson(json['hebergement']),
      dateCheckIn: json['dateCheckIn'],
      dateCheckOut: json['dateCheckOut'],
      prix: json['prix'],
      etat: json['etat'],
      nbRooms: json['nbRooms'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user?.toJson(),
      'hebergement': hebergement?.toJson(),
      'dateCheckIn': dateCheckIn,
      'dateCheckOut': dateCheckOut,
      'prix': prix,
      'etat': etat,
      'nbRooms': nbRooms,
    };
  }
}
