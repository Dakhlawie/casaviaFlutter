import 'dart:async';

import 'package:casavia/Screens/core/acommodation.dart';
import 'package:casavia/model/animator.dart';
import 'package:casavia/model/hebergement.dart';
import 'package:casavia/model/hotel.dart';
import 'package:casavia/model/userModel.dart';
import 'package:casavia/model/ville.dart';
import 'package:casavia/services/AuthService.dart';
import 'package:casavia/services/recommandationService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _imageIndex = 0;
  List<String> _imagePaths = [
    'assets/explore_2.jpg',
    'assets/explore_1.jpg',
    'assets/explore_3.jpg',
    'assets/explore_4.jpeg'
  ];
  late Timer _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        _imageIndex = (_imageIndex + 1) % _imagePaths.length;
      });
    });
    _fetchUserId();
    fetchHebergements();
  }

  RecommandationService recommandationService = RecommandationService();

  Future<void> _fetchUserId() async {
    AuthService authService = AuthService();
    int? userId = await authService.getUserIdFromToken();
    if (userId != null) {
      Provider.of<UserModel>(context, listen: false).setUserId(userId);
    }
    print('USERID');
    print(userId);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<List<Hebergement>>? hebergementsFuture;
  fetchHebergements() {
    final userId = Provider.of<UserModel>(context, listen: false).userId;
    print(userId);
    if (userId != 0) {
      hebergementsFuture =
          recommandationService.getRecommendedHebergementsByUser(userId);
    }
  }

  List<Hebergement> hebergements = [];
  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserModel>(context).userId;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.white,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 500),
                      child: Image.asset(
                        _imagePaths[_imageIndex],
                        key: ValueKey<int>(_imageIndex),
                        height: 400,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16, left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: 320,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: Icon(Icons.search,
                                            color: Colors.blue[900])),
                                    SizedBox(width: 8, height: 60),
                                    Expanded(
                                      child: Text(
                                        'Where are you going?',
                                        style: TextStyle(
                                            color: const Color.fromARGB(
                                                118, 0, 0, 0),
                                            fontFamily: 'AbrilFatface'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(FontAwesomeIcons.bell,
                                    color: Colors.white),
                                iconSize: 30.0,
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 250,
                      left: 16,
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Find your next stay',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'AbrilFatface'),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Search for offers on hotels,independent',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 1),
                            Text(
                              ' accommodations, and more.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 25.0),
              Container(
                padding: EdgeInsets.only(left: 12, right: 12),
                child: Text(
                  'Popular Destination',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                      fontFamily: 'AbrilFatface'),
                ),
              ),
              SizedBox(height: 25.0),
              Container(
                padding: EdgeInsets.only(left: 12, right: 12),
                height: 140.0,
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    Ville villeCourante = Ville.ville_list[index];
                    return InkWell(
                      onTap: () {},
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            alignment: Alignment.topLeft,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: Image.asset(
                                  villeCourante.imageUrl,
                                  width: 200.0,
                                  height: 100.0,
                                  fit: BoxFit.fill,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                  left: 8.0,
                                  right: 8.0,
                                  top: 4,
                                  bottom: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: Text(
                                  villeCourante.nom,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                      color: Colors.white,
                                      fontFamily: 'AbrilFatface'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 10),
                  itemCount: Ville.ville_list.length,
                ),
              ),
              SizedBox(height: 2.0),
              userId == 0
                  ? Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 2, left: 8),
                          child: Row(
                            children: [
                              Text(
                                'Best Deals',
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900],
                                    fontFamily: 'AbrilFatface'),
                              ),
                              Spacer(), // This will take all available horizontal space
                              Text(
                                'View all',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.normal,
                                  color: Color.fromARGB(190, 13, 72, 161),
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.chevron_right_outlined,
                                  color: Color.fromARGB(190, 13, 72, 161),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Column(
                          children: Hotel.hotel_list().map((hotel) {
                            return Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        hotel.image,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            hotel.nom,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            '${hotel.pays}, ${hotel.ville}',
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            '${hotel.prix}\$/night',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            '${hotel.distance}km',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: List.generate(
                                              5,
                                              (index) => Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    )
                  : Container(),
              if (userId != 0)
                FutureBuilder<List<Hebergement>>(
                  future: hebergementsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text("Error: ${snapshot.error.toString()}"));
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 2, left: 10),
                              child: Text(
                                'Recommended for you',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                  fontFamily: 'AbrilFatface',
                                ),
                              ),
                            ),
                            SizedBox(height: 10.0),
                            AccommodationList(hebergements: snapshot.data!),
                          ],
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                )
              else
                Container(),
            ],
          ),
        ),
      ),
    );
  }
}

class AccommodationList extends StatelessWidget {
  final List<Hebergement> hebergements;

  AccommodationList({required this.hebergements});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: hebergements.map((hebergement) {
          int nbEtoiles = hebergement.nbEtoile != null
              ? int.tryParse(hebergement.nbEtoile!) ?? 0
              : 0;
          return Padding(
            padding: EdgeInsets.all(10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  DateTime today = DateTime.now();
                  DateTime tomorrow = today.add(Duration(days: 1));
                  DateTime dayAfterTomorrow = today.add(Duration(days: 2));

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AcommodationPage(
                        hebergement: hebergement,
                        checkIn: DateFormat('dd/MM/yyyy').format(tomorrow),
                        checkOut:
                            DateFormat('dd/MM/yyyy').format(dayAfterTomorrow),
                      ),
                    ),
                  );
                },
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.horizontal(left: Radius.circular(10)),
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: HebergementImageAnimator(
                              hebergement: hebergement),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("${hebergement.nom}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text("${hebergement.pays}, ${hebergement.ville}",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey)),
                              Visibility(
                                visible: hebergement.categorie.idCat == 1,
                                child: Row(
                                  children: List.generate(
                                    nbEtoiles,
                                    (i) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
