import 'dart:convert';
import 'dart:typed_data';
import 'package:casavia/Screens/core/ReservationEtape2.dart';
import 'package:casavia/Screens/login/login_page.dart';
import 'package:casavia/model/categorieEquipement.dart';
import 'package:casavia/model/equipement.dart';
import 'package:casavia/model/offre.dart';
import 'package:casavia/model/user.dart';
import 'package:casavia/model/userModel.dart';
import 'package:casavia/services/ChambresServices.dart';
import 'package:casavia/services/UserService.dart';
import 'package:casavia/services/equipementService.dart';
import 'package:casavia/widgets/custom_expandable.dart';
import 'package:casavia/services/currencyService.dart';
import 'package:expandable/expandable.dart';
import 'package:casavia/model/chambre.dart';
import 'package:casavia/model/hebergement.dart';
import 'package:casavia/services/AuthService.dart';
import 'package:casavia/services/HebergementService.dart';
import 'package:casavia/services/ReservationService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChambreListPage extends StatefulWidget {
  final Hebergement hebergement;
  final String checkIn;
  final String checkOut;

  const ChambreListPage(
      {Key? key,
      required this.hebergement,
      required this.checkIn,
      required this.checkOut})
      : super(key: key);

  @override
  State<ChambreListPage> createState() => _ChambreListPageState();
}

class _ChambreListPageState extends State<ChambreListPage> {
  User? user;
  Future<void> _fetchUserId() async {
    AuthService authService = AuthService();
    int? userId = await authService.getUserIdFromToken();
    if (userId != null) {
      Provider.of<UserModel>(context, listen: false).setUserId(userId);
      user = await UserService().getUserById(userId);
    }
    print('USERID');
    print(userId);
  }

  EquipementService service = EquipementService();
  ChambresServices chambreserv = ChambresServices();
  int numberOfNights = 0;
  String? symbol;
  double? convertedPrice;
  double calculatePrice(String checkIn, String checkOut, double prixParNuit) {
    DateTime startDate = DateFormat('dd/MM/yyyy').parse(checkIn);
    DateTime endDate = DateFormat('dd/MM/yyyy').parse(checkOut);
    numberOfNights = endDate.difference(startDate).inDays;
    double totalPrice = numberOfNights * prixParNuit;

    return totalPrice;
  }

  Set<int> _selectedRoomIndices = Set<int>();
  void loadCategoryAndEquipements() async {
    service = EquipementService();
    try {
      category = await service.getCategoryByNom('Room');
      print("Loaded category: ${category?.nom}");
      futureEquipements = service.getEquipementsByCategorieHebregement(
          category?.categorieId ?? 0, widget.hebergement.hebergementId);
      setState(() {});
    } catch (e) {
      print("Error loading category or equipment: $e");
    }
  }

