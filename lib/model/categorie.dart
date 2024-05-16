

class Categorie {
  int idCat;
  String type;

  Categorie({
    required this.idCat,
    required this.type,
  });

  factory Categorie.fromJson(Map<String, dynamic> json) {
    return Categorie(
      idCat: json['idCat'] as int,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCat': idCat,
      'type': type,
    };
  }
}
