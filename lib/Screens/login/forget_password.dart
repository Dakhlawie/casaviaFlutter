import 'package:another_flushbar/flushbar.dart';
import 'package:casavia/Screens/login/infos.dart';
import 'package:casavia/Screens/login/login_page.dart';
import 'package:casavia/Screens/login/signUp.dart';
import 'package:casavia/model/user.dart';
import 'package:casavia/services/UserService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  void showFlushbar(BuildContext context, String message, Color color) {
    Flushbar(
      message: message,
      backgroundColor: color,
      duration: Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  UserService userService = UserService();
  TextEditingController mailController = TextEditingController();
  String _emailerror = "";
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      'assets/forget.svg',
                      height: MediaQuery.of(context).size.height * 0.25,
                    ),
                    SizedBox(height: 24.0),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Forgot your password",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'AbrilFatface',
                            ),
                          ),
                        ]),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Enter your email to be able to reset your password",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                fontFamily: 'AbrilFatface',
                                color: const Color.fromARGB(111, 0, 0, 0)),
                          ),
                        ]),
                    SizedBox(height: 24.0),
                    TextFormField(
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
                        hintText: "Enter your email",
                        hintStyle:
                            TextStyle(fontFamily: 'AbrilFatface', fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.blue[900]!,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 24.0,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (mailController.text.isNotEmpty) {
                            User? u = await userService
                                .findUserByEmail(mailController.text);
                            print(u);
                            if (u != null) {
                              await userService.sendRecoverEmail(
                                  u.email, u.prenom, u.nom);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()),
                              );
                            } else {
                              showDialog(
                                //validate email
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                    title: Center(
                                      child: Text(
                                          'We couldn\'t find your account.',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'AbrilFatface',
                                          )),
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'It looks like ${mailController.text} isn\'t connected to an account. You can create a new account with this email.',
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 20),
                                        Column(
                                          children: [
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          SignUpPage(),
                                                    ),
                                                  );
                                                },
                                                style: ButtonStyle(
                                                  shape:
                                                      MaterialStateProperty.all(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          Colors.blue[900]),
                                                  foregroundColor:
                                                      MaterialStateProperty.all(
                                                          Colors.white),
                                                ),
                                                child:
                                                    Text('Create new account'),
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ForgetPasswordPage(),
                                                    ),
                                                  ); // Ferme la boîte de dialogue
                                                },
                                                style: ButtonStyle(
                                                  shape:
                                                      MaterialStateProperty.all(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                  ),
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          Colors.blue[900]),
                                                  foregroundColor:
                                                      MaterialStateProperty.all(
                                                          Colors.white),
                                                ),
                                                child: Text('Try again'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }
                          } else {
                            showFlushbar(context, 'Please fill in your email.',
                                Colors.red);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.all(12),
                          backgroundColor: Colors.blue[900],
                        ),
                        child: Text('Send',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'AbrilFatface',
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
