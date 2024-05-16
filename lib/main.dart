import 'package:casavia/Screens/core/comments.dart';
import 'package:casavia/Screens/core/hereplaces.dart';
import 'package:casavia/Screens/core/menu.dart';
import 'package:casavia/Screens/core/search.dart';
import 'package:casavia/Screens/core/rate.dart';

import 'package:casavia/Screens/login/infos.dart';
import 'package:casavia/Screens/login/login_page.dart';
import 'package:casavia/Screens/login/password.dart';
import 'package:casavia/Screens/login/starting_page.dart';
import 'package:casavia/home.dart';
import 'package:casavia/model/userModel.dart';
import 'package:casavia/services/AuthService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserModel>(
      create: (context) => UserModel(),
      child: MaterialApp(
        home: StartingPage(),
      ),
    );
  }
}
