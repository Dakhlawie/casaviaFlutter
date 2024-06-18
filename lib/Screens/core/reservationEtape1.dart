import 'package:another_flushbar/flushbar.dart';
import 'package:casavia/Screens/core/ReservationEtape2.dart';
import 'package:casavia/model/hebergement.dart';
import 'package:casavia/model/user.dart';
import 'package:casavia/model/userModel.dart';
import 'package:casavia/services/AuthService.dart';
import 'package:casavia/services/UserService.dart';
import 'package:country_flags/country_flags.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class FirstEtapeReservation extends StatefulWidget {
  final Hebergement hebergement;
  final String checkIn;
  final String checkOut;
  final double prix;
  final String currency;

  const FirstEtapeReservation(
      {super.key,
      required this.hebergement,
      required this.checkIn,
      required this.checkOut,
      required this.prix,
      required this.currency});

  @override
  State<FirstEtapeReservation> createState() => _FirstEtapeReservationState();
}

class _FirstEtapeReservationState extends State<FirstEtapeReservation> {
  UserService userServ = new UserService();
  User? user;
  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  Future<void> _fetchUserId() async {
    AuthService authService = AuthService();
    int? userId = await authService.getUserIdFromToken();
    if (userId != null) {
      Provider.of<UserModel>(context, listen: false).setUserId(userId);
      user = await userServ.getUserById(userId);
      setState(() {
        _firstNameController.text = user!.prenom ?? '';
        _lastNameController.text = user!.nom ?? '';
        final phoneInfo = _extractPhoneInfo(user!.tlf ?? '');
        selectedCountryCode = phoneInfo['countryCode'];
        _phoneController.text = phoneInfo['phoneNumber']!;
        _emailController.text = user!.email ?? '';
        _countryController.text = user!.pays ?? '';
        selectedCountry = user!.pays ?? '';
      });
    }
    print('USERID');
    print(userId);
  }

  int currentStep = 0;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? selectedCountryName = "tn";
  String selectedCountry = "Tunisia";

  String? selectedCountryCode;

  String _emailerror = "";
  String _nameerror = "";
  String _phoneerror = "";

  Widget countryIcon(String countryCode) {
    return CountryFlag.fromCountryCode(
      countryCode.toUpperCase(),
      height: 20,
      width: 20,
    );
  }

  Map<String, String> _extractPhoneInfo(String phone) {
    RegExp regex = RegExp(r'\(\+(\d+)\)(\d+)');
    Match? match = regex.firstMatch(phone);
    if (match != null) {
      return {
        'countryCode': match.group(1)!,
        'phoneNumber': match.group(2)!,
      };
    } else {
      return {
        'countryCode': '',
        'phoneNumber': '',
      };
    }
  }

  bool _validateFields() {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        selectedCountryCode == null) {
      Flushbar(
        message: "All fields must be filled.",
        backgroundColor: Colors.blue[900]!,
        duration: Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      return false;
    }

    if (!_validateEmail(_emailController.text)) {
      Flushbar(
        message: "Invalid email address.",
        backgroundColor: Colors.blue[900]!,
        duration: Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      return false;
    }

    if (!_isNumeric(_phoneController.text)) {
      Flushbar(
        message: "Phone number must be numeric.",
        backgroundColor: Colors.blue[900]!,
        duration: Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      return false;
    }

    return true;
  }

  bool _validateEmail(String email) {
    final emailRegex = RegExp(
        r'^[a-zA-Z0-9]+([._%+-]?[a-zA-Z0-9]+)*@[a-zA-Z0-9]+([.-]?[a-zA-Z0-9]+)*(\.[a-zA-Z]{2,})$');
    return emailRegex.hasMatch(email);
  }

  bool _isNumeric(String value) {
    return double.tryParse(value) != null;
  }

  bool isPhoneNumberFilled = false;
  String extractCountryCode(String countryName) {
    RegExp regex = RegExp(r'\(([^\)]+)\)');
    Match? match = regex.firstMatch(countryName);
    if (match != null) {
      return match.group(1)!;
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserModel>(context).userId;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_outlined),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepIndicator(),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Your personal information",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'AbrilFatface',
                          fontSize: 20,
                        )),
                    SizedBox(height: 30),
                    Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Row(
                        children: [
                          Text(
                            "First Name",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            " * ",
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        hintText: 'First name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue[900]!, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Row(
                        children: [
                          Text(
                            "Last Name",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            " * ",
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        hintText: 'Last name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue[900]!, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Row(
                        children: [
                          Text(
                            "Email",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            " * ",
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue[900]!, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          "Phone Number",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          " * ",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () {
                              showCountryPicker(
                                context: context,
                                exclude: <String>['KN', 'MF'],
                                favorite: <String>['SE'],
                                showPhoneCode: true,
                                onSelect: (Country country) {
                                  setState(() {
                                    this.selectedCountryCode =
                                        country.phoneCode;
                                    this.selectedCountryName =
                                        extractCountryCode(country.displayName);
                                  });
                                  print(selectedCountryName);
                                },
                                countryListTheme: CountryListThemeData(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(40.0),
                                    topRight: Radius.circular(40.0),
                                  ),
                                  inputDecoration: InputDecoration(
                                    hintText: 'search',
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      color: Color.fromARGB(255, 6, 67, 127),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  searchTextStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                  ),
                                ),
                              );
                            },
                            decoration: InputDecoration(
                              hintText:
                                  "\+$selectedCountryCode" ?? 'Select Country',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.blue[900]!, width: 1.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                              ),
                              prefixIcon: Padding(
                                padding: EdgeInsets.all(5.0),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.transparent,
                                  child: countryIcon(selectedCountryName!),
                                ),
                              ),
                              suffixIcon: Icon(Icons.arrow_drop_down),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              hintText: "Phone ",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.blue[900]!, width: 1.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          "Country",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          " * ",
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          exclude: <String>['KN', 'MF'],
                          favorite: <String>['SE'],
                          showPhoneCode: false,
                          onSelect: (Country country) {
                            setState(() {
                              this.selectedCountry = country.name;
                            });
                          },
                          countryListTheme: CountryListThemeData(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40.0),
                              topRight: Radius.circular(40.0),
                            ),
                            inputDecoration: InputDecoration(
                              hintText: 'search',
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Color.fromARGB(255, 6, 67, 127),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            searchTextStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("$selectedCountry" ?? 'Select Country'),
                            Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    // SizedBox(
                    //   width: double.infinity,
                    //   child: ElevatedButton(
                    //     onPressed: () {},
                    //     style: ElevatedButton.styleFrom(
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(10),
                    //       ),
                    //       padding: EdgeInsets.all(12),
                    //       backgroundColor: Colors.blue[900],
                    //     ),
                    //     child: Text('Next',
                    //         style: TextStyle(
                    //           color: Colors.white,
                    //           fontFamily: 'AbrilFatface',
                    //         )),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_validateFields()) {
       
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(12),
                backgroundColor: Colors.blue[900],
              ),
              child: Text('NEXT',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'AbrilFatface',
                  )),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStep(currentStep >= 0, '1'),
          _buildLine(currentStep > 0),
          _buildStep(currentStep > 0, '2'),
          _buildLine(currentStep > 1),
          _buildStep(currentStep > 1, '✔'),
        ],
      ),
    );
  }

  Widget _buildStep(bool isActive, String text) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: isActive ? Colors.blue[900] : Colors.grey[300],
      child: Text(
        text,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? Colors.blue[900] : Colors.grey[300],
      ),
    );
  }
}
