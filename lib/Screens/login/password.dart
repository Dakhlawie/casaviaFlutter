import 'package:casavia/Screens/login/success_Registration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PasswordPage extends StatefulWidget {
  final String firstname;
  final String lastname;
  final String email;
  const PasswordPage(
      {super.key,
      required this.firstname,
      required this.lastname,
      required this.email});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController =
      TextEditingController();
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool isPasswordValid(String password) {
    RegExp regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    return regex.hasMatch(password);
  }

  Future<bool> createUser() async {
    var url = Uri.parse('http://192.168.1.17:3000/user/saveUser');
    Map<String, dynamic> userData = {
      'nom': widget.lastname,
      'prenom': widget.firstname,
      'email': widget.email,
      'mot_de_passe': passwordController.text,
    };
    String jsonBody = jsonEncode(userData);

    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonBody,
    );

    if (response.statusCode == 200) {
      print('User created successfully');
      return true;
    } else {
      print(response.statusCode);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 30),
                    child: SvgPicture.asset(
                      'assets/password.svg',
                      height: MediaQuery.of(context).size.height * 0.25,
                    ),
                  ),
                  SizedBox(height: 40),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          keyboardType: TextInputType.visiblePassword,
                          controller: passwordController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.blue[900]!,
                              ),
                            ),
                            labelText: "Enter your password",
                            labelStyle: TextStyle(
                                fontFamily: 'AbrilFatface', fontSize: 14),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordObscured
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordObscured = !_isPasswordObscured;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          keyboardType: TextInputType.visiblePassword,
                          controller: confirmpasswordController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.blue[900]!,
                              ),
                            ),
                            labelText: "Enter your confirm password",
                            labelStyle: TextStyle(
                                fontFamily: 'AbrilFatface', fontSize: 14),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordObscured
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordObscured =
                                      !_isConfirmPasswordObscured;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.all(12),
                                  backgroundColor: Colors.blue[900],
                                ),
                                onPressed: () async {
                                  if (passwordController.text.isEmpty ||
                                      confirmpasswordController.text.isEmpty) {
                                    showSnackBar(
                                        context, 'Please fill in all fields.');
                                    return;
                                  }

                                  if (!isPasswordValid(
                                      passwordController.text)) {
                                    showSnackBar(context,
                                        'Password must contain at least one letter, one number, and have a minimum length of 8 characters.');
                                    return;
                                  }

                                  if (passwordController.text !=
                                      confirmpasswordController.text) {
                                    showSnackBar(
                                        context, 'Passwords do not match.');
                                    return;
                                  }

                                  await createUser().then((success) {
                                    if (success) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SuccessPage()),
                                      );
                                    } else {
                                      showSnackBar(context,
                                          'Failed to create user. Please try again.');
                                    }
                                  });
                                },
                                child: Text(
                                  'FINNISH',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'AbrilFatface'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
