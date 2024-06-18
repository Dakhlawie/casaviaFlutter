import 'dart:typed_data';
import 'package:casavia/model/chambre.dart';
import 'package:casavia/model/equipement.dart';
import 'package:casavia/model/hebergement.dart';
import 'package:casavia/model/offre.dart';
import 'package:casavia/services/HebergementService.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvailableRooms extends StatefulWidget {
  final Hebergement hebergement;
  final String checkIn;
  final String checkOut;

  AvailableRooms({
    required this.hebergement,
    required this.checkIn,
    required this.checkOut,
    Key? key,
  }) : super(key: key);

  @override
  State<AvailableRooms> createState() => _AvailableRoomsState();
}

class _AvailableRoomsState extends State<AvailableRooms> {
  List<Chambre> chambres = [];
  List<List<int>> images = [];
  HebergementService hebergementService = HebergementService();
  Map<int, bool> _showDetailsMap = {};
  String? selectedCurrency;
  Hebergement? hebergement;
  Map<int, int> selectedRoomsCount = {};
  void _selectRoom(int chambreId) {
    setState(() {
      selectedRoomsCount[chambreId] = (selectedRoomsCount[chambreId] ?? 0) + 1;
    });
  }

  void _confirmSelection() {
    Navigator.pop(context, selectedRoomsCount);
  }

  @override
  void initState() {
    super.initState();
    hebergement = widget.hebergement;
    filterAvailableRooms();
    _initializeCurrencyAndConvert();
  }

  OffreHebergement? getApplicableOffer(int roomId) {
    for (var offre in widget.hebergement.offres ?? []) {
      if (offre.rooms.contains(roomId)) {
        return offre;
      }
    }
    return null;
  }

  double calculateDiscountedPrice(double price, int discount) {
    return price - (price * discount / 100);
  }

  Future<void> _initializeCurrencyAndConvert() async {
    final prefs = await SharedPreferences.getInstance();
    final storedCurrency = prefs.getString('selectedCurrency') ?? 'EUR';
    selectedCurrency = storedCurrency;

    try {
      Hebergement convertedHebergement = await hebergementService
          .convertHebergement(widget.hebergement, selectedCurrency!);
      setState(() {
        hebergement = convertedHebergement;
      });
      filterAvailableRooms();
    } catch (e) {
      print('Failed to convert prices: $e');
    }
  }

  Future<void> filterAvailableRooms() async {
    List<Chambre> availableRooms = [];
    List<List<int>> images = [];

    for (var chambre in widget.hebergement.chambres) {
      bool isAvailable = await hebergementService.checkAvailability(
          chambre.chambreId, widget.checkIn, widget.checkOut);
      if (isAvailable) {
        availableRooms.add(chambre);
        List<int>? imageBytes =
            await hebergementService.getImageBytesForChambre(chambre.chambreId);
        images.add(imageBytes ?? []);
      }
    }

    setState(() {
      this.chambres = availableRooms;
      this.images = images;
    });
  }

