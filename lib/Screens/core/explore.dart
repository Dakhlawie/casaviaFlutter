import 'dart:convert';
import 'dart:typed_data';
import 'package:casavia/Screens/core/acommodation.dart';
import 'package:casavia/model/animator.dart';
import 'package:casavia/model/categorie.dart';
import 'package:casavia/model/hebergement.dart';
import 'package:casavia/services/CategorieService.dart';
import 'package:casavia/services/HebergementService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExplorePage extends StatefulWidget {
  final String ville;
  final String checkIn;
  final String checkOut;
  const ExplorePage(
      {Key? key,
      required this.ville,
      required this.checkIn,
      required this.checkOut})
      : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'EUR':
        return '€';
      case 'CAD':
        return 'CA\$';
      case 'CHF':
        return 'CHF';
      case 'AUD':
        return 'A\$';
      case 'JPY':
        return '¥';
      case 'CNY':
        return '¥';
      case 'INR':
        return '₹';
      case 'SEK':
        return 'kr';
      case 'BRL':
        return 'R\$';
      case 'TRY':
        return '₺';
      case 'AED':
        return 'د.إ';
      case 'AFN':
        return '؋';
      case 'ALL':
        return 'Lek';
      case 'AMD':
        return '֏';

      default:
        return '';
    }
  }

  final HebergementService _hebergementService = HebergementService();
  final CategorieService _categorieService = CategorieService();
  late Future<List<Hebergement>> _hebergementsFuture;
  late Future<List<Hebergement>> _hotelhebergements;
  late Future<List<Hebergement>> _availabalehotel;
  late Future<List<Hebergement>> _availabalevillas;
  late Future<List<Hebergement>> _availabaleAppartement;
  late Future<List<Hebergement>> _villahebergements;
  late Future<List<Hebergement>> _appartmenthebergements;
  late Future<List<Categorie>> futureCategories;
  final TextEditingController searchcontroller = TextEditingController();
  bool isSearchExpanded = false;
  int selectedCategoryIndex = 0;
  int catindex = 1;
  void toggleSearchBar() {
    setState(() {
      isSearchExpanded = !isSearchExpanded;
    });
  }

  String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('MMM dd');
    return formatter.format(date);
  }

  DateFormat inputFormat = DateFormat('dd/MM/yyyy');
  @override
  void initState() {
    super.initState();
    String formattedCheckIn = formatDate(inputFormat.parse(widget.checkIn));
    String formattedCheckOut = formatDate(inputFormat.parse(widget.checkOut));
    searchcontroller.text =
        '${widget.ville} $formattedCheckIn $formattedCheckOut';
    futureCategories = _categorieService.getAllCategories();
    _hebergementsFuture = _hebergementService.searchHebergements(widget.ville);
    _hotelhebergements =
        _hebergementService.findByVilleAndCategorie(widget.ville, 1);
    _villahebergements =
        _hebergementService.findByVilleAndCategorie(widget.ville, 2);
    _appartmenthebergements =
        _hebergementService.findByVilleAndCategorie(widget.ville, 3);
    _availabalehotel = _hebergementService.fetchAvailableHebergements(
        widget.ville, 1, widget.checkIn, widget.checkOut);
    _availabalevillas = _hebergementService.fetchAvailable(
        widget.ville, 2, widget.checkIn, widget.checkOut);
    _availabaleAppartement = _hebergementService.fetchAvailable(
        widget.ville, 3, widget.checkIn, widget.checkOut);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            buildSearchBar(),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.all(16),
              child: Container(
                height: 50,
                child: FutureBuilder<List<Categorie>>(
                  future: _categorieService.getAllCategories(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Categorie>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      List<Categorie> categories = snapshot.data!;
                      /* _categoriehebergements =
                          _hebergementService.findByVilleAndCategorie(
                              widget.ville, categories[0].idCat);*/
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return _buildCircleCategory(
                              categories[index].type, index);
                        },
                      );
                    } else {
                      return Center(child: Text('No categories found.'));
                    }
                  },
                ),
              ),
            ),
            if (selectedCategoryIndex == 0)
              Expanded(
                child: FutureBuilder<List<Hebergement>>(
                  future: _availabalehotel,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.data != null &&
                        snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/empty.svg',
                              width: 150,
                              height: 150,
                            ),
                            SizedBox(height: 20),
                            Text('No accommodations found',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                      );
                    } else {
                      List<Hebergement> hebergements = snapshot.data!;
                      print("nbhebergement");
                      print(hebergements.length);
                      return Padding(
                        padding: EdgeInsets.all(16),
                        child: ListView.separated(
                          itemCount: hebergements.length,
                          separatorBuilder: (BuildContext context, int index) {
                            return SizedBox(height: 16);
                          },
                          itemBuilder: (context, index) {
                            Hebergement hebergement = hebergements[index];

                            int nbEtoiles = hebergement.nbEtoile != null
                                ? int.tryParse(hebergement.nbEtoile!) ?? 0
                                : 0;

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AcommodationPage(
                                      hebergement: hebergement,
                                      checkIn: widget.checkIn,
                                      checkOut: widget.checkOut,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AspectRatio(
                                      aspectRatio: 2.5,
                                      child: Stack(
                                        children: [
                                          HebergementImageAnimator(
                                              hebergement: hebergement),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 5),
                                      child: Text(
                                        hebergement.nom ?? 'Default Value',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'AbrilFatface',
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Padding(
                                      padding: EdgeInsets.only(left: 5),
                                      child: Text(
                                        '${hebergement.ville}, ${hebergement.pays}',
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Visibility(
                                      visible: hebergement.categorie.idCat == 1,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 5, bottom: 10),
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
                                    ),
                                    SizedBox(height: 8),

                                    // SizedBox(height: 3),
                                    // Padding(
                                    //   padding:
                                    //       EdgeInsets.only(left: 5, bottom: 5),
                                    //   child: Row(
                                    //     children: [
                                    //       Text(
                                    //         '${hebergement.distance} from city center',
                                    //         style: TextStyle(fontSize: 14),
                                    //       ),
                                    //       SizedBox(width: 80),
                                    //     ],
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
            if (selectedCategoryIndex == 1)
              Expanded(
                child: FutureBuilder<List<Hebergement>>(
                  future: _availabalevillas,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.data != null &&
                        snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/empty.svg',
                              width: 150,
                              height: 150,
                            ),
                            SizedBox(height: 20),
                            Text('No accommodations found',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                      );
                    } else {
                      List<Hebergement> hebergements = snapshot.data!;
                      print("nbhebergement");
                      print(hebergements.length);
                      return Padding(
                        padding: EdgeInsets.all(16),
                        child: ListView.separated(
                          itemCount: hebergements.length,
                          separatorBuilder: (BuildContext context, int index) {
                            return SizedBox(height: 16);
                          },
                          itemBuilder: (context, index) {
                            Hebergement hebergement = hebergements[index];

                            int nbEtoiles = hebergement.nbEtoile != null
                                ? int.tryParse(hebergement.nbEtoile!) ?? 0
                                : 0;

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AcommodationPage(
                                      hebergement: hebergement,
                                      checkIn: widget.checkIn,
                                      checkOut: widget.checkOut,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AspectRatio(
                                      aspectRatio: 2.5,
                                      child: Stack(
                                        children: [
                                          HebergementImageAnimator(
                                              hebergement: hebergement),
                                        ],
                                      ),
                                    ),

                                    Padding(
                                      padding: EdgeInsets.only(left: 5),
                                      child: Text(
                                        hebergement.nom ?? 'Default Value',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding: EdgeInsets.only(left: 5),
                                      child: Text(
                                        '${hebergement.ville}, ${hebergement.pays}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),

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
                                    SizedBox(height: 4),
                                    Padding(
                                      padding: EdgeInsets.only(left: 5),
                                      child: Text(
                                        '${hebergement.nbChambres} rooms, ${hebergement.nbSallesDeBains} bathrooms',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    // SizedBox(height: 4),
                                    // Row(
                                    //   children: [
                                    //     Text(
                                    //       '${hebergement.distance} from city center',
                                    //       style: TextStyle(fontSize: 14),
                                    //     ),
                                    //     SizedBox(width: 80),
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
            if (selectedCategoryIndex == 2)
              Expanded(
                child: FutureBuilder<List<Hebergement>>(
                  future: _availabaleAppartement,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.data != null &&
                        snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/empty.svg',
                              width: 150,
                              height: 150,
                            ),
                            SizedBox(height: 20),
                            Text('No accommodations found',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                      );
                    } else {
                      List<Hebergement> hebergements = snapshot.data!;
                      print("nbhebergement");
                      print(hebergements.length);
                      return Padding(
                        padding: EdgeInsets.all(16),
                        child: ListView.separated(
                          itemCount: hebergements.length,
                          separatorBuilder: (BuildContext context, int index) {
                            return SizedBox(height: 16);
                          },
                          itemBuilder: (context, index) {
                            Hebergement hebergement = hebergements[index];

                            int nbEtoiles = hebergement.nbEtoile != null
                                ? int.tryParse(hebergement.nbEtoile!) ?? 0
                                : 0;

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AcommodationPage(
                                      hebergement: hebergement,
                                      checkIn: widget.checkIn,
                                      checkOut: widget.checkOut,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AspectRatio(
                                      aspectRatio: 2.5,
                                      child: Stack(
                                        children: [
                                          HebergementImageAnimator(
                                              hebergement: hebergement),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 5),
                                      child: Text(
                                        hebergement.nom ?? 'Default Value',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 5),
                                      child: Text(
                                        '${hebergement.ville}, ${hebergement.pays}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
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
                                    SizedBox(height: 4),
                                    Padding(
                                      padding: EdgeInsets.only(left: 5),
                                      child: Text(
                                        '${hebergement.nbChambres} rooms, ${hebergement.nbSallesDeBains} bathrooms',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleCategory(String name, int index) {
    bool isSelected = index == selectedCategoryIndex;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedCategoryIndex = index;
          catindex = index + 1;
        });
      },
      style: ElevatedButton.styleFrom(
        minimumSize: Size(100, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: isSelected ? Colors.blue[900] : Colors.grey[50],
        foregroundColor: isSelected ? Colors.white : Colors.blue[900],

        elevation: isSelected ? 4 : 0,
        shadowColor: Colors.black.withOpacity(0.2), // Shadow color
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 16,
          fontFamily: 'AbrilFatface', // Font size
        ),
      ),
    );
  }

  Widget buildSearchBar() {
    return Stack(children: [
      Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          // Default border that's shown
                          borderSide:
                              BorderSide(color: Colors.blue[900]!, width: 1.0),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        prefixIcon: IconButton(
                          icon: Icon(Icons.arrow_back_ios_new_outlined,
                              color: Colors.blue[900]),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      controller: searchcontroller,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ]);
  }

/* Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[900],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_outlined),
            color: Colors.white,
            onPressed: () {
              // Implement back button functionality here
            },
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paris',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Mar 28 - Mar 29',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.search),
            color: Colors.white,
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    child: _SearchCard(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}*/
}

class SearchCard extends StatefulWidget {
  const SearchCard({Key? key}) : super(key: key);

  @override
  _SearchCardState createState() => _SearchCardState();
}

class _SearchCardState extends State<SearchCard> {
  late final TextEditingController locationTextController;
  late final TextEditingController dateFromTextController;
  late final TextEditingController dateToTextController;

  @override
  void initState() {
    super.initState();
    locationTextController = TextEditingController(text: 'Paris');
    DateTime now = DateTime.now();
    dateFromTextController =
        TextEditingController(text: DateFormat('dd MMM yyyy').format(now));
    dateToTextController =
        TextEditingController(text: DateFormat('dd MMM yyyy').format(now));
  }

  @override
  void dispose() {
    locationTextController.dispose();
    dateFromTextController.dispose();
    dateToTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.withAlpha(50),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ... Rest of your code
        ],
      ),
    );
  }
}
