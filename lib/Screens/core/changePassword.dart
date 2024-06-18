import 'package:another_flushbar/flushbar.dart';
import 'package:casavia/Screens/core/security.dart';
import 'package:casavia/Screens/login/forget_password.dart';
import 'package:casavia/services/AuthService.dart';
import 'package:casavia/services/UserService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _retypeNewPasswordController =
      TextEditingController();
  late final UserService _userService;
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _userService = UserService();
  }

  bool _containsLetterAndNumber(String text) {
    return RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(text);
  }

  void showFlushbar(BuildContext context, String message, Color color) {
    Flushbar(
      message: message,
      backgroundColor: color,
      duration: Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureRetypeNewPassword = true;
  int userId = 0;
  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _retypeNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.grey[50],
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_outlined),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: FutureBuilder<Map<String, dynamic>?>(
          future: _authService.getUserDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text("Erreur lors du chargement des données."));
            } else if (snapshot.hasData) {
              Map<String, dynamic>? userData = snapshot.data?['data'];

              userId = userData?['user_id'] ?? 0;
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Change password',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'AbrilFatface',
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Your password must be at least 8 characters and should include a combination of numbers, letters.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrentPassword,
                        decoration: InputDecoration(
                          hintText: "Current password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.blue[900]!,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureCurrentPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureCurrentPassword =
                                    !_obscureCurrentPassword;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        decoration: InputDecoration(
                          hintText: "New password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.blue[900]!,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _retypeNewPasswordController,
                        obscureText: _obscureRetypeNewPassword,
                        decoration: InputDecoration(
                          hintText: "Re-type new password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.blue[900]!,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureRetypeNewPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureRetypeNewPassword =
                                    !_obscureRetypeNewPassword;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => ForgetPasswordPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot your password?',
                          style: TextStyle(color: Colors.blue[900]),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Center(child: Text("Aucune donnée disponible."));
            }
          },
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
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
                    onPressed: () async {
                      if (_currentPasswordController.text.isEmpty ||
                          _newPasswordController.text.isEmpty ||
                          _retypeNewPasswordController.text.isEmpty) {
                        Flushbar(
                          message: 'Please fill in all fields',
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                          flushbarPosition: FlushbarPosition.TOP,
                        ).show(context);
                      } else if (_newPasswordController.text !=
                          _retypeNewPasswordController.text) {
                        Flushbar(
                          message: 'Passwords do not match',
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                          flushbarPosition: FlushbarPosition.TOP,
                        ).show(context);
                      } else if (_newPasswordController.text.length < 8 ||
                          !_containsLetterAndNumber(
                              _newPasswordController.text)) {
                        Flushbar(
                          message:
                              'Password must be at least 8 characters long and contain both letters and numbers',
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                          flushbarPosition: FlushbarPosition.TOP,
                        ).show(context);
                      } else if (_newPasswordController.text ==
                          _currentPasswordController.text) {
                        showFlushbar(
                            context,
                            'New password cannot be the same as the current password',
                            Colors.red);
                      } else {
                        bool success = await _userService.changePassword(
                          userId,
                          _currentPasswordController.text,
                          _newPasswordController.text,
                        );
                        if (success) {
                          Flushbar(
                            message: 'Password changed successfully',
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                            flushbarPosition: FlushbarPosition.TOP,
                          ).show(context);
                        } else {
                          Flushbar(
                            message: 'Incorrect current password',
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                            flushbarPosition: FlushbarPosition.TOP,
                          ).show(context);
                        }
                      }
                    },
                    child: Text(
                      'Change Password',
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
        ),
      ),
    );
  }
}
