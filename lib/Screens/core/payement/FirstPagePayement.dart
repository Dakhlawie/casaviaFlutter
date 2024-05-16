import 'package:casavia/Screens/core/payement/procedToPayementPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';


class FirstPagePayement extends StatefulWidget {
  const FirstPagePayement({Key? key}) : super(key: key);

  @override
  State<FirstPagePayement> createState() => _FirstPagePayementState();
}

class _FirstPagePayementState extends State<FirstPagePayement> {
  bool isNameFilled = false;
  bool isEmailFilled = false;
  String? selectedCountryCode = '216';
  bool isPhoneNumberFilled = false;
  String? selectedCountryName = 'Tunisia';
  bool isLeisureSelected = true;
  TextEditingController NameController = TextEditingController();
  TextEditingController MailController = TextEditingController();
  TextEditingController PhoneController = TextEditingController();
  String _emailerror = "";
  String _nameerror = "";
  String _phoneerror = "";
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.grey[100],
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: () {},
          ),
          title: Text("Your personal information"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      "Name",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      " * ",
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                TextField(
                  onTap: () {
                    setState(() {
                      if (NameController.text.isEmpty) {
                        _nameerror = "This field cannot be empty";
                      } else {
                        _nameerror = "";
                      }
                    });
                  },
                  onChanged: (value) {
                    setState(() {
                      isNameFilled = value.isNotEmpty;
                    });
                    setState(() {
                      if (NameController.text.isEmpty) {
                        _nameerror = "This field cannot be empty";
                      } else {
                        _nameerror = "";
                      }
                    });
                  },
                  controller: NameController,
                  decoration: InputDecoration(
                    errorText: _nameerror.isEmpty ? null : _nameerror,
                    hintText: "Enter your name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.blue[900]!,
                      ),
                    ),
                    suffixIcon: isNameFilled
                        ? Icon(Icons.check, color: Colors.green)
                        : null,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      "Mail",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      " * ",
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      isEmailFilled = value.isNotEmpty;
                    });
                    setState(() {
                      if (MailController.text.isEmpty) {
                        _emailerror = "This field cannot be empty";
                      } else {
                        _emailerror = "";
                      }
                    });
                  },
                  onTap: () {
                    setState(() {
                      if (MailController.text.isEmpty) {
                        _emailerror = "This field cannot be empty";
                      } else {
                        _emailerror = "";
                      }
                    });
                  },
                  controller: MailController,
                  decoration: InputDecoration(
                    errorText: _emailerror.isEmpty ? null : _emailerror,
                    hintText: "Enter your email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.blue[900]!,
                      ),
                    ),
                    suffixIcon: isEmailFilled
                        ? Icon(Icons.check, color: Colors.green)
                        : null,
                  ),
                ),
                SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              showCountryPicker(
                                context: context,
                                exclude: <String>['KN', 'MF'],
                                favorite: <String>['SE'],
                                showPhoneCode: true,
                                onSelect: (Country country) {
                                  setState(() {
                                    selectedCountryCode = country.phoneCode;
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("+$selectedCountryCode" ??
                                      'Select Country'),
                                  Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            onChanged: (value) {
                              bool isNumeric =
                                  RegExp(r'^[0-9]+$').hasMatch(value);
                              setState(() {
                                isPhoneNumberFilled =
                                    value.isNotEmpty && isNumeric;
                              });
                              setState(() {
                                if (PhoneController.text.isEmpty) {
                                  _phoneerror = "This field cannot be empty";
                                } else {
                                  _phoneerror = "";
                                }
                              });
                            },
                            onTap: () {
                              setState(() {
                                if (PhoneController.text.isEmpty) {
                                  _phoneerror = "This field cannot be empty";
                                } else {
                                  _phoneerror = "";
                                }
                              });
                            },
                            controller: PhoneController,
                            decoration: InputDecoration(
                              errorText:
                                  _phoneerror.isEmpty ? null : _phoneerror,
                              hintText: "Enter your phone number",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.blue[900]!,
                                ),
                              ),
                              suffixIcon: isPhoneNumberFilled
                                  ? Icon(Icons.check, color: Colors.green)
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      "Country/Region",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      " * ",
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
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
                          selectedCountryName = country.name;
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
                        Text("$selectedCountryName" ?? 'Select Country'),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "What is the main purpose of your trip?",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                    fontSize: 18,
                  ),
                ),
                CheckboxListTile(
                  activeColor: Colors.blue[900],
                  title: Text(
                    'Work',
                    style: TextStyle(),
                  ),
                  value: !isLeisureSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      isLeisureSelected = !value!;
                    });
                  },
                ),
                CheckboxListTile(
                  activeColor: Colors.blue[900],
                  checkColor: Colors.white,
                  selectedTileColor: Colors.blue[900],
                  title: Text(
                    'Leisure',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  value: isLeisureSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      isLeisureSelected = value!;
                    });
                  },
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (NameController.text.isEmpty) {
                              _nameerror = "This field cannot be empty";
                            } else {
                              _nameerror = "";
                            }

                            if (MailController.text.isEmpty) {
                              _emailerror = "This field cannot be empty";
                            } else {
                              _emailerror = "";
                            }

                            if (PhoneController.text.isEmpty) {
                              _phoneerror = "This field cannot be empty";
                            } else {
                              _phoneerror = "";
                            }
                          });

                          if (NameController.text.isNotEmpty &&
                              MailController.text.isNotEmpty &&
                              PhoneController.text.isNotEmpty) {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => ProceedToPayementPage(),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          textStyle: TextStyle(color: Colors.white),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Next Step",
                              style: TextStyle(color: Colors.white),
                            ),
                            SizedBox(width: 3),
                            Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
