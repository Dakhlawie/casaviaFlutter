import 'package:casavia/Screens/login/login_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:flutter_svg/flutter_svg.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => LoginPage(),
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
                  'assets/registration.svg',
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
