import 'package:casavia/Screens/core/Chat.dart';
import 'package:casavia/Screens/core/Reviews.dart';
import 'package:casavia/Screens/core/conversation.dart';
import 'package:casavia/Screens/core/payement/newcarte.dart';
import 'package:casavia/Screens/core/thank_you_view.dart';
import 'package:casavia/Screens/core/update_reservation.dart';
import 'package:casavia/Screens/login/passwordSecurity.dart';
import 'package:casavia/Screens/login/signUp.dart';
import 'package:casavia/Screens/login/starting_page.dart';
import 'package:casavia/model/userModel.dart';
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
      child: MaterialApp(home: StartingPage()),
    );
  }
}
