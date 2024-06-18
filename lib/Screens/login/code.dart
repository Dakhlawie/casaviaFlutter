import 'package:casavia/Screens/login/correct.dart';
import 'package:casavia/Screens/login/password.dart';
import 'package:casavia/Screens/login/passwordSecurity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CodePage extends StatefulWidget {
  final String firstname;
  final String lastname;
  final String email;
  final String country;
  final String tlf;
  final String codePays;
  const CodePage(
      {super.key,
      required this.firstname,
      required this.lastname,
      required this.email,
      required this.country,
      required this.tlf,
      required this.codePays});

  @override
  State<CodePage> createState() => _CodePageState();
}

class _CodePageState extends State<CodePage> {
  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: TextStyle(color: Colors.white, fontFamily: 'AbrilFatface')),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    sendCode();
  }

  sendCode() async {
    await sendCodeByEmail(widget.email);
  }

  final List<TextEditingController> verificationCodeControllers =
      List.generate(6, (index) => TextEditingController());
  String getCodeFromControllers() {
    String code = '';
    for (TextEditingController controller in verificationCodeControllers) {
      code += controller.text;
    }
    return code;
  }

  Future<String> sendCodeByEmail(String email) async {
    final url = Uri.parse('http://192.168.1.17:3000/user/register');
    Map<String, dynamic> verifData = {
      'email': email,
    };
    String jsonBody = jsonEncode(verifData);
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonBody,
    );

    if (response.statusCode == 200) {
      return email;
    } else {
      throw Exception('Failed to send code by email');
    }
  }

  Future<bool> verifyCode(String code) async {
    var url = Uri.parse('http://192.168.1.17:3000/user/verifcode');
    print('EM' + widget.email);
    Map<String, dynamic> verifData = {
      'email': widget.email,
      'code': code,
    };
    String jsonBody = jsonEncode(verifData);
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonBody,
    );
    print(json.decode(response.body));
    return json.decode(response.body)["result"];
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
                    padding: EdgeInsets.only(left: 120),
                    child: SvgPicture.asset(
                      'assets/email.svg',
                      height: MediaQuery.of(context).size.height * 0.15,
                    ),
                  ),
                  SizedBox(height: 40),
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Check your email for a 6-digit verification code.",
                          style: TextStyle(
                              color: Colors.grey, fontFamily: 'AbrilFatface'),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "This step ensures the security of your account.",
                          style: TextStyle(
                              color: Colors.grey, fontFamily: 'AbrilFatface'),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            6,
                            (index) => SizedBox(
                              width: 50,
                              child: TextFormField(
                                controller: verificationCodeControllers[index],
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                decoration: InputDecoration(
                                  counterText: "",
                                  hintText: "_",
                                  border: OutlineInputBorder(),
                                ),
                                textAlign: TextAlign.center,
                                onChanged: (value) {
                                  if (value.isNotEmpty && index < 5) {
                                    FocusScope.of(context).nextFocus();
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
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
                                    String code = getCodeFromControllers();
                                    if (code.length != 6) {
                                      showSnackBar(context,
                                          'Please enter a valid 6-digit code');
                                      return;
                                    }
                                    if (!await verifyCode(code)) {
                                      showSnackBar(context, 'Invalid code');
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PasswordSecurity(
                                                  firstname: widget.firstname,
                                                  lastname: widget.lastname,
                                                  email: widget.email,
                                                  country: widget.country,
                                                  tlf: widget.tlf,
                                                  codePays: widget.codePays,
                                                )),
                                      );
                                    }
                                  },
                                  child: Text(
                                    'VERIFY',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'AbrilFatface'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Didn't receive the verification code? ",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontFamily: 'AbrilFatface'),
                            ),
                            TextButton(
                              onPressed: () {
                                sendCode();
                              },
                              child: Text(
                                "Send again",
                                style: TextStyle(
                                    color: Colors.blue[900],
                                    fontFamily: 'AbrilFatface'),
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
