import 'package:casavia/model/userData.dart';
import 'package:casavia/services/UserService.dart';
import 'package:country_flags/country_flags.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  final String firstname;
  final String lastname;
  final String country;
  final String phone;
  final int id;
  const EditProfilePage(
      {super.key,
      required this.id,
      required this.firstname,
      required this.lastname,
      required this.phone,
      required this.country});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final UserService _userService = UserService();
  String? selectedCountryName = "tn";
  String selectedCountry = "Tunisia";

  String? selectedCountryCode = '';

  String _emailerror = "";
  String _nameerror = "";
  String _phoneerror = "";

  bool isPhoneNumberFilled = false;

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.firstname ?? '';
    _lastNameController.text = widget.lastname ?? '';
    _phoneController.text = widget.phone ?? '';
    _countryController.text = widget.country ?? '';
    selectedCountryCode = '+216';
  }

  String extractCountryCode(String countryName) {
    RegExp regex = RegExp(r'\(([^\)]+)\)');
    Match? match = regex.firstMatch(countryName);
    if (match != null) {
      return match.group(1)!;
    } else {
      return '';
    }
  }

  Widget countryIcon(String countryCode) {
    return CountryFlag.fromCountryCode(
      countryCode.toUpperCase(),
      height: 20,
      width: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'First Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 16),
                Theme(
                  data: ThemeData(
                    textSelectionTheme: TextSelectionThemeData(
                      cursorColor: Colors.blue[900],
                      selectionColor: Colors.blue.withOpacity(0.5),
                      selectionHandleColor: Colors.blue[900],
                    ),
                  ),
                  child: TextField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue[900]!),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Last Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 16),
                Theme(
                  data: ThemeData(
                    textSelectionTheme: TextSelectionThemeData(
                      cursorColor: Colors.blue[900],
                      selectionColor: Colors.blue.withOpacity(0.5),
                      selectionHandleColor: Colors.blue[900],
                    ),
                  ),
                  child: TextField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue[900]!),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Phone',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        onTap: () {
                          showCountryPicker(
                            context: context,
                            exclude: <String>['KN', 'MF'],
                            favorite: <String>['SE'],
                            showPhoneCode: true,
                            onSelect: (Country country) {
                              setState(() {
                                this.selectedCountryCode = country.phoneCode;
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                              color: Colors.blue[900]!,
                            ),
                          ),
                          prefixIcon: Padding(
                              padding: EdgeInsets.only(right: 10.0),
                              child: countryIcon(selectedCountryName!)),
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        onChanged: (value) {
                          bool isNumeric = RegExp(r'^[0-9]+$').hasMatch(value);
                          setState(() {
                            isPhoneNumberFilled = value.isNotEmpty && isNumeric;
                          });
                          setState(() {
                            if (_phoneController.text.isEmpty) {
                              _phoneerror = "This field cannot be empty";
                            } else {
                              _phoneerror = "";
                            }
                          });
                        },
                        onTap: () {
                          setState(() {
                            if (_phoneController.text.isEmpty) {
                              _phoneerror = "This field cannot be empty";
                            } else {
                              _phoneerror = "";
                            }
                          });
                        },
                        controller: _phoneController,
                        decoration: InputDecoration(
                          hintText: "Enter your phone ",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                              color: Colors.blue[900]!,
                            ),
                          ),
                          prefix: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text("$selectedCountryCode" ?? 'Select Country'),
                              Container(
                                height: 20,
                                child: VerticalDivider(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Country',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 16),
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
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          onPressed: () async {
            try {
              await _userService.modifierUserPrenom(
                  widget.id, _firstNameController.text);
              await _userService.modifierUserNom(
                  widget.id, _lastNameController.text);
              await _userService.modifierUserPhone(
                  widget.id, _phoneController.text);
              await _userService.modifierUserPays(widget.id, selectedCountry);
              UserData user = new UserData(
                  firstName: _firstNameController.text,
                  lastName: _lastNameController.text,
                  phone: _phoneController.text,
                  country: selectedCountry);
              Navigator.pop(context, user);
            } catch (e) {
              print('Erreur lors de la modification du nom: $e');
            }
          },
          child: Text(
            'Save',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12),
            backgroundColor: Colors.blue[900],
          ),
        ),
      ),
    );
  }
}
