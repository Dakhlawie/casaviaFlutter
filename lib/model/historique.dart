class Historique {
  final int? historiqueId;
  final String checkIn;
  final String checkOut;
  final String lieu;

  Historique({
    this.historiqueId,
    required this.checkIn,
    required this.checkOut,
    required this.lieu,
  });

  factory Historique.fromJson(Map<String, dynamic> json) {
    return Historique(
      historiqueId: json['historique_id'],
      checkIn: json['check_in'],
      checkOut: json['check_out'],
      lieu: json['lieu'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'historique_id': historiqueId,
      'check_in': checkIn,
      'check_out': checkOut,
      'lieu': lieu,
    };
  }
}
