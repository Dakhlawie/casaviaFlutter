import 'dart:typed_data';

import 'package:casavia/Screens/core/chambrelist.dart';
import 'package:casavia/model/avis.dart';
import 'package:casavia/model/hebergement.dart';
import 'package:casavia/services/UserService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AvisList extends StatefulWidget {
  final Hebergement hebergement;
  final List<Avis> listAvis;
 final  String checkIn;
 final  String checkOut;

  const AvisList({Key? key, required this.listAvis,required this.checkIn,required this.checkOut,required this.hebergement}) : super(key: key);

  @override
  State<AvisList> createState() => _AvisListState();
}

class _AvisListState extends State<AvisList> {
  Map<int, bool> showMore = {};
  Map<int, bool> _isExpandedMap = {};

  String _getShortText(String text) {
    if (text.length > 100) {
      return text.substring(0, 100) + '...';
    } else {
      return text;
    }
  }

  @override
  Widget build(BuildContext context) {
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Reviews",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'AbrilFatface',
                  ),
                ),
                SizedBox(height: 20),
                ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.listAvis.length,
                  separatorBuilder: (context, index) => SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final Avis avis = widget.listAvis[index];
                    bool isExpanded = _isExpandedMap[index] ?? false;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    FutureBuilder<Uint8List?>(
                                      future: UserService()
                                          .getImageFromFS(avis.user!.id),
                                      builder: (context, imageSnapshot) {
                                        if (imageSnapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        } else if (imageSnapshot.hasError) {
                                          return Text(
                                              'Erreur: ${imageSnapshot.error}');
                                        } else if (imageSnapshot.hasData &&
                                            imageSnapshot.data != null) {
                                          return CircleAvatar(
                                            backgroundImage: MemoryImage(
                                                imageSnapshot.data!),
                                          );
                                        } else {
                                          return SizedBox.shrink();
                                        }
                                      },
                                    ),
                                    SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${avis.user!.nom} ${avis.user!.prenom} ${avis.user!.flag}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(''),
                                      ],
                                    ),
                                  ],
                                ),
                                Text(
                                  avis.moyenne!,
                                  style: TextStyle(
                                      color: Colors.blue[900],
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Padding(
                              padding: EdgeInsets.only(left: 40),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.sentiment_satisfied,
                                        color: Colors.blue[900],
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              isExpanded
                                                  ? avis.avis
                                                  : _getShortText(avis.avis),
                                              style: TextStyle(
                                                  color: Colors.grey[500]),
                                            ),
                                            if (!isExpanded &&
                                                avis.avis.length > 100)
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _isExpandedMap[index] =
                                                        true;
                                                  });
                                                },
                                                child: Text(
                                                  'Show more',
                                                  style: TextStyle(
                                                    color: Colors.blue[900],
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            if (isExpanded)
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _isExpandedMap[index] =
                                                        false;
                                                  });
                                                },
                                                child: Text(
                                                  'Show less',
                                                  style: TextStyle(
                                                    color: Colors.blue[900],
                                                    fontWeight: FontWeight.bold,
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
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.sentiment_dissatisfied,
                                          color: Colors.blue[900],
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                isExpanded
                                                    ? avis.avisNegative!
                                                    : _getShortText(
                                                        avis.avisNegative!),
                                                style: TextStyle(
                                                    color: Colors.grey[500]),
                                              ),
                                              if (!isExpanded &&
                                                  avis.avisNegative!.length >
                                                      100)
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _isExpandedMap[index] =
                                                          true;
                                                    });
                                                  },
                                                  child: Text(
                                                    'Show more',
                                                    style: TextStyle(
                                                      color: Colors.blue[900],
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              if (isExpanded)
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _isExpandedMap[index] =
                                                          false;
                                                    });
                                                  },
                                                  child: Text(
                                                    'Show less',
                                                    style: TextStyle(
                                                      color: Colors.blue[900],
                                                      fontWeight:
                                                          FontWeight.bold,
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
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue[900],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChambreListPage(
                                hebergement: widget.hebergement,
                                checkIn: widget.checkIn,
                                checkOut: widget.checkOut,
                              ),
                            ),
                          );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 5),
                        Text(
                          'Book Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
