import 'dart:convert';

import 'package:casavia/Screens/core/explore.dart';
import 'package:casavia/Screens/core/hereplaces.dart';
import 'package:casavia/model/historique.dart';
import 'package:casavia/model/userModel.dart';
import 'package:casavia/model/ville.dart';
import 'package:casavia/services/AuthService.dart';
import 'package:casavia/services/historiqueService.dart';
import 'package:casavia/widgets/custom_button.dart';
import 'package:casavia/widgets/custom_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  HistoriqueService Hservice = HistoriqueService();
  Future<void> _fetchUserId() async {
    AuthService authService = AuthService();
    int? userId = await authService.getUserIdFromToken();
    if (userId != null) {
      Provider.of<UserModel>(context, listen: false).setUserId(userId);
    }
    print('USERID');
    print(userId);
  }

  TextEditingController locationTextController = TextEditingController();
  final TextEditingController checkInTextController = TextEditingController(
    text: DateFormat('dd/MM/yyyy').format(DateTime.now()),
  );

  final TextEditingController checkOutTextController = TextEditingController(
    text: DateFormat('dd/MM/yyyy').format(DateTime.now()),
  );
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  @override
  void initState() {
    super.initState();
    locationTextController.text = 'paris';
    _fetchUserId();
    final userId = Provider.of<UserModel>(context, listen: false).userId;
  }

  Future<String> fetchCountryImage(String countryName) async {
    final response = await http.get(Uri.parse(
        'https://api.unsplash.com/search/photos?query=$countryName landscape&client_id=KDANlN3q7dLNzIHvd8gP_2QeEemyeAs2J6L0xZzyHC8'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'][0]['urls']['small'];
    } else {
      throw Exception('Failed to load image');
    }
  }

  DateTime? _selectedDate;
  String _originalPriceText = "";
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
          final DateFormat formatter = DateFormat('dd/MM/yyyy');
          String formattedDate = formatter.format(picked);

          if (isCheckIn) {
            _checkInDate = picked;
            checkInTextController.text = formattedDate;
          } else {
            _checkOutDate = picked;
            checkOutTextController.text = formattedDate;
          }
        });
      }
    } catch (e, stackTrace) {
      print("An error occurred: $e");
      print("Error picking date: $e");
      print("StackTrace: $stackTrace");
    }
  }

  @override
  void dispose() {
    locationTextController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserModel>(context).userId;
    print("bilel:$userId");
    late Future<List<Historique>> historiques =
        Hservice.getHistoriqueByUser(userId);
    print("hhhhhh:$historiques");

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.grey.withAlpha(50),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.blue[900],
                        ),
                        SizedBox(width: 20),
                        CustomTextField(
                          readOnly: false,
                          controller: locationTextController,
                          label: 'Localisation',
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CountrySearchPage()),
                            );
                            if (result != null) {
                              locationTextController.text = result;
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.calendar_month, color: Colors.blue[900]),
                        SizedBox(width: 20),
                        CustomTextField(
                          readOnly: true,
                          label: 'Check In',
                          controller: checkInTextController,
                          onTap: () {
                            _selectDate(context, true);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.calendar_month, color: Colors.blue[900]),
                        SizedBox(width: 20),
                        CustomTextField(
                          readOnly: true,
                          label: 'Check Out',
                          controller: checkOutTextController,
                          onTap: () {
                            _selectDate(context, false);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      buttonText: 'Search',
                      onPressed: () {
                        validateAndNavigate(context);
                      },
                    )
                  ],
                ),
              ),
              SizedBox(height: 50),
              Visibility(
                visible: userId != 0,
                child: FutureBuilder<List<Historique>>(
                  future: historiques,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      List<Historique> historiques = snapshot.data ?? [];
                      return Visibility(
                        visible: historiques.isNotEmpty,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Last Searches',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                await Hservice.deleteAllHistoriquesByUser(
                                    userId);
                                setState(() {});
                              },
                              child: Text(
                                'Clear All',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: FutureBuilder<List<Historique>>(
                  future: historiques,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            Historique historique = snapshot.data![index];
                            return FutureBuilder<String>(
                              future: fetchCountryImage(historique.lieu),
                              builder: (context, imageSnapshot) {
                                if (imageSnapshot.connectionState ==
                                        ConnectionState.done &&
                                    imageSnapshot.hasData) {
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(imageSnapshot.data!),
                                      radius: 20,
                                    ),
                                    title: Text(historique.lieu),
                                    subtitle: Text(
                                        "${historique.checkIn} - ${historique.checkOut}"),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ExplorePage(
                                                    ville: historique.lieu,
                                                    checkIn: historique.checkIn,
                                                    checkOut:
                                                        historique.checkOut,
                                                  )));
                                    },
                                  );
                                } else {
                                  return CircularProgressIndicator();
                                }
                              },
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      } else {
                        Container();
                      }
                      ;
                    }
                    return CircularProgressIndicator();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void validateAndNavigate(BuildContext context) async {
    String city = locationTextController.text.trim();
    String checkIn = checkInTextController.text.trim();
    String checkOut = checkOutTextController.text.trim();
    final userId = Provider.of<UserModel>(context, listen: false).userId;
    print("USER Id");
    print(userId);
    Historique h =
        new Historique(checkIn: checkIn, checkOut: checkOut, lieu: city);

    if (city.isEmpty || checkIn.isEmpty || checkOut.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("All fields must be filled."),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    DateTime? startDate;
    DateTime? endDate;
    try {
      startDate = DateFormat('dd/MM/yyyy').parse(checkIn);
      endDate = DateFormat('dd/MM/yyyy').parse(checkOut);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Invalid date format."),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (endDate.isBefore(startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Check-out date must be after the check-in date."),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    if (userId != 0) {
      await Hservice.ajouterHistorique(userId, h);
      setState(() {});
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ExplorePage(
                    ville: city,
                    checkIn: checkIn,
                    checkOut: checkOut,
                  )));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ExplorePage(
                    ville: city,
                    checkIn: checkIn,
                    checkOut: checkOut,
                  )));
    }
  }
}
