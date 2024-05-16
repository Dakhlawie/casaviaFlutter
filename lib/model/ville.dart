class Ville {
  String nom;
  String pays;
  double latitude;
  double longitude;
  String description;
  String imageUrl;

  Ville({
    required this.nom,
    required this.pays,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.imageUrl,
  });
  static List<Ville> ville_list = [
    Ville(
      nom: "Paris",
      pays: "France",
      latitude: 48.8566,
      longitude: 2.3522,
      description:
          "La magnifique capitale de la France, connue pour sa tour emblématique, ses musées de renommée mondiale et son charme unique.",
      imageUrl: "assets/paris.jpg",
    ),
    Ville(
      nom: "New York",
      pays: "États-Unis",
      latitude: 40.7128,
      longitude: -74.0060,
      description:
          "La ville qui ne dort jamais, réputée pour ses gratte-ciel emblématiques, ses quartiers diversifiés et son ambiance cosmopolite.",
      imageUrl: "assets/newyork.jpg",
    ),
    Ville(
      nom: "Tokyo",
      pays: "Japon",
      latitude: 35.6895,
      longitude: 139.6917,
      description:
          "La capitale dynamique du Japon, mêlant traditions séculaires et technologie de pointe. Découvrez ses quartiers animés, ses temples anciens et ses innovations modernes.",
      imageUrl: "assets/tokyo.jpg",
    ),
  ];
}
