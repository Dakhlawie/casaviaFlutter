import 'dart:typed_data';

import 'package:casavia/Screens/core/chambrelist.dart';
import 'package:casavia/model/avis.dart';
import 'package:casavia/model/hebergement.dart';
import 'package:casavia/services/AvisService.dart';
import 'package:casavia/services/UserService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AvisList extends StatefulWidget {
  final Hebergement hebergement;
  const AvisList({Key? key, required this.hebergement}) : super(key: key);

  @override
  State<AvisList> createState() => _AvisListState();
}

class _AvisListState extends State<AvisList> {
  final AvisService _avisService = AvisService();
  late Future<List<Avis>> _avisFuture;
  @override
  void initState() {
    super.initState();
    _avisFuture = _avisService.fetchAvis();
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
          title: Text("Reviews"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: FutureBuilder<List<Avis>>(
              future: _avisFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final Avis avis = snapshot.data![index];

                      if (avis.hebergement.hebergementId ==
                          widget.hebergement.hebergementId) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                          ),
                          child: Column(children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FutureBuilder<Uint8List?>(
                                  future: UserService()
                                      .getImageFromFS(avis.user.id),
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
                                        backgroundImage:
                                            MemoryImage(imageSnapshot.data!),
                                      );
                                    } else {
                                      return SizedBox.shrink();
                                    }
                                  },
                                ),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${avis.user.nom} ${avis.user.prenom}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      avis.user.pays ?? '',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Padding(
                              padding: EdgeInsets.only(left: 50),
                              child: Text(
                                '"${avis.avis}"',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            SizedBox(height: 5),
                            Padding(
                              padding: EdgeInsets.only(left: 50, right: 20),
                              child: Divider(
                                color: Colors.black,
                                thickness: 1,
                              ),
                            ),
                          ]),
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    },
                  );
                }
              },
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
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.blue[900],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChambreListPage(
                                  hebergement: widget.hebergement,
                                  checkIn: '',
                                  checkOut: '',
                                )),
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
