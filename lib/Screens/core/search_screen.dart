import 'dart:typed_data';

import 'package:casavia/Screens/core/explore.dart';
import 'package:casavia/widgets/custom_button.dart';
import 'package:casavia/widgets/custom_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:intl/intl.dart';

class SearchScreenPage extends StatefulWidget {
  const SearchScreenPage({super.key, required});

  @override
  State<SearchScreenPage> createState() => _SearchScreenPageState();
}

class _SearchScreenPageState extends State<SearchScreenPage> {
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
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Container(
              height: double.infinity,
              margin: EdgeInsets.only(top: size.height * 0.25),
              color: Colors.white,
            ),
            Column(
              children: [
                SizedBox(height: 30),
                _HeaderSection(),
                SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey.withAlpha(50),
                      ),
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
                            Expanded(
                              child: CustomTextField(
                                  readOnly: false,
                                  controller: locationTextController,
                                  label: 'Localisation'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.calendar_month, color: Colors.blue[900]),
                            SizedBox(width: 20),
                            Expanded(
                              child: CustomTextField(
                                readOnly: true,
                                label: 'Check In',
                                controller: checkInTextController,
                                onTap: () {
                                  _selectDate(context, true);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.calendar_month, color: Colors.blue[900]),
                            SizedBox(width: 20),
                            Expanded(
                              child: CustomTextField(
                                readOnly: true,
                                label: 'Check Out',
                                controller: checkOutTextController,
                                onTap: () {
                                  _selectDate(context, false);
                                },
                              ),
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void validateAndNavigate(BuildContext context) {
    String city = locationTextController.text.trim();
    String checkIn = checkInTextController.text.trim();
    String checkOut = checkOutTextController.text.trim();

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

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            'Welcome back 👋',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }
}