  double? total;
  TextEditingController _checkInController = TextEditingController();
  TextEditingController _checkOutController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _numberOfRoomsController = TextEditingController();
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  DateTime? _selectedDate;
  String _originalPriceText = "";
  List<Chambre> rooms = [];
  final HebergementService _hebergementService = HebergementService();
  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    print("hi");
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: Colors.blue[900]!,
                onPrimary: Colors.white,
                surface: Colors.blue[900]!,
                onSurface: Colors.white,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    textStyle: TextStyle(color: Colors.white)),
              ),
            ),
            child: child!,
          );
        },
      );
      print("Date picker closed");
      print(picked);
      if (picked != null) {
        setState(() {
          final DateFormat formatter = DateFormat('dd-MMM-yyyy');
          String formattedDate = formatter.format(picked);

          if (isCheckIn) {
            _checkInDate = picked;
            _checkInController.text = formattedDate;
          } else {
            _checkOutDate = picked;
            _checkOutController.text = formattedDate;
          }
        });
      }
      print(_checkInController.text);
      print(_checkOutController.text);
    } catch (e, stackTrace) {
      print("An error occurred: $e");
      print("Error picking date: $e");
      print("StackTrace: $stackTrace");
    }
  }

  Future<void> filterAvailableRooms() async {
    List<Chambre> availableRooms = [];
    for (var chambre in widget.hebergement.chambres!) {
      bool isAvailable = await _hebergementService.checkAvailability(
          chambre.chambreId, widget.checkIn, widget.checkOut);
      if (isAvailable) {
        availableRooms.add(chambre);
      }
    }
    setState(() {
      this.rooms = availableRooms;
    });
  }

  final ReservationService _reservationservice = ReservationService();
  final AuthService _authService = AuthService();
  int? _selectedValue;
  CategorieEquipement? category;
  late Future<List<Equipement>> futureEquipements;

  @override
  void initState() {
    super.initState();
    _numberOfRoomsController.text = "1";
    _originalPriceText = _priceController.text;
    _checkInController.text = _checkOutController.text =
        DateFormat('dd MMM yyyy').format(DateTime.now());
    _selectedValue = 1;
    filterAvailableRooms();
    loadCategoryAndEquipements();
    _fetchUserId();
  }

  Map<String, int> _selectedRoomCounts = {};
  List<int> selectedRoomIds = [];
  int totalRoomCount = 0;
  bool isExpanded = false;
  int _selectedImageIndex = 0;
  Map<int, bool> _showDetailsMap = {};
  int _selectedRoomIndex = -1;

  double get _totalPrice => _selectedRoomIndices
      .map((index) => widget.hebergement.chambres![index].prix ?? 0)
      .fold(0, (previousValue, prix) => previousValue + prix);

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

  List<OffreHebergement> getOffres() {
    return widget.hebergement.offres ?? [];
  }

  double calculateDiscountedPrice(double price, int discountPercentage) {
    return price - (price * discountPercentage / 100);
  }

  OffreHebergement? getApplicableOffer(int roomId) {
    for (var offre in widget.hebergement.offres ?? []) {
      if (offre.rooms.contains(roomId)) {
        return offre;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final offres = getOffres();
    String currencySymbol =
        utf8.decode(widget.hebergement.currency.runes.toList());

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
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final chambre = rooms[index];
                  final applicableOffer = getApplicableOffer(chambre.chambreId);
                  final discountPercentage = applicableOffer != null
                      ? int.tryParse(applicableOffer.discount) ?? 0
                      : 0;
                  final discountedPrice = applicableOffer != null
                      ? calculateDiscountedPrice(
                          chambre.prix, discountPercentage)
                      : null;

                  _showDetailsMap.putIfAbsent(index, () => false);
                  return Padding(
                    padding: EdgeInsets.all(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0),
                          topLeft: Radius.circular(8.0),
                          topRight: Radius.circular(8.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16.0),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<List<int>?>(
                              future:
                                  _hebergementService.getImageBytesForChambre(
                                      rooms[index].chambreId),
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<int>?> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else if (snapshot.data == null) {
                                  return Text('No image data available');
                                } else {
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(8.0),
                                        topRight: Radius.circular(8.0),
                                      ),
                                      image: DecorationImage(
                                        image: MemoryImage(
                                            Uint8List.fromList(snapshot.data!)),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    height: 200,
                                  );
                                }
                              },
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  rooms[index].type ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'AbrilFatface',
                                  ),
                                ),
                                if (discountedPrice != null)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${calculatePrice(widget.checkIn, widget.checkOut, chambre.prix!).toStringAsFixed(2)} ${getCurrencySymbol(widget.hebergement.currency)}",
                                        style: TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        "${calculatePrice(widget.checkIn, widget.checkOut, discountedPrice!).toStringAsFixed(2)} ${getCurrencySymbol(widget.hebergement.currency)}",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Text(
                                    "${calculatePrice(widget.checkIn, widget.checkOut, chambre.prix!).toStringAsFixed(2)} ${getCurrencySymbol(widget.hebergement.currency)}",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                    ),
                                  ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('/per ${numberOfNights} night',
                                    style: TextStyle(color: Colors.grey))
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.location_on,
                                        color: Colors.blue[900]),
                                    SizedBox(width: 5),
                                    Text(rooms[index].floor ?? '',
                                        style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                                SizedBox(width: 10),
                                Row(
                                  children: [
                                    Icon(Icons.visibility,
                                        color: Colors.blue[900]),
                                    SizedBox(width: 5),
                                    Text(rooms[index].view ?? '',
                                        style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                                SizedBox(width: 10),
                                Row(
                                  children: [
                                    Icon(Icons.hotel, color: Colors.blue[900]),
                                    SizedBox(width: 5),
                                    Text(rooms[index].bed ?? '',
                                        style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                              ],
                            ),
                            ExpandableTextWidget(
                                text: rooms[index].description ?? ''),
                            SizedBox(height: 8),
                            if (_showDetailsMap[index] ?? false) ...[
                              FutureBuilder<List<Equipement>>(
                                future: ChambresServices()
                                    .getEquipements(rooms[index].chambreId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else if (snapshot.hasData) {
                                    return Wrap(
                                      spacing: 200,
                                      runSpacing: 20,
                                      children: snapshot.data!
                                          .map((equipement) => Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(FontAwesomeIcons.check,
                                                      color: Colors.blue[900]),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    equipement.nom,
                                                    style: TextStyle(
                                                        color: Colors.grey),
                                                  ),
                                                ],
                                              ))
                                          .toList(),
                                    );
                                  } else {
                                    return Text('No equipment found');
                                  }
                                },
                              ),
                            ],
                            SizedBox(height: 16),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _toggleRoomSelection(index);
                                    if (_selectedRoomIndices.contains(index)) {
                                      _showSelectRoomBottomSheet(context, index,
                                          rooms[index].chambreId);
                                    }
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
                        onTap: () {
                          _toggleRoomSelection(index);
                          if (_selectedRoomIndices.contains(index)) {
                            _showSelectRoomBottomSheet(
                                context, index, rooms[index].chambreId);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: _selectedRoomIndices.isNotEmpty
            ? BottomAppBar(
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: FutureBuilder<double>(
                          future: calculateTotalPrice(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Erreur: ${snapshot.error}');
                            } else {
                              total = snapshot.data!;
                              return Row(children: [
                                Icon(FontAwesomeIcons.moneyBill,
                                    color: Colors.green),
                                SizedBox(width: 10),
                                Text(
                                    '${snapshot.data}  ${getCurrencySymbol(widget.hebergement.currency)}',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                              ]);
                            }
                          },
                        )),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          if (user == null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReservationSecondStep(
                                  hebergement: widget.hebergement,
                                  checkIn: widget.checkIn,
                                  checkOut: widget.checkOut,
                                  prix: total!,
                                  currency: widget.hebergement.currency,
                                  user: user!,
                                  nbRooms: totalRoomCount,
                                  roomIds: selectedRoomIds,
                                ),
                              ),
                            );
                          }
                          ;
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          'Book Now',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }

  void _toggleRoomSelection(int index) {
    setState(() {
      if (_selectedRoomIndices.contains(index)) {
        _selectedRoomIndices.remove(index);
      } else {
        _selectedRoomIndices.add(index);
      }
    });
  }

  Future<void> _showSelectRoomBottomSheet(
      BuildContext context, int index, int chambreId) async {
    int availableRooms = await HebergementService()
        .getAvailableRooms(chambreId, widget.checkIn, widget.checkOut);

    int roomCount = _selectedRoomCounts[rooms[index].type] ?? 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Align(
              alignment: Alignment.topCenter,
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  padding: EdgeInsets.all(16),
                  margin:
                      EdgeInsets.only(top: 50), // Adjust the margin as needed
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
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
                                            roomCount--;
                                          });
                                          _handleRoomSelection(
                                              index, roomCount);
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
                                            roomCount++;
                                          });
                                          _handleRoomSelection(
                                              index, roomCount);
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
                          Navigator.pop(context, roomCount);
                        },
                        child: Text('Confirm'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedRoomCounts[rooms[index].type] = value;
        });
      }
    });
  }

  void _handleRoomSelection(int roomIndex, int count) {
    setState(() {
      _selectedRoomCounts[rooms[roomIndex].type] = count;
      print("Selected $count ${rooms[roomIndex].type}(s)");
    });
  }

  Future<double> calculateTotalPrice() async {
    selectedRoomIds = [];
    totalRoomCount = 0;
    double totalPrice = 0.0;
    for (var entry in _selectedRoomCounts.entries) {
      String type = entry.key;
      int count = entry.value;
      totalRoomCount += count;
      print(count);
      var chambre = rooms.firstWhere((room) => room.type == type);
      for (int i = 0; i < count; i++) {
        selectedRoomIds.add(chambre.chambreId);
      }

      final applicableOffer = getApplicableOffer(chambre.chambreId);
      final discountPercentage = applicableOffer != null
          ? int.tryParse(applicableOffer.discount) ?? 0
          : 0;

      final discountedPrice = applicableOffer != null
          ? calculateDiscountedPrice(chambre.prix, discountPercentage)
          : chambre.prix;

      double priceForRoom = await calculatePrice(
        widget.checkIn,
        widget.checkOut,
        discountedPrice,
      );

      totalPrice += priceForRoom * count;
    }
    return totalPrice;
  }

  void performBooking() {
    print("Booking rooms at a total of /{calculateTotalPrice()}");
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
