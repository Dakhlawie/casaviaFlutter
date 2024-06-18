import 'package:casavia/theme/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';


AppBar buildAppBar({required BuildContext context,final String? title}) {
  return AppBar(
    leading: Center( child: GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Icon(Icons.arrow_back_ios_new_outlined),
    ),),
    elevation: 0,
    backgroundColor: Colors.transparent,
    centerTitle: true,
    title: Text(
      title ?? '',
      textAlign: TextAlign.center,
      style: Styles.style25,
    ),
  );
}
