import 'package:casavia/model/hebergement.dart';
import 'package:casavia/model/user.dart';
import 'package:http/http.dart';


class Avis {
  int avisId;
  String avis;
  User user;
  Hebergement hebergement;

  Avis({
    required this.avisId,
    required this.avis,
    required this.user,
    required this.hebergement,
  });

  factory Avis.fromJson(Map<String, dynamic> json) {
    print("hhhhh");

    Avis avis = Avis(
      avisId: json['avisId'],
      avis: json['avis'],
      user: User.fromJson(json['user']),
      hebergement: Hebergement.fromJson(json['hebergement']),
    );
    print(avis);
    return avis;
  }

  Map<String, dynamic> toJson() => {
        'avisId': avisId,
        'avis': avis,
        'user': user.toJson(),
        'hebergement': hebergement.toJson(),
      };
}
