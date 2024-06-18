import 'package:another_flushbar/flushbar.dart';
import 'package:casavia/Screens/login/forget_password.dart';
import 'package:casavia/Screens/login/infos.dart';
import 'package:casavia/Screens/login/signUp.dart';

import 'package:casavia/Screens/login/welcome.dart';
import 'package:casavia/services/AuthService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_svg/svg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController mailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isObscured = true;
  String _emailerror = "";
  String _passerror = "";
  void showFlushbar(BuildContext context, String message, Color color) {
    Flushbar(
      message: message,
      backgroundColor: color,
      duration: Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                  builder: (context) => Welcome(),
                ),
              );
            },
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 600),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/login.svg',
                        height: MediaQuery.of(context).size.height * 0.25,
                      ),
                      SizedBox(height: 30),
                      TextField(
                        controller: mailController,
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(
                              fontFamily: 'AbrilFatface', fontSize: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: Icon(
                            Icons.email,
                            color: Colors.blue[900],
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.blue[900]!, width: 1.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      TextField(
                        obscureText: _isObscured,
                        controller: passwordController,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintStyle: TextStyle(
                              fontFamily: 'AbrilFatface', fontSize: 14),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.blue[900]!, width: 1.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Colors.blue[900],
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscured
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscured = !_isObscured;
                              });
                            },
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => ForgetPasswordPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Forgot your password?',
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontFamily: 'AbrilFatface',
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            print(mailController.text);
                            print(passwordController.text);
                            if (mailController.text.isNotEmpty &&
                                passwordController.text.isNotEmpty) {
                              AuthService authService = AuthService();

                              final result = await authService.login(
                                mailController.text,
                                passwordController.text,
                              );

                              if (result['success']) {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => Welcome(),
                                  ),
                                );
                              } else {
                                final errorMessage = result['message'];
                                showFlushbar(context,
                                    "Invalid email or password.", Colors.red);
                              }
                            } else {
                              showFlushbar(
                                  context,
                                  "Please enter your email and your password.",
                                  Colors.red);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.all(12),
                            backgroundColor: Colors.blue[900],
                          ),
                          child: Text('Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'AbrilFatface',
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't you have an acccount?",
                            style: TextStyle(
                              color: Colors.grey,
                              decoration: TextDecoration.none,
                              fontFamily: 'AbrilFatface',
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => SignUpPage(),
                                ),
                              );
                            },
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.blue[900],
                                decoration: TextDecoration.none,
                                fontFamily: 'AbrilFatface',
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
          ),
        ),
      ),
    );
  }
}
