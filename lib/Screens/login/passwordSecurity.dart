import 'package:another_flushbar/flushbar.dart';
import 'package:casavia/Screens/login/success_Registration.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PasswordSecurity extends StatefulWidget {
  final String firstname;
  final String lastname;
  final String email;
  final String country;
  final String tlf;
  final String codePays;
  const PasswordSecurity(
      {super.key,
      required this.firstname,
      required this.lastname,
      required this.email,
      required this.country,
      required this.tlf,
      required this.codePays});

  @override
  State<PasswordSecurity> createState() => _PasswordSecurityState();
}

class _PasswordSecurityState extends State<PasswordSecurity> {
  Future<bool> createUser() async {
    var url = Uri.parse('http://192.168.1.17:3000/user/saveUser');
    Map<String, dynamic> userData = {
      'nom': widget.lastname,
      'prenom': widget.firstname,
      'email': widget.email,
      'mot_de_passe': passwordController.text,
      'pays': widget.country,
      'tlf': widget.tlf,
      'flag': widget.codePays
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

  bool isPasswordValid(String password) {
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  void validateAndSave() async {
    final password = passwordController.text;
    final confirmPassword = confirmpasswordController.text;

    if (password.isEmpty || confirmPassword.isEmpty) {
      showFlushbar(context, "Please fill all fields.", Colors.red);
    } else if (password != confirmPassword) {
      showFlushbar(context, "Passwords do not match.", Colors.red);
    } else if (!isPasswordValid(password)) {
      showFlushbar(
          context,
          "Password must be at least 8 characters long and contain both numbers and letters.",
          Colors.red);
    } else {
      await createUser().then(
        (success) {
          if (success) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SuccessPage()),
            );
          } else {
            showFlushbar(context, "Failed to create your account", Colors.red);
          }
        },
      );
    }
  }

  void showFlushbar(BuildContext context, String message, Color color) {
    Flushbar(
      message: message,
      backgroundColor: color,
      duration: Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please enter your password',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'AbrilFatface',
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Password must be at least 8 characters long and contain both numbers and letters.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 40),
            Padding(
              padding: EdgeInsets.only(left: 5),
              child: Row(
                children: [
                  Text(
                    "Password",
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
              controller: passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: 'password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[900]!, width: 1.0),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(left: 5),
              child: Row(
                children: [
                  Text(
                    "Confirm password",
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
              controller: confirmpasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                hintText: 'confirm password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[900]!, width: 1.0),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
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
    );
  }
}
