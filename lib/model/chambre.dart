import 'package:casavia/model/equipement.dart';

class Chambre {
  int chambreId;
  String type;
  String description;
  double prix;
  String image_path;
  List<Equipement>? equipements;
  String? floor;
  String? view;
  String? bed;

  Chambre({
    required this.chambreId,
    required this.type,
    required this.description,
    required this.prix,
    required this.image_path,
    this.equipements,
    this.floor,
    this.view,
    this.bed,
  });

  factory Chambre.fromJson(Map<String, dynamic> json) {
    List<dynamic>? jsonEquipements = json['equipements'];
    List<Equipement>? equipements = jsonEquipements != null
        ? jsonEquipements
            .map((equipementJson) => Equipement.fromJson(equipementJson))
            .toList()
        : null;

    return Chambre(
      chambreId: json['chambre_id'],
      type: json['type'],
      description: json['description'],
      prix: json['prix'].toDouble(),
      image_path: json['image_path'],
      equipements: equipements,
      floor: json['floor'],
      view: json['view'],
      bed: json['bed'],
    );
  }

  Map<String, dynamic> toJson() => {
        'chambre_id': chambreId,
        'type': type,
        'description': description,
        'prix': prix,
        'image_path': image_path,
        'equipements':
            equipements?.map((equipement) => equipement.toJson()).toList(),
        'floor': floor,
        'view': view,
        'bed': bed,
      };
}
