class Visitor {
  final int id;
  final String visitorId;

  Visitor({required this.id, required this.visitorId});

  factory Visitor.fromJson(Map<String, dynamic> json) {
    return Visitor(
      id: json['id'] as int,
      visitorId: json['visitor_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visitor_id': visitorId,
    };
  }
}