  void _toggleRoomSelection(int index) async {
    var chambre = chambres[index];
    int? roomCount =
        await _showSelectRoomBottomSheet(context, chambre.chambreId);

    if (roomCount != null) {
      setState(() {
        selectedRoomsCount[chambre.chambreId] = roomCount;
      });
    }
  }

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
      case 'TND':
        return 'TND';
      case 'AMD':
        return '֏';

      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () {
            Navigator.pop(context, selectedRoomsCount!);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: chambres.length,
          itemBuilder: (context, index) {
            var chambre = chambres[index];
            var image = images[index];
            final applicableOffer = getApplicableOffer(chambre.chambreId);
            final discountPercentage = applicableOffer != null
                ? int.tryParse(applicableOffer.discount) ?? 0
                : 0;
            final discountedPrice = applicableOffer != null
                ? calculateDiscountedPrice(chambre.prix, discountPercentage)
                : null;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          image: image.isNotEmpty
                              ? DecorationImage(
                                  image: MemoryImage(Uint8List.fromList(image)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: image.isEmpty ? Colors.grey : null,
                        ),
                        height: 200,
                        width: double.infinity,
                        child: image.isEmpty
                            ? Center(child: Text('No image data available'))
                            : null,
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${chambre.type}',
                            style: TextStyle(
                              fontFamily: 'AbrilFatface',
                              fontSize: 18,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (discountedPrice != null)
                                Text(
                                  '${getCurrencySymbol(hebergement!.currency)}${chambre.prix}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                '${getCurrencySymbol(hebergement!.currency)}${discountedPrice ?? chambre.prix}',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: discountedPrice != null
                                      ? Colors.red
                                      : Colors.black,
                                ),
                              ),
                              Text(
                                '/ per night',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.blue[900]),
                              SizedBox(width: 5),
                              Text(chambre.floor ?? '',
                                  style: TextStyle(fontSize: 14)),
                            ],
                          ),
                          SizedBox(width: 10),
                          Row(
                            children: [
                              Icon(Icons.visibility, color: Colors.blue[900]),
                              SizedBox(width: 5),
                              Text(chambre.view ?? '',
                                  style: TextStyle(fontSize: 14)),
                            ],
                          ),
                          SizedBox(width: 10),
                          Row(
                            children: [
                              Icon(Icons.hotel, color: Colors.blue[900]),
                              SizedBox(width: 5),
                              Text(chambre.bed ?? '',
                                  style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      ExpandableTextWidget(text: chambre.description ?? ''),
                      SizedBox(height: 8.0),
                      if (_showDetailsMap[index] ?? false)
                        FutureBuilder<List<Equipement>>(
                          future: hebergementService
                              .getEquipements(chambre.chambreId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.hasData) {
                              return Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: snapshot.data!
                                    .map((equipement) => Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(FontAwesomeIcons.check,
                                                color: Colors.blue[900]),
                                            SizedBox(width: 4),
                                            Text(equipement.nom,
                                                style: TextStyle(
                                                    color: Colors.grey)),
                                          ],
                                        ))
                                    .toList(),
                              );
                            } else {
                              return Text('No equipment found');
                            }
                          },
                        ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _toggleRoomSelection(index);
                              // if (_showDetailsMap[index] ?? false) {
                              //   _showSelectRoomBottomSheet(
                              //       context, chambre.chambreId);
                              // }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[900],
                              textStyle: TextStyle(color: Colors.white),
                            ),
                            child: Text(
                              'Select Room',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(width: 80),
                          TextButton.icon(
                            label: Text(
                              _showDetailsMap[index] ?? false
                                  ? 'Show Less'
                                  : 'More Details',
                              style: TextStyle(color: Colors.black),
                            ),
                            onPressed: () {
                              setState(() {
                                _showDetailsMap[index] =
                                    !(_showDetailsMap[index] ?? false);
                              });
                            },
                            icon: Icon(
                              _showDetailsMap[index] ?? false
                                  ? Icons.arrow_circle_up
                                  : Icons.arrow_circle_down,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _confirmSelection();
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(12),
              backgroundColor: Colors.blue[900],
            ),
            child: Text('Finish',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'AbrilFatface',
                )),
          ),
        ),
      ),
    );
  }

  Future<int?> _showSelectRoomBottomSheet(
      BuildContext context, int chambreId) async {
    int availableRooms = await hebergementService.getAvailableRooms(
        chambreId, widget.checkIn, widget.checkOut);

    return await showModalBottomSheet<int>(
      context: context,
      builder: (context) {
        int roomCount = 1;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Number of rooms',
                        style: TextStyle(fontSize: 18),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: roomCount > 1
                                  ? () {
                                      setState(() {
                                        if (roomCount > 1) roomCount--;
                                      });
                                    }
                                  : null,
                              child: Icon(Icons.remove,
                                  color: roomCount > 1
                                      ? Colors.blue[900]
                                      : Colors.grey),
                            ),
                            SizedBox(width: 12),
                            Text(
                              '$roomCount',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(width: 12),
                            InkWell(
                              onTap: roomCount < availableRooms
                                  ? () {
                                      setState(() {
                                        if (roomCount < availableRooms)
                                          roomCount++;
                                      });
                                    }
                                  : null,
                              child: Icon(Icons.add,
                                  color: roomCount < availableRooms
                                      ? Colors.blue[900]
                                      : Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _confirmSelection();
                    },
                    child: Text('Confirm'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class ExpandableTextWidget extends StatefulWidget {
  final String text;
  const ExpandableTextWidget({Key? key, required this.text}) : super(key: key);

  @override
  _ExpandableTextWidgetState createState() => _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Text(
            widget.text,
            maxLines: isExpanded ? null : 2,
            overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
        Row(
          mainAxisAlignment:
              MainAxisAlignment.start, // Align the action text to the right
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Text(
                isExpanded ? 'show less' : 'show more',
                style: TextStyle(color: Colors.blue[900], fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
