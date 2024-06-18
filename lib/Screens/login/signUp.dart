import 'package:another_flushbar/flushbar.dart';
import 'package:casavia/Screens/login/code.dart';
import 'package:casavia/services/UserService.dart';
import 'package:country_flags/country_flags.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
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
  final TextEditingController _emailController = TextEditingController();
  String? selectedCountryName = "tn";
  String selectedCountry = "Tunisia";
  String? codePays;
  String? selectedCountryCode = "216";
  Widget countryIcon(String countryCode) {
    return CountryFlag.fromCountryCode(
      countryCode.toUpperCase(),
      height: 20,
      width: 20,
    );
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

  bool isEmailValid(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool isPhoneValid(String phone) {
    final phoneRegex = RegExp(r'^\d+$');
    return phoneRegex.hasMatch(phone);
  }

  Future<void> validateAndSave() async {
    final firstName = _firstNameController.text;
    final lastName = _lastNameController.text;
    final email = _emailController.text;
    final phone = _phoneController.text;
    final formattedPhone = '(+$selectedCountryCode)$phone';

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        selectedCountry.isEmpty) {
      showFlushbar(context, "Please fill all fields.", Colors.red);
    } else if (!isEmailValid(email)) {
      showFlushbar(context, "Please enter a valid email address.", Colors.red);
    } else if (!isPhoneValid(phone)) {
      showFlushbar(context, "Please enter a valid phone number.", Colors.red);
    } else {
      UserService userService = UserService();
      bool userExists =
          await userService.checkIfUserExists(_emailController.text);
      if (userExists) {
        showFlushbar(
            context,
            'This email is already in use. Please try another one.',
            Colors.red);
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CodePage(
                    firstname: firstName,
                    lastname: lastName,
                    email: email,
                    country: selectedCountry,
                    tlf: formattedPhone,
                    codePays: flagEmoji!,
                  )),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'AbrilFatface',
                ),
              ),
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
                        hintText: "\+$selectedCountryCode" ?? 'Select Country',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue[900]!, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
                          borderSide:
                              BorderSide(color: Colors.blue[900]!, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue[900],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextButton(
                        onPressed: () {
                          validateAndSave();
                        },
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
