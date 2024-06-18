import 'package:casavia/Screens/login/login_page.dart';
import 'package:casavia/model/avis.dart';
import 'package:casavia/model/userModel.dart';
import 'package:casavia/services/AuthService.dart';
import 'package:casavia/services/AvisService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/svg.dart';

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  AvisService avisserv = AvisService();
  List<Avis> _avisList = [];
  bool _isLoading = true;
  Map<int, bool> _isExpandedMap = {};

  Future<void> _fetchAvis(int userId) async {
    try {
      List<Avis> avisList = await avisserv.fetchAvisByUserId(userId);
      setState(() {
        _avisList = avisList;
        _isLoading = false;
        _isExpandedMap = {for (int i = 0; i < avisList.length; i++) i: false};
      });
    } catch (e) {
      print('Failed to load avis: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  Future<void> _fetchUserId() async {
    AuthService authService = AuthService();
    int? userId = await authService.getUserIdFromToken();
    if (userId != null && userId != 0) {
      Provider.of<UserModel>(context, listen: false).setUserId(userId);
      await _fetchAvis(userId);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
    print('USERID');
    print(userId);
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserModel>(context).userId;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_outlined),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: userId == null || userId == 0
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/reviews.svg',
                        height: 200,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "You don't have any reviews",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'AbrilFatface',
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Connect to be able to book and leave reviews after your stay at a property",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.all(12),
                            backgroundColor: Colors.blue[900],
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : _isLoading
                ? Center(child: CircularProgressIndicator())
                : _avisList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/reviews.svg',
                              height: 200,
                            ),
                            SizedBox(height: 20),
                            Text(
                              "You don't have any reviews",
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'AbrilFatface',
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                "After your stay at a property, you'll be invited to write a review",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reviews',
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontFamily: 'AbrilFatface',
                                fontSize: 30.0,
                              ),
                            ),
                            SizedBox(height: 30),
                            Expanded(
                              child: ListView.separated(
                                itemCount: _avisList.length,
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: 5),
                                itemBuilder: (context, index) {
                                  Avis avis = _avisList[index];
                                  bool isExpanded =
                                      _isExpandedMap[index] ?? false;
                                  return Container(
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
                                      onTap: () {},
                                      child: IntrinsicHeight(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                    top: Radius.circular(10),
                                                  ),
                                                  child: SizedBox(
                                                    width: double.infinity,
                                                    height: 100,
                                                    child: Image.memory(
                                                      avis.hebergement!
                                                          .images[0]!.image,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 8,
                                                  right: 8,
                                                  child: Container(
                                                    color: Colors.black54,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      vertical: 4,
                                                      horizontal: 8,
                                                    ),
                                                    child: Text(
                                                      DateFormat('MMM d, yyyy')
                                                          .format(avis.date),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                            "${avis.hebergement!.nom}",
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontFamily:
                                                                    'AbrilFatface',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        Text('${avis.moyenne}',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .blue[900],
                                                                fontFamily:
                                                                    'AbrilFatface',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold))
                                                      ]),
                                                  SizedBox(height: 10),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .sentiment_satisfied,
                                                        color: Colors.blue[900],
                                                      ),
                                                      SizedBox(width: 8),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              isExpanded
                                                                  ? avis.avis
                                                                  : _getShortText(
                                                                      avis.avis),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                          .grey[
                                                                      500]),
                                                            ),
                                                            if (!isExpanded &&
                                                                avis.avis
                                                                        .length >
                                                                    100)
                                                              GestureDetector(
                                                                onTap: () {
                                                                  setState(() {
                                                                    _isExpandedMap[
                                                                            index] =
                                                                        true;
                                                                  });
                                                                },
                                                                child: Text(
                                                                  'Show more',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                            .blue[
                                                                        900],
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            if (isExpanded)
                                                              GestureDetector(
                                                                onTap: () {
                                                                  setState(() {
                                                                    _isExpandedMap[
                                                                            index] =
                                                                        false;
                                                                  });
                                                                },
                                                                child: Text(
                                                                  'Show less',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                            .blue[
                                                                        900],
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (avis.avisNegative != null)
                                                    SizedBox(height: 4),
                                                  if (avis.avisNegative != null)
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .sentiment_dissatisfied,
                                                          color:
                                                              Colors.blue[900],
                                                        ),
                                                        SizedBox(width: 8),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                isExpanded
                                                                    ? avis
                                                                        .avisNegative!
                                                                    : _getShortText(
                                                                        avis.avisNegative!),
                                                                style: TextStyle(
                                                                    color: Colors
                                                                            .grey[
                                                                        500]),
                                                              ),
                                                              if (!isExpanded &&
                                                                  avis.avisNegative!
                                                                          .length >
                                                                      100)
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      _isExpandedMap[
                                                                              index] =
                                                                          true;
                                                                    });
                                                                  },
                                                                  child: Text(
                                                                    'Show more',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                              .blue[
                                                                          900],
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                              if (isExpanded)
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      _isExpandedMap[
                                                                              index] =
                                                                          false;
                                                                    });
                                                                  },
                                                                  child: Text(
                                                                    'Show less',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                              .blue[
                                                                          900],
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
      ),
    );
  }

  String _getShortText(String text) {
    const maxLength = 100;
    if (text.length <= maxLength) {
      return text;
    }
    return text.substring(0, maxLength) + '...';
  }
}
