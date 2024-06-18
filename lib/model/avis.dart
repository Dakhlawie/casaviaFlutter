import 'package:casavia/model/hebergement.dart';
import 'package:casavia/model/user.dart';

class Avis {
  int? avisId;
  String avis;
  User? user;
  Hebergement? hebergement;
  String? moyenne;
  String? avisNegative;
  int staff;
  int location;
  int comfort;
  int facilities;
  int cleanliness;
  int security;
  DateTime date;

  Avis({
    this.avisId,
    required this.avis,
    this.user,
    this.hebergement,
    this.moyenne,
    this.avisNegative,
    required this.staff,
    required this.location,
    required this.comfort,
    required this.facilities,
    required this.cleanliness,
    required this.security,
    required this.date,
  });

  factory Avis.fromJson(Map<String, dynamic> json) {
    return Avis(
      avisId: json['avisId'],
      avis: json['avis'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      hebergement: json['hebergement'] != null
          ? Hebergement.fromJson(json['hebergement'])
          : null,
      moyenne: json['moyenne'] != null ? json['moyenne'].toString() : null,
      avisNegative: json['avisNegative'] != null ? json['avisNegative'] : null,
      staff: json['staff'],
      location: json['location'],
      comfort: json['comfort'],
      facilities: json['facilities'],
      cleanliness: json['cleanliness'],
      security: json['security'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() => {
        'avisId': avisId,
        'avis': avis,
        'user': user?.toJson(),
        'hebergement': hebergement?.toJson(),
        'moyenne': moyenne,
        'avisNegative': avisNegative,
        'staff': staff,
        'location': location,
        'comfort': comfort,
        'facilities': facilities,
        'cleanliness': cleanliness,
        'security': security,
        'date': date.toIso8601String(),
      };
}
