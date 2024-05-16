class Recommandation {
  int? recommandation_id;


  Recommandation({
     this.recommandation_id,
   
  });

  factory Recommandation.fromJson(Map<String, dynamic> json) {
    return Recommandation(
      recommandation_id: json['recommandation_id'] as int,
      
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recommandation_id': recommandation_id,
      
    };
  }
}
