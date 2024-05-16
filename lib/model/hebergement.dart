import 'package:casavia/model/categorie.dart';
import 'package:casavia/model/chambre.dart';
import 'package:casavia/model/equipement.dart';
import 'package:casavia/model/imageHebergement.dart';
import 'package:casavia/model/position.dart';

class Hebergement {
  int hebergementId;
  String nom;
  String description;
  String ville;
  String pays;
  double prix;
  String distance;
  String phone;
  String email;
  String adresse;
  String politiqueAnnulation;
  String nbEtoile;
  double superficie;
  int nbSallesDeBains;
  int nbChambres;
  String website;
  String facebook;
  String instagram;
  String fax;
  String country_code;
  String currency;
  List<ImageHebergement> images;

  List<Chambre> chambres;
  List<Position> positions;
  Categorie categorie;

  Hebergement({
    required this.hebergementId,
    required this.nom,
    required this.description,
    required this.ville,
    required this.pays,
    required this.prix,
    required this.distance,
    required this.phone,
    required this.email,
    required this.adresse,
    required this.politiqueAnnulation,
    required this.nbEtoile,
    required this.superficie,
    required this.nbSallesDeBains,
    required this.nbChambres,
    required this.website,
    required this.facebook,
    required this.instagram,
    required this.fax,
    required this.images,
    required this.chambres,
    required this.positions,
    required this.categorie,
    required this.country_code,
    required this.currency,
  });
  factory Hebergement.fromJson(Map<String, dynamic> json) {
    List<dynamic> jsonImages = json['images'];

    List<dynamic> jsonPositions = json['positions'];
    List<dynamic> jsonChambres = json['chambres'];

    List<ImageHebergement> images = jsonImages
        .map((imageJson) => ImageHebergement.fromJson(imageJson))
        .toList();

    List<Position> positions = jsonPositions
        .map((positionJson) => Position.fromJson(positionJson))
        .toList();
    List<Chambre> chambres = jsonChambres
        .map((chambreJson) => Chambre.fromJson(chambreJson))
        .toList();

    return Hebergement(
      hebergementId: json['hebergement_id'],
      nom: json['nom'],
      description: json['description'],
      ville: json['ville'],
      pays: json['pays'],
      prix: json['prix'],
      distance: json['distance'],
      phone: json['phone'],
      email: json['email'],
      adresse: json['adresse'],
      politiqueAnnulation: json['politiqueAnnulation'],
      nbEtoile: json['nbEtoile'],
      superficie: json['superficie'],
      nbSallesDeBains: json['nb_Salles_De_Bains'],
      nbChambres: json['nb_Chambres'],
      website: json['website'],
      facebook: json['facebook'],
      instagram: json['instagram'],
      fax: json['fax'],
      country_code: json['country_code'],
      currency: json['currency'],
      images: images,
      positions: positions,
      chambres: chambres,
      categorie: Categorie.fromJson(json['categorie']),
    );
  }

  Map<String, dynamic> toJson() => {
        'hebergement_id': hebergementId,
        'nom': nom,
        'description': description,
        'ville': ville,
        'pays': pays,
        'prix': prix,
        'distance': distance,
        'phone': phone,
        'email': email,
        'adresse': adresse,
        'politiqueAnnulation': politiqueAnnulation,
        'nbEtoile': nbEtoile,
        'superficie': superficie,
        'nb_Salles_De_Bains': nbSallesDeBains,
        'nb_Chambres': nbChambres,
        'website': website,
        'facebook': facebook,
        'instagram': instagram,
        'fax': fax,
        'country_code': country_code,
        'currency': currency,
        'images': images.map((image) => image.toJson()).toList(),
        'positions': positions.map((position) => position.toJson()).toList(),
        'categorie': categorie.toJson(),

        /*'chambres': chambres.map((chambre) => chambre.toJson()).toList(),*/
      };
  
}
