class Hotel {
  String image;
  String nom;
  String ville;
  String pays;
  double prix; 
  double distance;
  String contact;
  String adresse;
  List<String> equipements;
  List<String> servicesSupplementaires;
  String politiqueAnnulation;

  Hotel({
    required this.nom,
    required this.pays,
    required this.ville,
    required this.prix,
    required this.distance,
    required this.image,
    required this.contact,
    required this.adresse,
    required this.equipements,
    required this.servicesSupplementaires,
    required this.politiqueAnnulation,
  });

  static List hotel_list() {
    return [
      Hotel(
        nom: 'Grand Hotel',
        pays: 'France',
        ville: 'Paris',
        prix: 200,
        distance: 1.5,
        image: 'assets/hotel_Type_3.jpg',
        contact: '+33 1 23 45 67 89',
        adresse: '123 Rue de Rivoli, 75001 Paris',
        equipements: ['Piscine', 'Spa', 'Restaurant', 'Salle de sport'],
        servicesSupplementaires: [
          'Service de blanchisserie',
          'Service en chambre'
        ],
        politiqueAnnulation:
            'Annulation gratuite jusqu\'à 24 heures avant l\'arrivée.',
      ),
      Hotel(
        nom: 'Beach Resort',
        pays: 'Spain',
        ville: 'Barcelona',
        prix: 150,
        distance: 0.8,
        image: 'assets/hotel_Type_4.jpg',
        contact: '+34 6 78 90 12 34',
        adresse: '123 Rue de Rivoli, 75001 Paris',
        equipements: [
          'Plage privée',
          'Piscine extérieure',
          'Restaurant',
          'Bar'
        ],
        servicesSupplementaires: ['Location de vélos', 'Excursions organisées'],
        politiqueAnnulation:
            'Politique d\'annulation flexible. Veuillez consulter les détails lors de la réservation.',
      ),
      Hotel(
        nom: 'Mountain Lodge',
        pays: 'Switzerland',
        ville: 'Zurich',
        prix: 300,
        distance: 2.0,
        image: 'assets/hotel_2.png',
        contact: '+41 12 34 56 78',
        adresse: '123 Rue de Rivoli, 75001 Paris',
        equipements: [
          'Sauna',
          'Restaurant avec vue panoramique',
          'Salle de réunion'
        ],
        servicesSupplementaires: [
          'Service de navette vers les pistes de ski',
          'Location de matériel de ski'
        ],
        politiqueAnnulation:
            'Annulation gratuite jusqu\'à 48 heures avant l\'arrivée.',
      ),
      Hotel(
        nom: 'City Center Hotel',
        pays: 'USA',
        ville: 'New York',
        prix: 250,
        distance: 1.0,
        image: 'assets/hotel_3.png',
        contact: '+1 123-456-7890',
        adresse: '123 Rue de Rivoli, 75001 Paris',
        equipements: [
          'Centre de remise en forme',
          'Restaurant',
          'Centre d\'affaires'
        ],
        servicesSupplementaires: [
          'Service de voiturier',
          'Service de blanchisserie'
        ],
        politiqueAnnulation:
            'Politique d\'annulation flexible. Veuillez consulter les détails lors de la réservation.',
      ),
    ];
  }
}
