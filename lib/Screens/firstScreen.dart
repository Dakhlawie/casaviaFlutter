import 'dart:async';
import 'package:casavia/Screens/core/acommodation.dart';
import 'package:casavia/Screens/core/notification.dart';
import 'package:casavia/Screens/core/rate.dart';
import 'package:casavia/model/hebergement.dart';
import 'package:casavia/model/userModel.dart';
import 'package:casavia/services/AuthService.dart';
import 'package:casavia/services/HebergementService.dart';
import 'package:casavia/services/UserPosition.dart';
import 'package:casavia/services/notificationService.dart';
import 'package:casavia/services/recommandationService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  NotificationService notificationServ = NotificationService();
  int _unseenCount = 0;
  bool showTop10 = false;
  Future<void> _fetchUserId() async {
    AuthService authService = AuthService();
    final prefs = await SharedPreferences.getInstance();
    final storedCurrency = prefs.getString('selectedCurrency');

    int? userId = await authService.getUserIdFromToken();

    if (userId != null) {
      Provider.of<UserModel>(context, listen: false).setUserId(userId);
      int count =
          await notificationServ.countUnseenNotificationsByUserId(userId);
      setState(() {
        _unseenCount = count;
      });
      var recommendedHebergements =
          await recommandationService.getRecommendedHebergementsByUser(userId);
      var offers = await hebergementService
          .fetchHebergementsWithOffersBasedOnCurrency(userId);
      var withoutAvis =
          await hebergementService.findHebergementsWithoutAvisByUser(userId);

      setState(() {
        if (recommendedHebergements != null &&
            recommendedHebergements.isNotEmpty) {
          hebergementsFuture = Future.value(recommendedHebergements);
        } else {
          showTop10 = true;
          if (storedCurrency != null) {
            hebergementsFuture = hebergementService
                .fetchTopHebergementsByCurrency(storedCurrency);
          } else {
            hebergementsFuture = hebergementService.fetchTopHebergements();
          }
        }
        offreFuture = Future.value(offers);
        withoutAvisFuture = Future.value(withoutAvis);
      });
    } else {
      setState(() {
        showTop10 = true;
        if (storedCurrency != null) {
          hebergementsFuture =
              hebergementService.fetchTopHebergementsByCurrency(storedCurrency);
        } else {
          hebergementsFuture = hebergementService.fetchTopHebergements();
        }
      });
    }

    print('USERID');
    print(userId);
  }

  final PageController _pageController = PageController(initialPage: 0);
  late Timer? _timer;
  Future<List<Hebergement>>? hebergementsFuture;
  Future<List<Hebergement>>? offreFuture;
  Future<List<Hebergement>>? withoutAvisFuture;

  RecommandationService recommandationService = RecommandationService();
  HebergementService hebergementService = HebergementService();
  List<Hebergement> extendedHebergements = [];

  @override
  void initState() {
    super.initState();

    _fetchUserId().then((_) {
      hebergementsFuture?.then((hebergements) {
        setState(() {
          extendedHebergements = [...hebergements, ...hebergements];
        });
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
          if (_pageController.hasClients) {
            int nextPage = _pageController.page!.toInt() + 1;
            if (nextPage >= extendedHebergements.length) {
              nextPage = 0;
              _pageController.jumpToPage(0);
            } else {
              _pageController.animateToPage(
                nextPage,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _timer!.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Casavia',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'AbrilFatface',
                      ),
                    ),
                    Stack(
                      children: [
                        IconButton(
                          icon: Icon(CupertinoIcons.bell, size: 24),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotificationPage(),
                              ),
                            );

                            if (result == true) {
                              setState(() {
                                _unseenCount = 0;
                              });
                            }
                          },
                        ),
                        if (_unseenCount > 0)
                          Positioned(
                            right: 5,
                            top: 0,
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.blue[900],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                '$_unseenCount',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Search...',
                    suffixIcon: Icon(
                      Icons.search,
                      color: Colors.blue[900],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(16),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  showTop10 ? 'Top 10' : 'Suggestions for you',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'AbrilFatface',
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 350,
                  child: FutureBuilder<List<Hebergement>>(
                    future: hebergementsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center();
                      } else {
                        final hebergements = snapshot.data!;
                        extendedHebergements = [
                          ...hebergements,
                          ...hebergements
                        ];
                        return PageView.builder(
                          controller: _pageController,
                          itemCount: extendedHebergements.length,
                          itemBuilder: (context, index) {
                            final hebergement = extendedHebergements[
                                index % hebergements.length];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: GestureDetector(
                                onTap: () {
                                  DateTime today = DateTime.now();

                                  DateTime tomorrow =
                                      today.add(Duration(days: 1));

                                  DateTime dayAfterTomorrow =
                                      today.add(Duration(days: 2));
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AcommodationPage(
                                        hebergement: hebergement,
                                        checkIn: DateFormat('dd/MM/yyyy')
                                            .format(tomorrow),
                                        checkOut: DateFormat('dd/MM/yyyy')
                                            .format(dayAfterTomorrow),
                                      ),
                                    ),
                                  );
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        image: DecorationImage(
                                          image: MemoryImage(
                                              hebergement.images[0].image),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.6),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 16,
                                      bottom: 16,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            hebergement.nom,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            ' ${hebergement.pays} ${hebergement.ville}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: 20),
                FutureBuilder<List<Hebergement>>(
                  future: offreFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Container();
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Offers for You',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'AbrilFatface',
                            ),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Container(
                              height: 100,
                              width: 100000,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  final offer = snapshot.data![index];
                                  final firstOffer = offer.offres != null &&
                                          offer.offres!.isNotEmpty
                                      ? offer.offres![0]
                                      : null;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        DateTime today = DateTime.now();

                                        DateTime tomorrow =
                                            today.add(Duration(days: 1));

                                        DateTime dayAfterTomorrow =
                                            today.add(Duration(days: 2));
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AcommodationPage(
                                              hebergement: offer,
                                              checkIn: DateFormat('dd/MM/yyyy')
                                                  .format(tomorrow),
                                              checkOut: DateFormat('dd/MM/yyyy')
                                                  .format(dayAfterTomorrow),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.3),
                                              spreadRadius: 2,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        width: 330,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: GestureDetector(
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.horizontal(
                                                          left: Radius.circular(
                                                              10)),
                                                  child: SizedBox(
                                                    width: 100,
                                                    height: 100,
                                                    child: Image.memory(
                                                      offer.images[0].image,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 10),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      offer.nom,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily:
                                                            'AbrilFatface',
                                                      ),
                                                    ),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      '${offer.ville},${offer.pays}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                    SizedBox(height: 10),
                                                    LimitedTimeDealWidget(
                                                        discount: 20),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
                SizedBox(height: 20),
                FutureBuilder<List<Hebergement>>(
                  future: withoutAvisFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Container();
                    } else {
                      return Container(
                        height: 400,
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final hebergement = snapshot.data![index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
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
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                      ),
                                      child: Image.memory(
                                        hebergement.images[0].image,
                                        fit: BoxFit.fill,
                                        width: 100,
                                        height: 150,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'How was ${hebergement.nom}?',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              'Don\'t forget to leave a review .',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        RatePage(
                                                      hebergement: hebergement,
                                                      startDate: '',
                                                      endDate: '',
                                                    ),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.blue[900],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: Text(
                                                  '        Rate your stay         ',
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LimitedTimeDealWidget extends StatelessWidget {
  final double discount;

  LimitedTimeDealWidget({required this.discount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(12),
        color: Colors.green,
      ),
      child: Text(
        '${discount} % off',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
