import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'package:casavia/Screens/core/List_acommodation.dart';
import 'package:casavia/Screens/core/acommodation.dart';
import 'package:casavia/Screens/core/explore.dart';
import 'package:casavia/model/historique.dart';
import 'package:casavia/model/userModel.dart';
import 'package:casavia/model/ville.dart';
import 'package:casavia/services/AuthService.dart';
import 'package:casavia/services/historiqueService.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class FindPage extends StatefulWidget {
  const FindPage({super.key});

  @override
  State<FindPage> createState() => _FindPageState();
}

class _FindPageState extends State<FindPage> {
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

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String apiKey = 'aKM_bdLW8-VU6B_gDNupLNNNkq3Wvsg-YhyaeIORXH4';
  List<Map<String, String>> lastSearches = [];

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _showCalendarDialog(
      BuildContext context, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Check In',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'AbrilFatface',
                  ),
                ),
              ),
              TableCalendar(
                firstDay: DateTime(2000),
                lastDay: DateTime(2100),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    controller.text =
                        DateFormat('dd/MM/yyyy').format(selectedDay);
                  });
                  Navigator.pop(context);
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blue[900],
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue[900],
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    foregroundColor: Colors.white,
                  ),
                  child: Center(
                    child: Text('Apply'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserModel>(context).userId;

    late Future<List<Historique>> historiques =
        Hservice.getHistoriqueByUser(userId);

    final double containerHeight = MediaQuery.of(context).size.height * 0.4;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: containerHeight,
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/search.jpg'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(72, 255, 255, 255),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Destination...',
                            hintStyle: TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: const Color.fromARGB(72, 255, 255, 255),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () =>
                            _showCalendarDialog(context, _startDateController),
                        child: AbsorbPointer(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 16.0),
                            child: TextField(
                              readOnly: true,
                              controller: _startDateController,
                              decoration: InputDecoration(
                                hintText: 'Check In...',
                                hintStyle: TextStyle(color: Colors.white),
                                filled: true,
                                fillColor:
                                    const Color.fromARGB(72, 255, 255, 255),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20.0),
                              ),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () =>
                            _showCalendarDialog(context, _endDateController),
                        child: AbsorbPointer(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 16.0),
                            child: TextField(
                              readOnly: true,
                              controller: _endDateController,
                              decoration: InputDecoration(
                                hintText: 'Check Out...',
                                hintStyle: TextStyle(color: Colors.white),
                                filled: true,
                                fillColor:
                                    const Color.fromARGB(72, 255, 255, 255),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20.0),
                              ),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          validateAndNavigate(context);
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 16.0),
                          padding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          decoration: BoxDecoration(
                            color: Colors.blue[900]!,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Search',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (userId != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
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
                                  fontFamily: 'AbrilFatface',
                                  fontSize: 20,
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
                                    fontFamily: 'AbrilFatface',
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
              SizedBox(height: 2),
              FutureBuilder<List<Historique>>(
                future: historiques,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center();
                  } else {
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final historique = snapshot.data![index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ListAcommodation(
                                            ville: historique.lieu,
                                            checkIn: historique.checkIn,
                                            checkOut: historique.checkOut,
                                          )));
                            },
                            child: Container(
                              height: 70,
                              margin: EdgeInsets.all(10),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.location_on,
                                          size: 16, color: Colors.blue[900]),
                                      SizedBox(width: 7),
                                      Text(
                                        historique.lieu,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 2),
                                  Row(
                                    children: [
                                      SizedBox(width: 23),
                                      Text('From : ${historique.checkIn}'),
                                      SizedBox(width: 7),
                                      Text('To : ${historique.checkOut}'),
                                    ],
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
    );
  }

  void validateAndNavigate(BuildContext context) async {
    String city = _searchController.text.trim();
    String checkIn = _startDateController.text.trim();
    String checkOut = _endDateController.text.trim();
    final userId = Provider.of<UserModel>(context, listen: false).userId;

    Historique h =
        new Historique(checkIn: checkIn, checkOut: checkOut, lieu: city);

    if (city.isEmpty || checkIn.isEmpty || checkOut.isEmpty) {
      Flushbar(
        message: "All fields must be filled.",
        backgroundColor: Colors.blue[900]!,
        duration: Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      return;
    }

    DateTime? startDate;
    DateTime? endDate;
    try {
      startDate = DateFormat('dd/MM/yyyy').parse(checkIn);
      endDate = DateFormat('dd/MM/yyyy').parse(checkOut);
    } catch (e) {
      Flushbar(
        message: "Invalid Dates",
        backgroundColor: Colors.blue[900]!,
        duration: Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      return;
    }
    if (startDate.isBefore(DateTime.now()) ||
        endDate.isBefore(DateTime.now())) {
      Flushbar(
        message: "Dates cannot be in the past.",
        backgroundColor: Colors.blue[900]!,
        duration: Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      return;
    }

    if (endDate.isBefore(startDate)) {
      Flushbar(
        message: "Check-out date must be after the check-in date.",
        backgroundColor: Colors.blue[900]!,
        duration: Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      return;
    }

    if (userId != 0) {
      await Hservice.ajouterHistorique(userId, h);
      setState(() {});
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ListAcommodation(
                    ville: city,
                    checkIn: checkIn,
                    checkOut: checkOut,
                  )));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ListAcommodation(
                    ville: city,
                    checkIn: checkIn,
                    checkOut: checkOut,
                  )));
    }
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImagePage({Key? key, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}
