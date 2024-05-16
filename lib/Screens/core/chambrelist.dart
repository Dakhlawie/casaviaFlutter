import 'dart:convert';
import 'dart:typed_data';
import 'package:casavia/model/categorieEquipement.dart';
import 'package:casavia/model/equipement.dart';
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
  EquipementService service = EquipementService();
  String? symbol;
  double? convertedPrice;
  Future<double> calculatePrice(
      String checkIn, String checkOut, double prixParNuit) async {
    DateTime startDate = DateFormat('dd/MM/yyyy').parse(checkIn);
    DateTime endDate = DateFormat('dd/MM/yyyy').parse(checkOut);
    int numberOfNights = endDate.difference(startDate).inDays;
    double totalPrice = numberOfNights * prixParNuit;

    final prefs = await SharedPreferences.getInstance();
    String? ToCurrency = prefs.getString('selectedCurrency');
    print(ToCurrency);
    if (ToCurrency != null) {
      symbol = getCurrencySymbol(ToCurrency);
    }
    if (ToCurrency != null && ToCurrency!.isNotEmpty) {
      double rate = await CurrencyService()
          .getConversionRate(widget.hebergement.currency, ToCurrency);
      totalPrice *= rate;
    }

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
    for (var chambre in widget.hebergement.chambres) {
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
  }

  Map<String, int> _selectedRoomCounts = {};
  bool isExpanded = false;
  int _selectedImageIndex = 0;
  Map<int, bool> _showDetailsMap = {};
  int _selectedRoomIndex = -1;

  double get _totalPrice => _selectedRoomIndices
      .map((index) => widget.hebergement.chambres[index].prix ?? 0)
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
        return 'DT';
      case 'AMD':
        return '֏';

      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    String currencySymbol =
        utf8.decode(widget.hebergement.currency.runes.toList());

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.grey[100],
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_outlined),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text('${widget.hebergement.nom}'),
          actions: [],
        ),
        body: ListView.builder(
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final chambre = rooms[index];
            _showDetailsMap.putIfAbsent(index, () => false);
            return Padding(
              padding: EdgeInsets.all(8),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: _selectedRoomIndices.contains(index)
                      ? Colors.blue[100]
                      : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                  border: _selectedRoomIndices.contains(index)
                      ? Border.all(color: Colors.blue, width: 2.0)
                      : null,
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.0),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<List<int>?>(
                        future: _hebergementService
                            .getImageBytesForChambre(rooms[index].chambreId),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<int>?> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.data == null) {
                            return Text('No image data available');
                          } else {
                            return Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: MemoryImage(
                                      Uint8List.fromList(snapshot.data!)),
                                  fit: BoxFit.cover,
                                ),
                              ),
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
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          FutureBuilder<double>(
                            future: calculatePrice(widget.checkIn,
                                widget.checkOut, rooms[index].prix),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text(
                                    "Error: ${snapshot.error.toString()}");
                              } else if (snapshot.hasData) {
                                return Text(
                                  "${snapshot.data!.toStringAsFixed(2)}  ${symbol ?? getCurrencySymbol(widget.hebergement.currency)}",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 20),
                                );
                              } else {
                                return Text("Price not available");
                              }
                            },
                          ),
                        ],
                      ),
                      ExpandableTextWidget(
                          text: rooms[index].description ?? ''),
                      SizedBox(height: 8),
                      if (_showDetailsMap[index] ?? false) ...[
                        FutureBuilder<List<Equipement>>(
                          future: futureEquipements,
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
                                              style:
                                                  TextStyle(color: Colors.grey),
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
                                _showSelectRoomBottomSheet(context, index);
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
                      _showSelectRoomBottomSheet(context, index);
                    }
                  },
                ),
              ),
            );
          },
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
                              return Text(
                                  '${snapshot.data}  ${symbol ?? getCurrencySymbol(widget.hebergement.currency)}',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red));
                            }
                          },
                        )),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          performBooking();
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

  void _showSelectRoomBottomSheet(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListView(
                shrinkWrap: true,
                children: List<Widget>.generate(3, (int idx) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      checkboxTheme: CheckboxThemeData(
                        fillColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            return Colors.blue[900]!;
                          }
                          return Colors.white;
                        }),
                        checkColor: MaterialStateProperty.all(Colors.white),
                      ),
                    ),
                    child: CheckboxListTile(
                      title: Text(
                          "${idx + 1} ${rooms[index].type}${idx > 0 ? 's' : ''}"),
                      value: _selectedRoomCounts[rooms[index].type] == idx + 1,
                      onChanged: (bool? value) {
                        if (value != null && value) {
                          _handleRoomSelection(index, idx + 1);
                        } else {
                          _handleRoomSelection(index, 0);
                        }
                        Navigator.pop(context);
                      },
                      secondary: Icon(Icons.bed, color: Colors.blue[900]),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleRoomSelection(int roomIndex, int count) {
    setState(() {
      _selectedRoomCounts[rooms[roomIndex].type] = count;
      print("Selected $count ${rooms[roomIndex].type}(s)");
    });
  }

  Future<double> calculateTotalPrice() async {
    double totalPrice = 0.0;
    for (var entry in _selectedRoomCounts.entries) {
      String type = entry.key;
      int count = entry.value;
      double priceForRoom = await calculatePrice(
        widget.checkIn,
        widget.checkOut,
        rooms.firstWhere((room) => room.type == type).prix,
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
