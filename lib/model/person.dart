import 'package:casavia/model/hebergement.dart';
import 'package:casavia/model/notification.dart';

class Person {
  int? personId;
  String nom;
  String prenom;
  String telephone;
  String email;
  String motDePasse;
  String role;
  String? imagePath;

  Person({
    this.personId,
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.email,
    required this.motDePasse,
    required this.role,
    this.imagePath,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      personId: json['person_id'],
      nom: json['nom'],
      prenom: json['prenom'],
      telephone: json['telephone'],
      email: json['email'],
      motDePasse: json['mot_de_passe'],
      role: json['role'],
      imagePath: json['image_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'person_id': personId,
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'email': email,
      'mot_de_passe': motDePasse,
      'role': role,
      'image_path': imagePath,
    };
  }
}
