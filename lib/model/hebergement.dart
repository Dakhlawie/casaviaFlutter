import 'package:casavia/model/categorie.dart';
import 'package:casavia/model/chambre.dart';
import 'package:casavia/model/equipement.dart';
import 'package:casavia/model/imageHebergement.dart';
import 'package:casavia/model/offre.dart';
import 'package:casavia/model/person.dart';
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
  String? cancellationfees;
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
  List<Equipement>? equipements;
  Person person;
  List<OffreHebergement>? offres;

  double? staff;
  double? location;
  double? comfort;
  double? facilities;
  double? cleanliness;
  double? security;
  double? moyenne;
  int? nbAvis;

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
    this.cancellationfees,
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
    this.equipements,
    required this.person,
    this.offres,
    this.staff,
    this.location,
    this.comfort,
    this.facilities,
    this.cleanliness,
    this.security,
    this.moyenne,
    this.nbAvis, // Initialiser nbAvis
  });

  factory Hebergement.fromJson(Map<String, dynamic> json) {
    List<dynamic> jsonImages = json['images'];
    List<dynamic>? jsonOffres = json['offres'];
    List<dynamic> jsonPositions = json['positions'];
    List<dynamic> jsonChambres = json['chambres'];
    List<dynamic>? jsonEquipements = json['equipements'];

    List<ImageHebergement> images = jsonImages
        .map((imageJson) => ImageHebergement.fromJson(imageJson))
        .toList();

    List<Position> positions = jsonPositions
        .map((positionJson) => Position.fromJson(positionJson))
        .toList();
    List<Chambre> chambres = jsonChambres
        .map((chambreJson) => Chambre.fromJson(chambreJson))
        .toList();
    List<Equipement>? equipements = jsonEquipements != null
        ? jsonEquipements
            .map((equipementJson) => Equipement.fromJson(equipementJson))
            .toList()
        : null;
    List<OffreHebergement>? offres = jsonOffres != null
        ? jsonOffres
            .map((offreJson) => OffreHebergement.fromJson(offreJson))
            .toList()
        : null;

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
      cancellationfees: json['cancellationfees'],
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
      equipements: equipements,
      person: Person.fromJson(json['person']),
      offres: offres,
      staff: json['staff'],
      location: json['location'],
      comfort: json['comfort'],
      facilities: json['facilities'],
      cleanliness: json['cleanliness'],
      security: json['security'],
      moyenne: json['moyenne'],
      nbAvis: json['nbAvis'], // Ajouter nbAvis dans fromJson
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
        'cancellationfees': cancellationfees,
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
        'equipements':
            equipements?.map((equipement) => equipement.toJson()).toList(),
        'categorie': categorie.toJson(),
        'chambres': chambres.map((chambre) => chambre.toJson()).toList(),
        'person': person.toJson(),
        'offres': offres?.map((offre) => offre.toJson()).toList(),
        'staff': staff,
        'location': location,
        'comfort': comfort,
        'facilities': facilities,
        'cleanliness': cleanliness,
        'security': security,
        'moyenne': moyenne,
        'nbAvis': nbAvis, // Ajouter nbAvis dans toJson
      };
}
