import 'dart:typed_data';

import 'package:casavia/Screens/core/whishlists.dart';
import 'package:casavia/model/hebergement.dart';
import 'package:casavia/model/like.dart';
import 'package:casavia/services/AuthService.dart';
import 'package:casavia/services/LikeSerice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

import 'dart:math' as math;
import 'package:flutter_svg/svg.dart';

class FavoritePage extends StatefulWidget {
  final int userId;

  const FavoritePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late final AuthService _authService;
  late final LikeService _likeService;
  bool _isLoading = true;
  Map<String, List<Hebergement>> _hebergementsByCountry = {};

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _likeService = LikeService();
    _fetchUserLikes();
  }

  Future<void> _fetchUserLikes() async {
    List<Like> likes = await _likeService.getLikesByUser(widget.userId);
    setState(() {
      _isLoading = false;
      _hebergementsByCountry = _groupHebergementsByCountry(likes);
    });
  }

  Map<String, List<Hebergement>> _groupHebergementsByCountry(List<Like> likes) {
    Map<String, List<Hebergement>> grouped = {};
    for (var like in likes) {
      String country = like.hebergement.pays;
      if (grouped.containsKey(country)) {
        grouped[country]!.add(like.hebergement);
      } else {
        grouped[country] = [like.hebergement];
      }
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    bool hasWishlists = _hebergementsByCountry.keys.any(
      (country) => _hebergementsByCountry[country]?.isNotEmpty ?? false,
    );

    return SafeArea(
      child: Scaffold(
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_outlined),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Wishlists',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontFamily: 'AbrilFatface',
                            fontSize: 30.0,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _hebergementsByCountry.keys.length,
                          itemBuilder: (context, index) {
                            String country =
                                _hebergementsByCountry.keys.elementAt(index);
                            List<Hebergement> hebergements =
                                _hebergementsByCountry[country]!;
                            if (hebergements.isNotEmpty)
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Whishlists(
                                        hebergements: hebergements,
                                        country: country,
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 200,
                                      width: double.infinity,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 8.0),
                                      child: hebergements.isNotEmpty &&
                                              hebergements[0].images.isNotEmpty
                                          ? Image.memory(
                                              hebergements[0].images[0].image,
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              color: Colors.transparent,
                                              alignment: Alignment.center,
                                              child: Text('No Image Available'),
                                            ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 16.0),
                                      child: Text(
                                        country,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 16.0),
                                      child: Text(
                                        '${hebergements.length} Saved',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                ),
                              );
                            else
                              return Column(
                                children: [
                                  SvgPicture.asset(
                                    'assets/favorite.svg',
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    'Save what you like for later',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: 'AbrilFatface',
                                    ),
                                  ),
                                ],
                              );
                          },
                        ),
                      ),
                    ]),
              ),
      ),
    );
  }
}
