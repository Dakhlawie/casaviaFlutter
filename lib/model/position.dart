class Position {
  int positionId;
  double longitude;
  double latitude;

  Position({
    required this.positionId,
    required this.longitude,
    required this.latitude,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      positionId: json['position_id'],
      longitude: json['longitude'],
      latitude: json['latitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'position_id': positionId,
      'longitude': longitude,
      'latitude': latitude,
    };
  }
}
