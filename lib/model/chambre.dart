

import 'package:casavia/model/equipement.dart';

class Chambre {
  int chambreId;
  String type;
  String description;
  double prix;
  String image_path;
  List<Equipement> equipements;

  Chambre({
    required this.chambreId,
    required this.type,
    required this.description,
    required this.prix,
    required this.image_path,
    required this.equipements,
  });

  factory Chambre.fromJson(Map<String, dynamic> json) {
    List<dynamic> equipementsJson = json['equipements'];
    List<Equipement> equipements =
        equipementsJson.map((e) => Equipement.fromJson(e)).toList();

    return Chambre(
      chambreId: json['chambre_id'],
      type: json['type'],
      description: json['description'],
      prix: json['prix'].toDouble(),
      image_path: json['image_path'],
      equipements: equipements,
    );
  }

  Map<String, dynamic> toJson() => {
        'chambre_id': chambreId,
        'type': type,
        'description': description,
        'prix': prix,
        'image_path': image_path,
        'equipements': equipements.map((e) => e.toJson()).toList(),
      };
}
