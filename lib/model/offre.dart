class OffreHebergement {
  int offreId;
  String discount;
  String startDate;
  String endDate;
  bool allRooms;

  List<int> rooms;

  OffreHebergement({
    required this.offreId,
    required this.discount,
    required this.startDate,
    required this.endDate,
    required this.allRooms,
    required this.rooms,
  });

  factory OffreHebergement.fromJson(Map<String, dynamic> json) {
    return OffreHebergement(
      offreId: json['offre_id'],
      discount: json['discount'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      allRooms: json['allRooms'],
      rooms: List<int>.from(json['rooms']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'offre_id': offreId,
      'discount': discount,
      'start_date': startDate,
      'end_date': endDate,
      'allRooms': allRooms,
      'rooms': rooms,
    };
  }
}
