class CategorieEquipement {
  final int categorieId;
  final String nom;

  CategorieEquipement({required this.categorieId, required this.nom});

  factory CategorieEquipement.fromJson(Map<String, dynamic> json) {
    return CategorieEquipement(
      categorieId: json['categorie_id'],
      nom: json['nom'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categorie_id': categorieId,
      'nom': nom,
    };
  }
}
