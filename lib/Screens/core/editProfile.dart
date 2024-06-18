import 'package:another_flushbar/flushbar.dart';
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
  final String emoji;
  const EditProfilePage(
      {super.key,
      required this.id,
      required this.firstname,
      required this.lastname,
      required this.phone,
      required this.country,
      required this.emoji});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String? flagEmoji = "🇹🇳";
  void showFlushbar(BuildContext context, String message, Color color) {
    Flushbar(
      message: message,
      backgroundColor: color,
      duration: Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

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
    setState(() {});
    _firstNameController.text = widget.firstname ?? '';
    _lastNameController.text = widget.lastname ?? '';
    _phoneController.text = widget.phone ?? '';
    final phoneInfo = _extractPhoneInfo(widget.phone);
    selectedCountryCode = phoneInfo['countryCode'];
    _phoneController.text = phoneInfo['phoneNumber']!;
    this.flagEmoji = widget.emoji!;
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
                  'Update Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'AbrilFatface',
                  ),
                ),
                SizedBox(height: 30),
                TextField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    hintText: 'first name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.blue[900]!),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    hintText: 'last name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.blue[900]!),
                    ),
                  ),
                ),
                SizedBox(height: 20),
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
                                this.selectedCountryCode = country.phoneCode;
                                this.selectedCountryName =
                                    extractCountryCode(country.displayName);
                                this.flagEmoji = country.flagEmoji;
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
                              child: Text(flagEmoji!),
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
                SizedBox(height: 20),
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
            if (_firstNameController.text.isEmpty ||
                _lastNameController.text.isEmpty ||
                _phoneController.text.isEmpty ||
                selectedCountry.isEmpty) {
              showFlushbar(context, 'Please fill in all fields', Colors.red);
              return;
            }

            if (!RegExp(r'^\d+$').hasMatch(_phoneController.text)) {
              showFlushbar(
                  context, 'Phone number must contain only digits', Colors.red);
              return;
            }

            try {
              final fullPhoneNumber =
                  '(+${selectedCountryCode!})${_phoneController.text}';

              await _userService.modifierUserPrenom(
                  widget.id, _firstNameController.text);
              await _userService.modifierUserNom(
                  widget.id, _lastNameController.text);
              await _userService.modifierUserPhone(widget.id, fullPhoneNumber);
              await _userService.modifierUserPays(widget.id, selectedCountry);
              await _userService.modifierUserFlag(widget.id, flagEmoji!);
              UserData user = UserData(
                firstName: _firstNameController.text,
                lastName: _lastNameController.text,
                phone: _phoneController.text,
                country: selectedCountry,
              );
              Navigator.pop(context, user);
            } catch (e) {
              showFlushbar(context,
                  'Error occurred while updating information: $e', Colors.red);
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
