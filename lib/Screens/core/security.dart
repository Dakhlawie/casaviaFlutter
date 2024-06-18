import 'package:casavia/Screens/core/accountSettings.dart';
import 'package:casavia/Screens/core/changePassword.dart';
import 'package:casavia/Screens/core/deleteAccount.dart';
import 'package:casavia/Screens/core/updateEmail.dart';
import 'package:casavia/theme/color.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  TextEditingController PhoneController = TextEditingController();

  bool isPhoneNumberFilled = false;
  String? selectedCountryCode = '216';
  String _phoneerror = "";
  void _showAuthenticationCodeBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Authentication Code',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int i = 0; i < 6; i++)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue[900]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Enter the 6-digit code sent to your phone number:',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                child: Text(
                  'Submit ',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.blue[900],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPhoneEditBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Phone number',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("+$selectedCountryCode" ?? 'Select Country'),
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
                        bool isNumeric = RegExp(r'^[0-9]+$').hasMatch(value);
                        setState(() {
                          isPhoneNumberFilled = value.isNotEmpty && isNumeric;
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
                        errorText: _phoneerror.isEmpty ? null : _phoneerror,
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
              SizedBox(height: 16),
              Text(
                  "To set up two-factor authentication we'll send a 6-digit code to this number. You'll be asked to enter it at the next step.",
                  style: TextStyle(color: Colors.grey)),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showAuthenticationCodeBottomSheet();
                },
                child: Text(
                  'Send code',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.blue[900],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Security'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Change your security settings, or delete your account',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
            SizedBox(height: 20),
            Container(
              height: 80,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
                color: AppColor.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: AppColor.shadowColor.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Reset your password ',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChangePassword()),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 80,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
                color: AppColor.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: AppColor.shadowColor.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Change your Email',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UpdateMailPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
            // SizedBox(height: 20),
            // Container(
            //   height: 80,
            //   width: double.infinity,
            //   padding: const EdgeInsets.symmetric(horizontal: 15),
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.only(
            //       topRight: Radius.circular(15),
            //       bottomRight: Radius.circular(15),
            //       topLeft: Radius.circular(15),
            //       bottomLeft: Radius.circular(15),
            //     ),
            //     color: AppColor.cardColor,
            //     boxShadow: [
            //       BoxShadow(
            //         color: AppColor.shadowColor.withOpacity(0.1),
            //         spreadRadius: 1,
            //         blurRadius: 1,
            //         offset: Offset(0, 1),
            //       ),
            //     ],
            //   ),
            //   child: Row(
            //     children: [
            //       Expanded(
            //         child: Padding(
            //           padding: EdgeInsets.only(top: 20),
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               Text(
            //                 'Two-factor authentifcation',
            //                 style: TextStyle(
            //                   fontWeight: FontWeight.bold,
            //                 ),
            //               ),
            //               Text(
            //                 'Add a phone number',
            //                 style: TextStyle(fontSize: 14),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            //       IconButton(
            //         icon: Icon(Icons.arrow_forward_ios),
            //         onPressed: () {
            //           _showPhoneEditBottomSheet();
            //         },
            //       ),
            //     ],
            //   ),
            // ),
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
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DeleteAccountPage()),
                        );
                      },
                      child: Text(
                        'Delete account',
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
    ));
  }
}
