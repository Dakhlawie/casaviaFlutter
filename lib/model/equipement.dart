import 'package:casavia/model/categorieEquipement.dart';

class Equipement {
  final int id;
  final String nom;
  final CategorieEquipement categorie;

  Equipement({
    required this.id,
    required this.nom,
    required this.categorie,
  });

  factory Equipement.fromJson(Map<String, dynamic> json) {
    return Equipement(
      id: json['id'] as int,
      nom: json['nom'] as String,
      categorie: CategorieEquipement.fromJson(json['categorie']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'categorie': categorie.toJson(),
      };
}

