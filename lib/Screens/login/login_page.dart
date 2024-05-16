import 'package:casavia/Screens/login/forget_password.dart';
import 'package:casavia/Screens/login/infos.dart';

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
  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'AbrilFatface',
            )),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController mailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isObscured = true;
  String _emailerror = "";
  String _passerror = "";

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
                        onTap: () {
                          setState(() {
                            if (mailController.text.isEmpty) {
                              _emailerror = "This field cannot be empty";
                            } else {
                              _emailerror = "";
                            }
                          });
                        },
                        onChanged: (value) {
                          setState(() {
                            if (mailController.text.isEmpty) {
                              _emailerror = "This field cannot be empty";
                            } else {
                              _emailerror = "";
                            }
                          });
                        },
                        keyboardType: TextInputType.emailAddress,
                        controller: mailController,
                        decoration: InputDecoration(
                          labelText: "Enter your Email",
                          labelStyle: TextStyle(
                              fontFamily: 'AbrilFatface', fontSize: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.blue[900]!,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.email,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      TextField(
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: _isObscured,
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
                            fontFamily: 'AbrilFatface',
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Colors.blue[900],
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscured
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.blue[900],
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
                                widget.showSnackBar(
                                    context, "invalid email or password ");
                              }
                            } else {
                              widget.showSnackBar(context,
                                  "Please enter your email and your password");
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
                                  builder: (context) => UserInformation(),
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
