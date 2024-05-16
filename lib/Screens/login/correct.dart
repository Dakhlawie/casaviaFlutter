import 'package:casavia/Screens/login/password.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Correct extends StatefulWidget {
  final String firstname;
  final String lastname;
  final String email;
  const Correct(
      {super.key,
      required this.firstname,
      required this.lastname,
      required this.email});

  @override
  State<Correct> createState() => _CorrectState();
}

class _CorrectState extends State<Correct> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => PasswordPage(
            firstname: widget.firstname,
            lastname: widget.lastname,
            email: widget.email,
          ),
        ),
      );
    });
    return Scaffold(
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        double width = constraints.maxWidth * 0.5;
        double height = constraints.maxHeight * 0.5;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(
                child: SvgPicture.asset(
                  'assets/code.svg',
                  width: width,
                  height: height,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
