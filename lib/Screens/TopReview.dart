import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:casavia/model/avis.dart';
import 'package:casavia/services/AvisService.dart';
import 'package:casavia/services/UserService.dart';

class TopReview extends StatefulWidget {
  const TopReview({Key? key}) : super(key: key);

  @override
  State<TopReview> createState() => _TopReviewState();
}

class _TopReviewState extends State<TopReview> {
  Future<List<Avis>>? _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = AvisService().findTopAvisHebergement(44);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Avis>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child:
                Text('Erreur lors du chargement des avis: ${snapshot.error}'),
          );
        } else if (snapshot.hasData) {
          final List<Avis> reviews = snapshot.data!;

          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final Avis review = reviews[index];

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        FutureBuilder<Uint8List?>(
                          future: UserService().getImageFromFS(review.user!.id),
                          builder: (context, imageSnapshot) {
                            if (imageSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (imageSnapshot.hasError ||
                                !imageSnapshot.hasData) {
                              return CircleAvatar(
                                backgroundColor: Colors.grey,
                                child: Icon(Icons.person),
                              );
                            } else {
                              return CircleAvatar(
                                backgroundImage:
                                    MemoryImage(imageSnapshot.data!),
                              );
                            }
                          },
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${review.user!.nom} ${review.user!.prenom}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  review.user!.pays ?? '',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  review.avis,
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        review.moyenne.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          return Center(
            child: Text('Aucun avis trouvé'),
          );
        }
      },
    );
  }
}
