import 'dart:convert';

class User {
  int id;
  String nom;
  String prenom;
  String? tlf;
  String? pays;
  String email;
  String motDePasse;
  String? imagePath;

  User({
    required this.id,
    required this.nom,
    required this.prenom,
    this.tlf,
    this.pays,
    required this.email,
    required this.motDePasse,
    this.imagePath,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    print(json);
    User user = User(
      id: json['user_id'],
      nom: json['nom'],
      prenom: json['prenom'],
      tlf: json['tlf'],
      pays: json['pays'],
      email: json['email'],
      motDePasse: json['mot_de_passe'],
      imagePath: json['image_path'],
    );
    print(user);
    return user;
  }

  Map<String, dynamic> toJson() => {
        'user_id': id,
        'nom': nom,
        'prenom': prenom,
        'tlf': tlf,
        'pays': pays,
        'email': email,
        'mot_de_passe': motDePasse,
        'image_path': imagePath,
      };
}
